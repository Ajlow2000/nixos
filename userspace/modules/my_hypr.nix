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
        wayland.windowManager.hyprland = {
            enable = true;
            settings = {
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

                    "$mod, u, workspace, m-1, "
                    "$mod, i, workspace, m+1, "

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

                    # Master Layout binds
                    "$mod, m, layoutmsg, swapwithmaster master"
                    "$mod, n, layoutmsg, rollnext"
                    "$mod, b, layoutmsg, rollprev"
                    "$mod, left, layoutmsg, orientationleft"
                    "$mod, up, layoutmsg, orientationtop"
                    "$mod, down, layoutmsg, orientationbottom"
                    "$mod, right, layoutmsg, orientationright"

                    "$mod, mouse:272, movewindow"           # mod + LMB
                    "$mod, mouse:273, resizewindowpixel"    # mod + RMB

                    # Scroll through workspaces with mod + scroll
                    "$mod, mouse_down, workspace, m+1"
                    "$mod, mouse_up, workspace, m-1"

                    "$mod,              F12,          togglefloating, "

                    "$mod,              SPACE,      exec,           wofi --show drun"
                    ",                  Print,      exec,           grimblast copy area"
                ];

                general = {
                    layout = "master"; # dwindle | master

                    gaps_in = 5;
                    gaps_out = 5;
                    border_size = 2;
                };

                decoration = {
                    rounding = 5;
                };

                input = {
                    kb_layout = "us";
                    kb_options = "ctrl:nocaps";

                    follow_mouse = 0;

                    touchpad = {
                        natural_scroll = 1;
                    };

                    sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
                };

                gestures = {
                    workspace_swipe = "on";
                };
            };
        };
    };
}
