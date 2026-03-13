{ config, lib, pkgs, inputs, system, ... }:
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
        ] ++ lib.optionals stdenv.isLinux [
            # Linux-only GUI apps
            zoom-us
            firefox
            inkscape
            wireshark
            discord
            spotify
            element-desktop
            anki
            signal-desktop
            ghidra
            inputs.nix-binary-ninja.packages.${system}.binary-ninja-free-wayland
            gimp
            krita
            zathura
            microsoft-edge
            evince
            teams-for-linux
            chromium
            godot
        ]);
    };
}
