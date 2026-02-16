{ config, lib, pkgs, ... }:
let
    cfg = config.profiles.system.laptop;
in {
    imports = [
        ./desktop.nix
        ../modules/hardware/power.nix
    ];

    options.profiles.system.laptop = {
        enable = lib.mkEnableOption "laptop system profile";
    };

    config = lib.mkIf cfg.enable {
        profiles.system.desktop.enable = true;

        modules.hardware.power.enable = true;
    };
}
