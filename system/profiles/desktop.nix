{ config, lib, pkgs, ... }:
let
    cfg = config.profiles.system.desktop;
in {
    imports = [
        ./base.nix
        ../modules/services/audio.nix
        ../modules/services/printing.nix
        ../modules/services/docker.nix
        ../modules/services/virtualization.nix
        ../modules/services/mpd.nix
        ../modules/hardware/tablet.nix
        ../modules/localization/mandarin.nix
    ];

    options.profiles.system.desktop = {
        enable = lib.mkEnableOption "desktop system profile";
    };

    config = lib.mkIf cfg.enable {
        profiles.system.base.enable = true;

        modules.services.audio.enable = lib.mkDefault true;
        modules.services.printing.enable = lib.mkDefault true;
        modules.services.docker.enable = lib.mkDefault true;
        modules.services.virtualization.enable = lib.mkDefault true;
        modules.services.mpd.enable = lib.mkDefault true;
        modules.hardware.tablet.enable = lib.mkDefault true;
        mandarin.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
            firefox
            libnotify
            wineWowPackages.stable
        ];

        programs.firefox.enable = true;
        programs.noisetorch.enable = true;

        services.xserver.xkb = {
            layout = "us";
            variant = "";
        };
    };
}
