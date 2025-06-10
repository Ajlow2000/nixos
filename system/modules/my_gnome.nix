{ config, lib, ... }:
let 
    cfg = config.my_gnome;
in {
    options = {
        my_gnome.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        # Enable the X11 windowing system.
        services.xserver.enable = true;

        # Enable the GNOME Desktop Environment.
        services.desktopManager.gnome.enable = true;
    };
}
