{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.glance;
in
{
  options.modules.services.glance = {
    enable = lib.mkEnableOption "Glance dashboard";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port the Glance web UI listens on.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.glance = {
      enable = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = cfg.port;
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  { type = "clock"; }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Uptime Kuma";
                        url = "https://uptime.prod.services.aleclowry.com/dashboard";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to
    # the global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];
  };
}
