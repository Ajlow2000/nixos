{ config, lib, pkgs, inputs, ... }:
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
            zoom-us
            firefox
            inkscape
            wireshark
            discord
            spotify
            element-desktop
            signal-desktop
            anki
        ] ++ lib.optionals stdenv.isLinux [
            # Linux-only GUI apps
            ghidra
            gimp
            krita
            zathura
            microsoft-edge
            evince
            teams-for-linux
        ]);
    };
}
