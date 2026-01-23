{ config, lib, pkgs, ... }:
let
    cfg = config.modules.hardware.power;
in {
    options.modules.hardware.power = {
        enable = lib.mkEnableOption "laptop power management";

        cpuGovernor = lib.mkOption {
            type = lib.types.str;
            default = "powersave";
            description = "CPU frequency scaling governor";
        };
    };

    config = lib.mkIf cfg.enable {
        powerManagement.cpuFreqGovernor = cfg.cpuGovernor;

        # Use latest kernel for better hardware support on laptops
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
}
