{ config, pkgs, ... }:

{
    imports = [
        ./hardware-multivac.nix
        "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
        ./disko-multivac.nix
        ../archetype/personal.nix
    ];

    personal.enable = true;

    disko.devices.disk.main.device = "/dev/sda";

    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;

    networking.hostName = "multivac";


    networking.firewall.allowedTCPPorts = [ 22 ];
    #networking.firewall.allowedUDPPorts = [ ... ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
}
