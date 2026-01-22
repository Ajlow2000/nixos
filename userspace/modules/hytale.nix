{ config, lib, pkgs, inputs, system, ... }:
let
    cfg = config.hytale;
in {
    options = {
        hytale.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = [
            inputs.hytale-nix.packages.${system}.hytale-launcher
        ];
    };
}
