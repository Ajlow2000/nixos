{ pkgs, lib, ... }: {
    imports = [
        ./hardware-mindgame.nix
        ../archetype/personal.nix
        ../modules/display-manager.nix
        ../modules/desktop-environment.nix
    ];

    personal.enable = true;
    
    display-manager.enable = lib.mkForce false;
    # desktop-environment.enable = lib.mkForce false;

    # powerManagement.cpuFreqGovernor = "powersave";

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
        cosmic-bg
        cosmic-ext-ctl
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "mindgame"; # Define your hostname.

    boot.kernelPackages = pkgs.linuxPackages_latest;

    #networking.firewall.allowedTCPPorts = [ ... ];
    #networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "25.05";
}
