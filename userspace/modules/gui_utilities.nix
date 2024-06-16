{ config, pkgs, inputs, ... }: {
    home.packages = with pkgs; ([
        firefox
        evince
        krita
        gimp
        inkscape
        wireshark
        discord
        spotify
    ]);
}
