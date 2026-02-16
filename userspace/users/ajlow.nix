{ pkgs, ... }: {
    imports = [
        ../profiles/personal.nix
    ];

    # Enable personal user profile
    profiles.user.personal.enable = true;

    # User-specific settings
    home.username = "ajlow";
    home.homeDirectory = if pkgs.stdenv.isDarwin
        then "/Users/ajlow"
        else "/home/ajlow";
    home.stateVersion = "22.11";
}
