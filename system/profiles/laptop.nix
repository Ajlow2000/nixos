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

        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.blueman.enable = true;

        systemd.services.bluetooth-rfkill-unblock = {
            description = "Unblock Bluetooth rfkill soft block";
            before = [ "bluetooth.service" ];
            wantedBy = [ "bluetooth.service" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
            };
        };
    };
}
