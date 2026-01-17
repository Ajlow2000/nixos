{ config, lib, pkgs, ... }:
let 
    cfg = config.personal;
in {
    imports = [
        ./work.nix
        ../modules/user-definitions.nix
        ../modules/gaming.nix
    ];

    options = {
        personal.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        work.enable = true;
        user-definitions.ajlow.enable = true;
        gaming.enable = true;

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

        fonts.fontconfig.defaultFonts = {
            monospace = [ "Hack Nerd Font" "Noto Sans Mono CJK SC" ];
        };

        # # Force Wayland apps to recognize the Input Method
        # environment.sessionVariables = {
        #     XMODIFIERS = "@im=fcitx";
        #     QT_IM_MODULE = "fcitx";
        #     GTK_IM_MODULE = "fcitx";
        #     # Some Rust/COSMIC apps need this specifically:
        #     CLUTTER_IM_MODULE = "fcitx";
        #     GLFW_IM_MODULE = "ibus"; # Fcitx5 emulates the ibus protocol for GLFW/Rust apps
        # };

        networking.firewall.checkReversePath = false;
        environment.systemPackages = with pkgs; [
            wireguard-tools 
            protonvpn-gui
        ];
    };
}
