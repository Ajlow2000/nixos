{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.immich;
  # tank/immich/* datasets are mounted here (see system/hosts/glados/disko.nix).
  base = "/mnt/tank/immich";
in
{
  options.modules.services.immich = {
    enable = lib.mkEnableOption "Immich photo/video server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = "Port the Immich web/API listens on.";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "immich";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0"; # reachable over wt0 (module default is localhost)
      port = cfg.port;
      mediaLocation = "${base}/library";
      machine-learning.enable = true; # smart search + face detection (CPU)
      # database.enable / redis.enable default to true -> the module provisions
      # PostgreSQL (pgvector + vectorchord) and Redis. DB uses a unix socket
      # with peer auth, so no password / sops secret is needed.
    };

    # Don't start these before their datasets are mounted.
    systemd.services.immich-server.unitConfig.RequiresMountsFor = [ "${base}/library" ];

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to the
    # global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
