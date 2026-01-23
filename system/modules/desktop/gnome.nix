{ config, lib, ... }:
let
    cfg = config.modules.desktop.gnome;
in {
    options.modules.desktop.gnome = {
        enable = lib.mkEnableOption "GNOME desktop environment";
    };

    config = lib.mkIf cfg.enable {
        # Enable the X11 windowing system
        services.xserver.enable = true;

        # Enable the GNOME Desktop Environment
        services.desktopManager.gnome.enable = true;
    };
}
