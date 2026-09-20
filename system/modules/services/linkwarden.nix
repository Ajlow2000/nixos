{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.linkwarden;
in
{
  options.modules.services.linkwarden = {
    enable = lib.mkEnableOption "Linkwarden bookmark manager";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3100;
      description = "Port Linkwarden listens on.";
    };

    storageDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tank/services/linkwarden";
      description = "Directory for stored media (screenshots, PDFs, etc.).";
    };

    nextauthUrl = lib.mkOption {
      type = lib.types.str;
      description = "Full public URL of the Linkwarden instance (used for NEXTAUTH_URL).";
    };

    nextauthSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the NEXTAUTH_SECRET value.";
    };

    enableRegistration = lib.mkEnableOption "user registration";

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "links";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.linkwarden = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.port;
      storageLocation = cfg.storageDir;
      enableRegistration = cfg.enableRegistration;
      secretFiles.NEXTAUTH_SECRET = cfg.nextauthSecretFile;
      environment.NEXTAUTH_URL = cfg.nextauthUrl;
    };

    systemd.tmpfiles.rules = [ "d ${cfg.storageDir} 0750 linkwarden linkwarden -" ];
    systemd.services.linkwarden.unitConfig.RequiresMountsFor = [ cfg.storageDir ];
    systemd.services.linkwarden-worker.unitConfig.RequiresMountsFor = [ cfg.storageDir ];

    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
