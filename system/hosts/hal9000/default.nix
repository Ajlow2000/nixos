{ pkgs, lib, inputs, ... }: {
    imports = [
        ./hardware.nix
        ../../profiles/desktop.nix
        ../../modules/desktop/gnome.nix
        ../../modules/desktop/display-manager.nix
        ../../modules/services/gaming.nix
        ../../modules/user-definitions.nix
    ];

    profiles.system.desktop.enable = true;

    modules.desktop.gnome.enable = true;
    modules.desktop.display-manager.enable = true;

    modules.services.gaming.enable = true;

    user-definitions.ajlow.enable = true;

    modules.services.virtualization.users = [ "ajlow" ];

    networking.firewall.checkReversePath = false;
    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = with pkgs; [
        wireguard-tools
        protonvpn-gui
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/nvme0n1";
    boot.loader.grub.useOSProber = true;

    networking.hostName = "hal9000";
    system.stateVersion = "24.05";
}
