{ config, pkgs, inputs, ... }: {
    home.packages = with pkgs; ([
        wl-clipboard
    ]);

    home.file = {
        hyprland = {
            recursive = true;
            source = ../../dotfiles/hypr;
            target = "./.config/hypr";
        };
        waybar = {
            recursive = true;
            source = ../../dotfiles/waybar;
            target = "./.config/waybar";
        };
    };
}
