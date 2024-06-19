{ config, pkgs, ... }: {
    imports = [
        ./work.nix
        ../modules/user-definitions.nix
        ../modules/gaming.nix
    ];
}
