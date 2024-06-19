{ config, pkgs, ... }: {
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.lightdm.greeters.slick.enable = true;
}
