{ config, lib, ... }:
let
    cfg = config.modules.desktop.display-manager;
in {
    options.modules.desktop.display-manager = {
        enable = lib.mkEnableOption "LightDM display manager with Slick greeter";
    };

    config = lib.mkIf cfg.enable {
        services.xserver.displayManager.lightdm.enable = true;
        services.xserver.displayManager.lightdm.greeters.slick.enable = true;
    };
}
