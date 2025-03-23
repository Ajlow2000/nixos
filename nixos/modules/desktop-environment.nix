{ config, lib, ... }:
let 
    cfg = config.desktop-environment;
in {
    imports = [
        ./my_gnome.nix
    ];

    options = {
        desktop-environment.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        my_gnome.enable = true;
    };
}
