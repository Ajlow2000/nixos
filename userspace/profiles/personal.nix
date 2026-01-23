{ config, lib, pkgs, ... }:
let
    cfg = config.profiles.user.personal;
in {
    imports = [
        ../modules/pde.nix
        ../modules/env.nix
        ../modules/gui_utilities.nix
        ../modules/personal.nix
        ../modules/de.nix
        ../modules/minecraft.nix
        ../modules/hytale.nix
    ];

    options.profiles.user.personal = {
        enable = lib.mkEnableOption "personal user profile";
    };

    config = lib.mkIf cfg.enable {
        nixpkgs.config.allowUnfreePredicate = _: true;

        # Enable all personal modules
        pde.enable = true;
        env.enable = true;
        gui_utilities.enable = true;
        personal.enable = true;
        de.enable = pkgs.stdenv.isLinux;
        minecraft.enable = true;
        hytale.enable = true;

        # Virt-manager dconf settings (Linux only)
        dconf.settings = lib.mkIf pkgs.stdenv.isLinux {
            "org/virt-manager/virt-manager/connections" = {
                autoconnect = ["qemu:///system"];
                uris = ["qemu:///system"];
            };
        };

        # Let Home Manager install and manage itself
        programs.home-manager.enable = true;
    };
}
