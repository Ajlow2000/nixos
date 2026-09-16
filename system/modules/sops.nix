{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.sops;
  hostFile = ../../secrets/hosts + "/${config.networking.hostName}.yaml";
in
{
  options.modules.sops = {
    enable = lib.mkEnableOption "sops-nix secrets management for this host";

    passwords.root.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Manage root via sops on this host: login password (root.passwd) and
        SSH private key (root.ssh_private_key), both from the per-host file
        secrets/hosts/<hostName>.yaml. Requires modules.sops.enable.
      '';
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        User accounts whose login password and SSH private key are sops-managed
        from the shared secrets/common.yaml, under the nested keys
        <user>.passwd and <user>.ssh_private_key. Callers (user-definitions,
        digital-ocean profile) append to this list when the user is enabled.
      '';
    };

    rclone.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Deploy rclone.conf from secrets/common.yaml (key: rclone/config) to
        ~/.config/rclone/rclone.conf for each user in modules.sops.users.
        The file is owner-readable only (0600) and managed entirely by sops-nix.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # User passwords/keys are shared across hosts and live in common.yaml.
    # Root password/key are per-host (the entries below override sopsFile).
    sops.defaultSopsFile = ../../secrets/common.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Nested YAML keys are addressed with "/" (e.g. ajlow/passwd). The secret
    # name is the flat <account>-{passwd,ssh-key}; `key` points at the nested
    # field, `path` controls where the materialized secret lands.
    sops.secrets = lib.mkMerge (
      (lib.optional cfg.passwords.root.enable {
        "root-passwd" = {
          key = "root/passwd";
          neededForUsers = true;
          sopsFile = hostFile;
        };
        "root-ssh-key" = {
          key = "root/ssh_private_key";
          sopsFile = hostFile;
          path = "/root/.ssh/id_ed25519";
          owner = "root";
          group = "root";
          mode = "0600";
        };
      })
      ++ (map (u: {
        "${u}-passwd" = {
          key = "${u}/passwd";
          neededForUsers = true;
        };
        "${u}-ssh-key" = {
          key = "${u}/ssh_private_key";
          path = "/home/${u}/.ssh/id_ed25519";
          owner = u;
          group = "users";
          mode = "0600";
        };
      }) cfg.users)
      ++ (lib.optionals cfg.rclone.enable (map (u: {
        "${u}-rclone-config" = {
          key = "rclone/config";
          path = "/home/${u}/.config/rclone/rclone.conf";
          owner = u;
          group = "users";
          mode = "0600";
        };
      }) cfg.users))
    );

    # ~/.ssh must exist before sops writes the key into it.
    systemd.tmpfiles.rules =
      (lib.optional cfg.passwords.root.enable "d /root/.ssh 0700 root root -")
      ++ map (u: "d /home/${u}/.ssh 0700 ${u} users -") cfg.users
      ++ lib.optionals cfg.rclone.enable
           (map (u: "d /home/${u}/.config/rclone 0700 ${u} users -") cfg.users);

    users.mutableUsers = false;

    # Derive the host age key once at boot, readable by sops users so they can
    # run sops interactively without needing root.
    users.groups.sops-age = { };
    users.users = lib.mkMerge (
      lib.optional cfg.passwords.root.enable {
        root.hashedPasswordFile = config.sops.secrets."root-passwd".path;
      }
      ++ map (u: { ${u}.extraGroups = [ "sops-age" ]; }) cfg.users
    );

    system.activationScripts.sopsHostAgeKey = {
      deps = [ "specialfs" ];
      text = ''
        mkdir -p /etc/sops/age
        ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key \
          -i /etc/ssh/ssh_host_ed25519_key \
          > /etc/sops/age/host.txt
        chown root:sops-age /etc/sops/age/host.txt
        chmod 640 /etc/sops/age/host.txt
      '';
    };
  };
}
