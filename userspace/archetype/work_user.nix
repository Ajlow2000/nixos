{ config, pkgs, inputs, ... }: {
    nixpkgs.config.allowUnfreePredicate = _: true;

    imports = [
        ../modules/pde.nix
        ../modules/env.nix
        ../modules/gui_utilities.nix
        ../modules/work.nix
        ../modules/de.nix
    ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "22.11"; # Please read the comment before changing.

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}
