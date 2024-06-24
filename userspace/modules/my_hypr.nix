{ config, lib, ... }:
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
        # home.file = {
        #     hyprland = {
        #         recursive = true;
        #         source = ../dotfiles/hypr;
        #         target = "./.config/hypr";
        #     };
        #     waybar = {
        #         recursive = true;
        #         source = ../dotfiles/waybar;
        #         target = "./.config/waybar";
        #     };
        # };
    };
}
