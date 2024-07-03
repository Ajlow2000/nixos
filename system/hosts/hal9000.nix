{pkgs, ... }: {

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    imports = [
        ./hardware-hal9000.nix
        ../archetype/personal.nix
    ];

    personal.enable = true;

    # Bootloader.
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/nvme0n1";
    boot.loader.grub.useOSProber = true;

    networking.hostName = "hal9000"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    hardware.opengl = {
        ## radv: an open-source Vulkan driver from freedesktop
        #driSupport = true;
        driSupport32Bit = true;

        ## amdvlk: an open-source Vulkan driver from AMD
        extraPackages = [ pkgs.amdvlk ];
        extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
    };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
}
