{ config, lib, ... }:
let 
    cfg = config.de;
in {
    imports = [
        ./my_hypr.nix
    ];

    options = {
        de.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        my_hypr.enable = true;
    };
}
