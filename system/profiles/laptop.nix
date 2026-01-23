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
        # Enable desktop profile (which also enables base)
        profiles.system.desktop.enable = true;

        # Laptop-specific power management
        modules.hardware.power.enable = true;
    };
}
