{ config, lib, pkgs, ... }:
let 
    cfg = config.my_hypr;
in {
    options = {
        my_hypr.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            wayland-protocols
            wayland-utils
            wl-clipboard
            (waybar.overrideAttrs (oldAttrs: {
                mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
                })
            )
            swww
            mako
            libnotify
            feh
            rofi-wayland
            light
            kitty
        ];

        environment.sessionVariables = {
            WLR_NO_HARDWARE_CURSORS = "1";
            NIXOS_OZONE_WL = "1";
        };

        hardware = {
            graphics.enable = true;
            nvidia.modesetting.enable = true;
        };

        programs.hyprland = {
            enable = true;
            xwayland.enable = true;
        };
    };
}
