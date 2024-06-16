{ config, pkgs, ... }: {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.desktopManager.gnome.enable = true;
}
