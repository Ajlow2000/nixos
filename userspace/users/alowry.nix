{ config, pkgs, inputs, ... }:
let inherit (inputs) toolbox;
in {
    imports = [
        ../profiles/work.nix
    ];

    # Enable work user profile
    profiles.user.work.enable = true;

    # User-specific settings
    home.username = "alowry";
    home.homeDirectory = if pkgs.stdenv.isDarwin
        then "/Users/alowry"
        else "/home/alowry";
    home.stateVersion = "22.11";
}
