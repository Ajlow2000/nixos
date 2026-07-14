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
          LANDING_PAGE = "explore";
        };
        service.DISABLE_REGISTRATION = true;
        # Plain HTTP for now (mesh-only). Revisit when Forgejo moves behind Traefik.
        session.COOKIE_SECURE = false;
        # Custom "terminus" colorscheme (forest-green, matches the cgit theme).
        # The CSS is symlinked into customDir/public/assets/css below. THEMES is a
        # whitelist, so the built-ins stay selectable alongside it.
        ui = {
          THEMES = "forgejo-auto,forgejo-light,forgejo-dark,gitea-auto,gitea-light,gitea-dark,terminus";
          DEFAULT_THEME = "terminus";
        };
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

    # Drop the custom theme CSS into customDir/public/assets/css. The upstream
    # module only creates custom/ and custom/conf/, so we build the asset tree
    # ourselves and symlink the store-interned CSS in. L+ replaces any existing
    # link so a redeploy picks up edits. Lives under the ZFS mount (base), same
    # as the immich mounted-dir tmpfiles pattern.
    systemd.tmpfiles.rules = [
      "d ${base}/custom/public 0755 forgejo forgejo -"
      "d ${base}/custom/public/assets 0755 forgejo forgejo -"
      "d ${base}/custom/public/assets/css 0755 forgejo forgejo -"
      "L+ ${base}/custom/public/assets/css/theme-terminus.css - - - - ${./theme-terminus.css}"
    ];

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to the
    # global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      cfg.port
      cfg.sshPort
    ];
  };
}
