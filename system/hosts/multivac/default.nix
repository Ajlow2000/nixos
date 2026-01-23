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

    # Personal networking (VPN and SSH)
    networking.firewall.checkReversePath = false;
    networking.firewall.allowedTCPPorts = [ 22 ];

    environment.systemPackages = with pkgs; [
        wireguard-tools
        protonvpn-gui
    ];

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Host-specific settings
    networking.hostName = "multivac";
    system.stateVersion = "24.05";
}
