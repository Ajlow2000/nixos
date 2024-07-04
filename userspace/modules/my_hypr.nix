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
        wayland.windowManager.hyprland.enable = true;
        wayland.windowManager.hyprland.settings = {
            "$mod" = "SUPER";
            bind = [
                "$mod,              RETURN,     exec,           kitty tmux-session-manager"
                "$mod SHIFT,        RETURN,     exec,           firefox"
                "$mod,              q,          exit, "
                "$mod SHIFT,        c,          killactive, "
                "$mod,              f,          fullscreen, 1"
                "$mod SHIFT,        f,          fullscreen, 0"
                ",                  f11,        fullscreen, 0"
                "$mod CONTROL SHIFT,f,          fullscreen, 2"

                "$mod,              m,          togglefloating, "
                "$mod,              P,          pseudo, "
                "$mod,              J,          togglesplit, "

                "$mod,              SPACE,      exec,           wofi --show drun"
                ",                  Print,      exec,           grimblast copy area"
            ];
        };
    };
}
