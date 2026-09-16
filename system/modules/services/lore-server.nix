{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.loreServer;
  lorePkg = pkgs.callPackage ../../pkgs/lore.nix { };

  # Minimal TOML config: override data path only; ports and other settings use
  # the defaults baked into the binary (QUIC/gRPC on 41337, HTTP on 41339).
  configFile = (pkgs.formats.toml { }).generate "lore-server.toml" {
    path = cfg.dataDir;
  };
in
{
  options.modules.services.loreServer = {
    enable = lib.mkEnableOption "Lore VCS server";

    grpcPort = lib.mkOption {
      type = lib.types.port;
      default = 41337;
      description = "QUIC/gRPC port for Lore clients. Opened directly in the firewall (not proxied — QUIC is UDP).";
    };

    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 41339;
      description = "HTTP port for health checks and REST endpoints. Proxied through Caddy when exposeInternal is true.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/tank/services/lore";
      description = "Directory for Lore server data (repos, metadata).";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy (proxies the HTTP port only)";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "lore";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.lore = {
      isSystemUser = true;
      group = "lore";
      home = cfg.dataDir;
    };
    users.groups.lore = { };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0750 lore lore -" ];

    systemd.services.lore-server = {
      description = "Lore VCS server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      unitConfig.RequiresMountsFor = [ cfg.dataDir ];

      serviceConfig = {
        ExecStart = "${lorePkg}/bin/loreserver";
        User = "lore";
        Group = "lore";
        Restart = "on-failure";
        Environment = "LORE_CONFIG_PATH=${configFile}";
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.dataDir ];
      };
    };

    # QUIC is UDP — open the gRPC port directly on wt0 for Lore clients.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.grpcPort cfg.httpPort ];
    networking.firewall.interfaces.wt0.allowedUDPPorts = [ cfg.grpcPort ];

    # Caddy proxies only the HTTP port (QUIC can't go through Caddy).
    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.httpPort}";
    };
  };
}
