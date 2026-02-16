{ config, lib, ... }:
let
    cfg = config.modules.desktop.gnome;
in {
    options.modules.desktop.gnome = {
        enable = lib.mkEnableOption "GNOME desktop environment";
    };

    config = lib.mkIf cfg.enable {
        services.xserver.enable = true;

        services.desktopManager.gnome.enable = true;
    };
}
