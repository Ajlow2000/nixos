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

                "$mod, h, movefocus, l"
                "$mod, l, movefocus, r"
                "$mod, k, movefocus, u"
                "$mod, j, movefocus, d"

                "$mod, 1, workspace, 1"
                "$mod, 2, workspace, 2"
                "$mod, 3, workspace, 3"
                "$mod, 4, workspace, 4"
                "$mod, 5, workspace, 5"
                "$mod, 6, workspace, 6"
                "$mod, 7, workspace, 7"
                "$mod, 8, workspace, 8"
                "$mod, 9, workspace, 9"
                "$mod, 0, workspace, 10"

                "$mod SHIFT, 1, movetoworkspace, 1"
                "$mod SHIFT, 2, movetoworkspace, 2"
                "$mod SHIFT, 3, movetoworkspace, 3"
                "$mod SHIFT, 4, movetoworkspace, 4"
                "$mod SHIFT, 5, movetoworkspace, 5"
                "$mod SHIFT, 6, movetoworkspace, 6"
                "$mod SHIFT, 7, movetoworkspace, 7"
                "$mod SHIFT, 8, movetoworkspace, 8"
                "$mod SHIFT, 9, movetoworkspace, 9"
                "$mod SHIFT, 0, movetoworkspace, 10"


                "$mod,              m,          togglefloating, "
                "$mod,              P,          pseudo, "
                "$mod,              J,          togglesplit, "

                "$mod,              SPACE,      exec,           wofi --show drun"
                ",                  Print,      exec,           grimblast copy area"
            ];
        };
    };
}
