{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.uptime-kuma;
in
{
  options.modules.services.uptime-kuma = {
    enable = lib.mkEnableOption "Uptime Kuma monitoring";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Port the Uptime Kuma web UI listens on.";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "status";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = toString cfg.port;
        HOST = "0.0.0.0";
      };
    };

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to
    # the global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
