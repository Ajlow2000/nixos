{ config, pkgs, ... }:
{
    home.username = "ajlow";
    home.homeDirectory = "/home/ajlow";

    nixpkgs.config.allowUnfreePredicate = _: true;
    
    programs = {
        direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
        };
    };

    home.packages = with pkgs; [
        ### PDE
        neovim
        tmux
        zsh
        git
        lf
        fzf
        ripgrep
        gnugrep
        delta
        gum
        lazygit
        zoxide
        glow
        firefox
        kitty
        gnumake
        just
        mercurial
        darcs
        subversion
        wl-clipboard
        xclip
        unixtools.xxd
        hack-font
        ( nerdfonts.override { fonts = [ "FiraCode" "Meslo"]; } )

        ### Utils
        util-linux
        openssh
        lsb-release
        fd
        sd
        htop
        neofetch
        unzip
        eza
        bottom
        fd
        hyperfine
        nmap
        interception-tools
        rsync
        gnupatch
        bzip2

        ### Language Support
        texlive.combined.scheme-full
        typst
        rustup
        #opam
        nixd
        gopls
        go
        nixd
        lua-language-server
        nodePackages_latest.bash-language-server
        jdk11
        nodejs_20
        gcc

        ### Misc
        krita
        gimp
        inkscape
        discord
    ];


    xdg.desktopEntries = {
        kitty-tmux = {
            name = "Kitty (Tmux)";
            genericName = "Terminal Emulator";
            exec = "kitty tmux-session-manager";
            terminal = false;
            categories = [ "System" "TerminalEmulator" ];
            icon = "kitty";
        };
    };

    home.file = {
        neovim = {
            recursive = true;
            source = ../dotfiles/nvim;
            target = "./.config/nvim";
        };
        kitty = {
            recursive = true;
            source = ../dotfiles/kitty;
            target = "./.config/kitty";
        };
        tmux = {
            source = ../dotfiles/tmux/tmux.conf;
            target = "./.tmux.conf";
        };
        hyprland = {
            recursive = true;
            source = ../dotfiles/hypr;
            target = "./.config/hypr";
        };
        waybar = {
            recursive = true;
            source = ../dotfiles/waybar;
            target = "./.config/waybar";
        };
        git = {
            recursive = true;
            source = ../dotfiles/git;
            target = "./.config/git";
        };
        scripts = {
            recursive = false;
            source = ../scripts;
            target = "./.local/bin";
        };
        zsh = {
            recursive = false;
            source = ../dotfiles/zsh/zshrc;
            target = "./.zshrc";
        };
    };

    home.sessionVariables = {
        EDITOR = "nvim";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
        XDG_DESKTOP_DIR="$HOME/desktop";
        XDG_DOWNLOAD_DIR="$HOME/downloads";

        AJLOW_OCAML_TOOLS="dune merlin ocaml-lsp-server odoc ocamlformat utop
        dune-release core core_unix base";
    };

    home.sessionPath = [
        "$XDG_BIN_HOME"
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
