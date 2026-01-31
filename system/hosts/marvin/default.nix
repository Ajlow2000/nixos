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

    profiles.system.laptop.enable = true;

    modules.desktop.cosmic.enable = true;

    modules.desktop.display-manager.enable = lib.mkForce false;

    modules.services.gaming.enable = true;

    user-definitions.ajlow.enable = true;

    modules.services.virtualization.users = [ "ajlow" ];

    modules.work.sram-udev.enable = true;
    modules.work.sentinelone = {
        enable = true;
        email = "alowry@sram.com";
        serialNumber = "DPR8SQ3";
        tokenPath = /etc/nixos/sentinelOne.token;
        packageSource = /etc/nixos/SentinelAgent_linux_x86_64_v24_3_3_6.deb;
    };

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "mydatabase" ];
        authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
        '';
    };

    environment.systemPackages = with pkgs; [
        cosmic-bg
        cosmic-ext-ctl
        wireguard-tools
        protonvpn-gui
    ];

    networking.firewall.checkReversePath = false;

    boot.blacklistedKernelModules = [ "nouveau" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "marvin";
    system.stateVersion = "24.05";
}
