{ pkgs, lib, inputs, ... }: {
    imports = [
        ./hardware.nix
        ../../profiles/desktop.nix
        ../../modules/desktop/cosmic.nix
        ../../modules/desktop/display-manager.nix
        ../../modules/services/gaming.nix
        ../../modules/user-definitions.nix
    ];

    # Enable desktop profile
    profiles.system.desktop.enable = true;

    # Enable COSMIC desktop environment
    modules.desktop.cosmic.enable = true;

    # Disable LightDM since COSMIC has its own greeter
    modules.desktop.display-manager.enable = lib.mkForce false;

    # Enable gaming (Steam)
    modules.services.gaming.enable = true;

    # Enable user definitions
    user-definitions.ajlow.enable = true;

    # Enable virtualization for ajlow user
    modules.services.virtualization.users = [ "ajlow" ];

    # COSMIC packages
    environment.systemPackages = with pkgs; [
        cosmic-bg
        cosmic-ext-ctl
        wireguard-tools
        protonvpn-gui
    ];

    # Personal networking (VPN)
    networking.firewall.checkReversePath = false;

    # Bootloader
    boot.loader.grub.useOSProber = true;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Host-specific settings
    networking.hostName = "mindgame";
    system.stateVersion = "25.05";
}
