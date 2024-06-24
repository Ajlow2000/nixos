{ ... }: {
    imports = [
        ../archetype/personal_user.nix
    ];

    personal_user.enable = true;

    home.username = "ajlow";
    home.homeDirectory = "/home/ajlow";
}
