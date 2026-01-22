{config, lib, ... }:
let 
    cfg = config.personal_user;
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

    options = {
        personal_user.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        nixpkgs.config.allowUnfreePredicate = _: true;


        pde.enable = true;
        env.enable = true;
        gui_utilities.enable = true;
        personal.enable = true;
        de.enable = true;
        minecraft.enable = true;
        hytale.enable = true;

        dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
                autoconnect = ["qemu:///system"];
                uris = ["qemu:///system"];
            };
        };

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
    };
}
