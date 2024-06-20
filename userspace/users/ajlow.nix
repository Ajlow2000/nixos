{ config, pkgs, inputs, ... }: {
    imports = [
        ../archetype/personal_user.nix
    ];

    home.username = "ajlow";
    home.homeDirectory = "/home/ajlow";
}
