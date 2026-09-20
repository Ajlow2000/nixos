{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.freshrss;
in
{
  options.modules.services.freshrss = {
    enable = lib.mkEnableOption "FreshRSS RSS reader";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3200;
      description = "Port the Nginx vhost for FreshRSS listens on.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tank/services/freshrss";
      description = "Directory for FreshRSS data.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      description = "Full public URL of the FreshRSS instance.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the admin user password.";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "rss";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      webserver = "nginx";
      virtualHost = cfg.baseUrl;
      baseUrl = cfg.baseUrl;
      dataDir = cfg.dataDir;
      passwordFile = cfg.passwordFile;
      database.type = "sqlite";
    };

    # Override the vhost to listen on a specific port instead of 80.
    services.nginx.virtualHosts.${cfg.baseUrl}.listen = [
      { addr = "0.0.0.0"; port = cfg.port; }
    ];

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0750 freshrss freshrss -" ];
    systemd.services.freshrss-config.unitConfig.RequiresMountsFor = [ cfg.dataDir ];

    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
