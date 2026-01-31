{ pkgs, lib, inputs, ... }: {
    imports = [
        ./hardware.nix
        ../../profiles/desktop.nix
        ../../modules/desktop/cosmic.nix
        ../../modules/desktop/display-manager.nix
        ../../modules/services/gaming.nix
        ../../modules/user-definitions.nix
    ];

    profiles.system.desktop.enable = true;

    modules.desktop.cosmic.enable = true;

    modules.desktop.display-manager.enable = lib.mkForce false;

    modules.services.gaming.enable = true;

    user-definitions.ajlow.enable = true;

    modules.services.virtualization.users = [ "ajlow" ];

    environment.systemPackages = with pkgs; [
        cosmic-bg
        cosmic-ext-ctl
        wireguard-tools
        protonvpn-gui
    ];

    networking.firewall.checkReversePath = false;

    boot.loader.grub.useOSProber = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "mindgame";
    system.stateVersion = "25.05";
}
