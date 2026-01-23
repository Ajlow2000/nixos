{ pkgs, lib, inputs, ... }: {
    imports = [
        ./hardware.nix
        ../../profiles/laptop.nix
        ../../modules/desktop/cosmic.nix
        ../../modules/desktop/display-manager.nix
        ../../modules/services/gaming.nix
        ../../modules/work/sram-udev.nix
        ../../modules/work/sentinelone.nix
        ../../modules/user-definitions.nix
    ];

    # Enable laptop profile (includes desktop and base)
    profiles.system.laptop.enable = true;

    # Enable COSMIC desktop environment
    modules.desktop.cosmic.enable = true;

    # Disable LightDM since COSMIC has its own greeter
    modules.desktop.display-manager.enable = lib.mkForce false;

    # Enable gaming (Steam)
    modules.services.gaming.enable = true;

    # Enable user definitions (work user)
    user-definitions.ajlow.enable = true;

    # Enable virtualization for ajlow user
    modules.services.virtualization.users = [ "ajlow" ];

    # Work-specific modules
    modules.work.sram-udev.enable = true;
    modules.work.sentinelone = {
        enable = true;
        email = "alowry@sram.com";
        serialNumber = "DPR8SQ3";
        tokenPath = /etc/nixos/sentinelOne.token;
        packageSource = /etc/nixos/SentinelAgent_linux_x86_64_v24_3_3_6.deb;
    };

    # PostgreSQL for work
    services.postgresql = {
        enable = true;
        ensureDatabases = [ "mydatabase" ];
        authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
        '';
    };

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
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Host-specific settings
    networking.hostName = "marvin";
    system.stateVersion = "24.05";
}
