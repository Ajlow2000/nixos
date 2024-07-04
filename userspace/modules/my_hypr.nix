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
        wayland.windowManager.hyprland.settings = {
            "$mod" = "SUPER";
            bind = [
                ",              Print,  exec,           grimblast copy area"
                "$mod,          RETURN, exec,           kitty tmux-session-manager"
                "$mod SHIFT,    RETURN, exec,           firefox"
                "$mod,          DELETE, killactive, "
                "$mod SHIFT,    DELETE, exit, "
                "$mod,          M,      togglefloating, "
                "$mod,          SPACE,  exec,           wofi --show drun"
                "$mod,          P,      pseudo, "
                "$mod,          J,      togglesplit, "
            ];
        };
    };
}
