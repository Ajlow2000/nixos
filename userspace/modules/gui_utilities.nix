{ config, lib, pkgs, ... }:
let 
    cfg = config.gui_utilities;
in {
    options = {
        gui_utilities.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; ([
            firefox
            evince
            krita
            gimp
            inkscape
            wireshark
            discord
            spotify
            teams-for-linux
        ]);
    };
}
