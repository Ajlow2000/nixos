{ config, lib, ... }:
let
  cfg = config.modules.services.mealie;
  base = "/mnt/tank/mealie";
in
{
  options.modules.services.mealie = {
    enable = lib.mkEnableOption "Mealie recipe manager";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "Port the Mealie web UI listens on.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie = {
      enable = true;
      port = cfg.port;
      settings = {
        DATA_DIR = base;
        ALLOW_SIGNUP = "false";
      };
    };

    # The upstream module uses DynamicUser=true, which can't own a ZFS mountpoint.
    # Override to a static user so tmpfiles can set ownership on /mnt/tank/mealie.
    systemd.services.mealie = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "mealie";
        Group = "mealie";
      };
      unitConfig.RequiresMountsFor = [ base ];
    };

    users.users.mealie = {
      isSystemUser = true;
      group = "mealie";
    };
    users.groups.mealie = { };

    systemd.tmpfiles.rules = [ "d ${base} 0750 mealie mealie -" ];

    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];
  };
}
