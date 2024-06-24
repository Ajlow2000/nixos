{ config, lib, ... }:
let 
    cfg = config.desktop-environment;
in {
    options = {
        desktop-environment.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        # Enable the X11 windowing system.
        services.xserver.enable = true;

        # Enable the GNOME Desktop Environment.
        services.xserver.desktopManager.gnome.enable = true;
    };
}
