{ pkgs, ... }: {
    imports = [
        ../archetype/personal_user.nix
    ];

    personal_user.enable = true;

    home.username = "ajlow";
    home.homeDirectory = if pkgs.stdenv.isDarwin
        then "/Users/ajlow"
        else "/home/ajlow";
}
