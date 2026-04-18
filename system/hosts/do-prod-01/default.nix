{ lib, ... }: {
    imports = [
        ../../profiles/digital-ocean.nix
    ];

    profiles.system.digital-ocean.enable = true;

    # DO minimum custom image size is 20 GiB
    virtualisation.diskSize = 20 * 1024;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    system.stateVersion = "25.05";
}
