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

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "glance";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create a real system user so sops-nix can own secret files for the
    # service (DynamicUser allocates the user only at runtime, after activation).
    users.users.glance = {
      isSystemUser = true;
      group = "glance";
    };
    users.groups.glance = {};

    systemd.services.glance.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "glance";
      Group = lib.mkForce "glance";
    };

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

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
