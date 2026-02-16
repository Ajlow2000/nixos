{ config, lib, pkgs, ... }:
let
    cfg = config.modules.desktop.cosmic;
in {
    options.modules.desktop.cosmic = {
        enable = lib.mkEnableOption "COSMIC desktop environment";

        xwayland = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable XWayland support";
        };
    };

    config = lib.mkIf cfg.enable {
        services.desktopManager.cosmic.enable = true;
        services.displayManager.cosmic-greeter.enable = true;
        services.desktopManager.cosmic.xwayland.enable = cfg.xwayland;
    };
}
