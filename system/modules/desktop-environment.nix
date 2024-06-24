{ config, lib, ... }:
let 
    cfg = config.desktop-environment;
in {
    imports = [
        ./my_gnome.nix
        ./my_hypr.nix
    ];

    options = {
        desktop-environment.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        my_hypr.enable = true;
    };
}
