{ config, lib, ... }:
let 
    cfg = config.display-manager;
in {
    options = {
        display-manager.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        services.xserver.displayManager.lightdm.enable = true;
        services.xserver.displayManager.lightdm.greeters.slick.enable = true;
    };
}
