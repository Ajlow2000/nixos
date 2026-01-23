{ config, pkgs, lib, osConfig ? null, ... }:
let
    cfg = config.profiles.user.work;
    # Only set nixpkgs config when running standalone (not as NixOS module)
    isStandalone = osConfig == null;
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
        # Only set allowUnfree when running standalone (for non-NixOS systems)
        nixpkgs.config = lib.mkIf isStandalone {
            allowUnfreePredicate = _: true;
        };

        # Enable modules (with de conditional on Linux)
        pde.enable = true;
        env.enable = true;
        gui_utilities.enable = true;
        de.enable = pkgs.stdenv.isLinux;

        # Let Home Manager install and manage itself
        programs.home-manager.enable = true;
    };
}
