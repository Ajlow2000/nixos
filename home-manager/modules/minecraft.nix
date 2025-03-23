{ config, lib, pkgs, ... }:
let 
    cfg = config.minecraft;
in {
    options = {
        minecraft.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; ([
            prismlauncher
        ]);
    };
}
