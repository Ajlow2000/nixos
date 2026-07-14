{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.fileShares;

  fbFormat = pkgs.formats.json { };

  publicBase = "/mnt/tank/public-share";
  internalBase = "/mnt/tank/internal-share";

  # Upstream services.filebrowser is single-instance, so we run one systemd
  # service per share, mirroring the upstream unit
  # (nixos/modules/services/web-apps/filebrowser.nix): a JSON --config plus a
  # hardened serviceConfig. preStart seeds the admin user from a sops secret on
  # first init (filebrowser keeps users in its Bolt DB, which lives on local
  # /var/lib — only the served `root` is on the tank pool).
  mkFilebrowser =
    {
      name,
      port,
      root,
      group,
      pwSecret,
      readOnly ? false, # public download server: no login, read-only + download
    }:
    let
      user = "fb-${name}";
      stateDir = "/var/lib/filebrowser-${name}";
      cacheDir = "/var/cache/filebrowser-${name}";
      db = "${stateDir}/database.db";
      configFile = fbFormat.generate "filebrowser-${name}.json" {
        address = "0.0.0.0";
        inherit port root;
        database = db;
        "cache-dir" = cacheDir;
      };
      fb = lib.getExe pkgs.filebrowser;
      pwPath = config.sops.secrets.${pwSecret}.path;
    in
    {
      description = "FileBrowser (${name}-share)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      # Serves files from the tank dataset — wait for the ZFS mount.
      unitConfig.RequiresMountsFor = [ root ];

      # preStart runs as the service user (which can read the fb-user-owned sops
      # secret and write the state dir) and BEFORE the daemon opens the Bolt DB,
      # so it holds no lock here.
      #
      # readOnly (public download server): filebrowser's noauth auto-logs every
      # visitor in as user id 1 (hardcoded), so user 1 must be the read-only
      # guest. The DB is fully derived from this config, so we rebuild it every
      # start — this deterministically makes user 1 = guest (read-only+download)
      # and user 2 = admin (full perms). noauth means no login screen; the admin
      # account is thus only reachable via the CLI, which is fine since content
      # is managed over SMB (as ajlow). Nothing valuable lives in the DB.
      #
      # Otherwise (internal): seed the admin once, on first init, and keep state.
      preStart = lib.mkIf config.modules.sops.enable (
        if readOnly then
          ''
            rm -f ${db}
            ${fb} -d ${db} config init
            guestpw="$(head -c 18 /dev/urandom | base64)"
            ${fb} -d ${db} users add guest "$guestpw" \
              --perm.admin=false --perm.create=false --perm.delete=false \
              --perm.modify=false --perm.rename=false --perm.share=false \
              --perm.download=true --lockPassword
            ${fb} -d ${db} users add admin "$(cat ${pwPath})" --perm.admin
            ${fb} -d ${db} config set --auth.method=noauth --hideLoginButton
          ''
        else
          ''
            if [ ! -f ${db} ]; then
              ${fb} -d ${db} config init
              ${fb} -d ${db} users add admin "$(cat ${pwPath})" --perm.admin
            fi
          ''
      );

      serviceConfig = {
        ExecStart = "${fb} --config ${configFile}";
        User = user;
        Group = group;
        StateDirectory = "filebrowser-${name}";
        CacheDirectory = "filebrowser-${name}";
        WorkingDirectory = root;
        UMask = "0007"; # group-writable so ajlow (via the share group) can manage files
        # Hardening, mirrored from the upstream filebrowser module.
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        DevicePolicy = "closed";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
in
{
  options.modules.services.fileShares = {
    enable = lib.mkEnableOption "Samba file shares (public + internal) with filebrowser web UIs";

    publicShare.filebrowserPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port the public-share filebrowser web UI listens on (wt0 only).";
    };

    internalShare.filebrowserPort = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Port the internal-share filebrowser web UI listens on (wt0 only).";
    };
  };

  config = lib.mkIf cfg.enable {
    # --- shared groups + filebrowser service users ---------------------------
    # Samba writes as `ajlow` (guests map to `nobody`); each filebrowser runs as
    # its own system user. A per-share group with setgid dirs lets both manage
    # the same files. `ajlow` is a member of both groups.
    users.groups.public-share = { };
    users.groups.internal-share = { };
    users.users = {
      fb-public = {
        isSystemUser = true;
        group = "public-share";
      };
      fb-internal = {
        isSystemUser = true;
        group = "internal-share";
      };
      ajlow.extraGroups = [
        "public-share"
        "internal-share"
      ];
    };

    # Own/mode the mounted share roots (setgid so new files inherit the group).
    # public: others r-x so guest (nobody) can browse/download.
    # internal: no "other" access, so guests are excluded at the filesystem level.
    systemd.tmpfiles.rules = [
      "d ${publicBase} 2775 ajlow public-share -"
      "d ${internalBase} 2770 ajlow internal-share -"
    ];

    # --- Samba ---------------------------------------------------------------
    services.samba = {
      enable = true;
      # Mesh-only: no NetBIOS name service or winbind needed.
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = false; # scoped to wt0 below, not the public interface

      settings = {
        global = {
          security = "user";
          "server string" = "glados";
          "map to guest" = "Bad User"; # unknown users become the guest account
          "guest account" = "nobody";
          "load printers" = "no";
          "printing" = "bsd";
          "printcap name" = "/dev/null";
          "disable spoolss" = "yes";
        };

        # Download server: anonymous guest read-only, authenticated write (ajlow).
        "public-share" = {
          path = publicBase;
          browseable = "yes";
          "guest ok" = "yes";
          "read only" = "yes";
          "write list" = "ajlow";
          "force group" = "public-share";
          "create mask" = "0664";
          "directory mask" = "2775";
        };

        # Private: authenticated read-write, ajlow only, no guests.
        "internal-share" = {
          path = internalBase;
          browseable = "yes";
          "guest ok" = "no";
          "valid users" = "ajlow";
          "read only" = "no";
          "force group" = "internal-share";
          "create mask" = "0660";
          "directory mask" = "2770";
        };
      };
    };

    # smbd must wait for the tank mounts, and we seed the ajlow SMB password from
    # sops on start (idempotent: adds the passdb entry on first run, updates it
    # thereafter). smbd runs as root, so it can read the root-owned secret.
    systemd.services.samba-smbd = {
      unitConfig.RequiresMountsFor = [
        publicBase
        internalBase
      ];
      preStart = lib.mkIf config.modules.sops.enable ''
        pw="$(cat ${config.sops.secrets."smb-ajlow-password".path})"
        if ${pkgs.samba}/bin/pdbedit -L 2>/dev/null | grep -q '^ajlow:'; then
          printf '%s\n%s\n' "$pw" "$pw" | ${pkgs.samba}/bin/smbpasswd -s ajlow
        else
          printf '%s\n%s\n' "$pw" "$pw" | ${pkgs.samba}/bin/smbpasswd -s -a ajlow
        fi
      '';
    };

    # --- filebrowser (one instance per share) --------------------------------
    systemd.services.filebrowser-public = mkFilebrowser {
      name = "public";
      port = cfg.publicShare.filebrowserPort;
      root = publicBase;
      group = "public-share";
      pwSecret = "filebrowser-public-admin-password";
      readOnly = true;
    };
    systemd.services.filebrowser-internal = mkFilebrowser {
      name = "internal";
      port = cfg.internalShare.filebrowserPort;
      root = internalBase;
      group = "internal-share";
      pwSecret = "filebrowser-internal-admin-password";
    };

    # --- secrets -------------------------------------------------------------
    # Values live in the shared secrets/common.yaml (the sops defaultSopsFile),
    # so every host key can decrypt them. smb password is read by root (smbd
    # preStart); each filebrowser admin password is read by that instance's
    # service user.
    sops.secrets = lib.mkIf config.modules.sops.enable {
      "smb-ajlow-password" = {
        key = "smb/ajlow_passwd";
      };
      "filebrowser-public-admin-password" = {
        key = "filebrowser/public/admin_passwd";
        owner = "fb-public";
        mode = "0400";
      };
      "filebrowser-internal-admin-password" = {
        key = "filebrowser/internal/admin_passwd";
        owner = "fb-internal";
        mode = "0400";
      };
    };

    # --- firewall ------------------------------------------------------------
    # Reachable only over the Netbird mesh (wt0). Deliberately not added to the
    # global allowedTCPPorts so the public interface stays closed. The user will
    # handle exposing public-share to the internet separately.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      445
      139
      cfg.publicShare.filebrowserPort
      cfg.internalShare.filebrowserPort
    ];
  };
}
