{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.forgejo;
  # tank/forgejo dataset is mounted here (see system/hosts/glados/disko.nix).
  # Repos, LFS objects, and the sqlite DB all live under stateDir, so a single
  # `zfs snapshot tank/forgejo@x` captures the whole forge atomically.
  base = "/mnt/tank/forgejo";
in
{
  options.modules.services.forgejo = {
    enable = lib.mkEnableOption "Forgejo git forge";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port the Forgejo web UI / API listens on.";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2223;
      description = ''
        Port for Forgejo's built-in git-over-SSH server. Deliberately not 22
        (that's Netbird's SSH on wt0) nor 2222 (used by the gitolite git-server
        module), so the two forges can coexist. Forgejo runs its own in-process
        SSH daemon here — it does not touch system sshd.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      description = ''
        Host as reached over the Netbird mesh (wt0). Feeds DOMAIN, SSH_DOMAIN and
        ROOT_URL, so it's what shows up in the web UI's clone URLs. Must resolve
        over the mesh from clients (netbird name or wt0 IP).
      '';
    };

    lfs = lib.mkEnableOption "Git LFS support" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      stateDir = base;
      # sqlite: the module manages the DB file under stateDir. No extra service,
      # no password / sops secret needed.
      database.type = "sqlite3";
      lfs.enable = cfg.lfs;

      settings = {
        server = {
          DOMAIN = cfg.domain;
          HTTP_ADDR = "0.0.0.0"; # reachable over wt0 (module default is localhost)
          HTTP_PORT = cfg.port;
          ROOT_URL = "https://git.aleclowry.com/";
          # Built-in SSH server (runs as the forgejo user, not system sshd).
          START_SSH_SERVER = true;
          SSH_DOMAIN = cfg.domain;
          SSH_PORT = cfg.sshPort; # advertised in clone URLs
          SSH_LISTEN_PORT = cfg.sshPort; # port the built-in server binds
        };
        # Open sign-ups enabled. The first account to register becomes the
        # instance admin automatically. Reachable only over the mesh (wt0), so
        # "open" means open to Netbird peers, not the public internet.
        service.DISABLE_REGISTRATION = false;
        # Plain HTTP for now (mesh-only). Revisit when Forgejo moves behind Traefik.
        session.COOKIE_SECURE = false;
      };
    };

    # The nixpkgs forgejo module emits its own tmpfiles rule creating stateDir as
    # forgejo:forgejo (runs after the mount), so no ownership fixup is needed here.
    # Both the main service AND the secret-bootstrap helper must wait for the ZFS
    # mount: forgejo-secrets uses ReadWritePaths=customDir, and systemd sets up its
    # mount namespace before the script runs — if it starts before the dataset is
    # mounted (and its subdirs created), it dies with 226/NAMESPACE on the missing
    # custom/ dir.
    systemd.services.forgejo.unitConfig.RequiresMountsFor = [ base ];
    systemd.services.forgejo-secrets.unitConfig.RequiresMountsFor = [ base ];

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to the
    # global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      cfg.port
      cfg.sshPort
    ];
  };
}
