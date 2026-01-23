{ config, pkgs, lib, ... }:
let
    cfg = config.profiles.user.work;
in {
    imports = [
        ../modules/pde.nix
        ../modules/env.nix
        ../modules/gui_utilities.nix
        ../modules/work.nix
        ../modules/de.nix
    ];

    options.profiles.user.work = {
        enable = lib.mkEnableOption "work user profile";
    };

    config = lib.mkIf cfg.enable {
        nixpkgs.config.allowUnfreePredicate = _: true;

        # Enable modules (with de conditional on Linux)
        pde.enable = true;
        env.enable = true;
        gui_utilities.enable = true;
        de.enable = pkgs.stdenv.isLinux;

        # Let Home Manager install and manage itself
        programs.home-manager.enable = true;
    };
}
