{ pkgs, lib, ... }: {
    imports = [
        ./hardware-marvin.nix
        ../archetype/personal.nix
        ../modules/display-manager.nix
        ../modules/desktop-environment.nix
        ../modules/user-definitions.nix
    ];

    personal.enable = true;

    user-definitions.ajlow.enable = true;
    
    display-manager.enable = lib.mkForce false;
    # desktop-environment.enable = lib.mkForce false;

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "mydatabase" ];
        authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
        '';
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "marvin"; # Define your hostname.

    boot.kernelPackages = pkgs.linuxPackages_latest;

    #networking.firewall.allowedTCPPorts = [ ... ];
    #networking.firewall.allowedUDPPorts = [ ... ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
}
