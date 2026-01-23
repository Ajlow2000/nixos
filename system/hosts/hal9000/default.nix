{ pkgs, lib, inputs, ... }: {
    imports = [
        ./hardware.nix
        ../../profiles/desktop.nix
        ../../modules/desktop/gnome.nix
        ../../modules/desktop/display-manager.nix
        ../../modules/services/gaming.nix
        ../../modules/user-definitions.nix
    ];

    # Enable desktop profile
    profiles.system.desktop.enable = true;

    # Enable GNOME desktop environment
    modules.desktop.gnome.enable = true;
    modules.desktop.display-manager.enable = true;

    # Enable gaming (Steam)
    modules.services.gaming.enable = true;

    # Enable user definitions
    user-definitions.ajlow.enable = true;

    # Enable virtualization for ajlow user
    modules.services.virtualization.users = [ "ajlow" ];

    # AMD Graphics (RADV is enabled by default, no extra configuration needed)

    # Personal networking (VPN and SSH)
    networking.firewall.checkReversePath = false;
    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = with pkgs; [
        wireguard-tools
        protonvpn-gui
    ];

    # Bootloader
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/nvme0n1";
    boot.loader.grub.useOSProber = true;

    # Host-specific settings
    networking.hostName = "hal9000";
    system.stateVersion = "24.05";
}
