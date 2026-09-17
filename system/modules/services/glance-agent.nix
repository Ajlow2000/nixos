{ config, lib, pkgs, ... }:
let
  cfg = config.modules.services.glanceAgent;
in
{
  options.modules.services.glanceAgent = {
    enable = lib.mkEnableOption "Glance Agent (system metrics for Glance server-stats widget)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 27973;
      description = "Port the Glance Agent listens on (wt0 only).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.glance-agent = {
      description = "Glance Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment.PORT = toString cfg.port;

      serviceConfig = {
        ExecStart = "${pkgs.glance-agent}/bin/glance-agent";
        Restart = "always";
        RestartSec = 5;
        DynamicUser = true;
      };
    };

    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];
  };
}
