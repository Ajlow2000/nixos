{ config, lib, pkgs, ... }:
let
    cfg = config.mandarin;
in {
    options = {
        mandarin.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Mandarin Chinese language support with fcitx5 input method and CJK fonts";
        };
    };

    config = lib.mkIf cfg.enable {
        i18n.supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "zh_CN.UTF-8/UTF-8" # Simplified Chinese
            "zh_TW.UTF-8/UTF-8" # Traditional Chinese (optional)
        ];

        i18n.inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5.waylandFrontend = true; # Crucial for native Wayland apps
            fcitx5.addons = with pkgs; [
                qt6Packages.fcitx5-chinese-addons # Contains the Pinyin engine
                fcitx5-gtk            # For GTK apps (Chrome, etc.)
                fcitx5-m17n
                fcitx5-rime           # Alternative: RIME (highly customizable)
                # fcitx5-chewing      # For Traditional Chinese (optional)
            ];
        };

        fonts.packages = with pkgs; [
            nerd-fonts.hack
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            wqy_microhei  # Popular compact Chinese font
            wqy_zenhei
        ];

        environment.sessionVariables = {
            XMODIFIERS = "@im=fcitx";
        };

        fonts.fontconfig.defaultFonts = {
            monospace = [ "Hack Nerd Font" "Noto Sans Mono CJK SC" ];
        };
    };
}
