{ config, pkgs, inputs, ... }: {
    home.packages = with pkgs; ([
        firefox
        evince
        krita
        gimp
        inkscape
        discord
        wireshark
    ]);
}
