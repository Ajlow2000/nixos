{ config, pkgs, ... }:
{
    home.username = "ajlow";
    home.homeDirectory = "/home/ajlow";

    imports = [
        ../configurations/zsh.nix
    ];

    home.packages = with pkgs; [
        neovim
        tmux
	git
        openssh
        lf
        fzf
        delta
        fd
        sd
        gum
        htop
        circumflex
        lazygit
        neofetch
        cbonsai
        fd
        ripgrep
        unzip
        exa # switch to eza
        bottom
        fd
        hyperfine
        atuin # setup
        zoxide
        gnugrep
        firefox
        kitty
        typst
        nmap
        interception-tools
        rustup
        opam
        nixd
        gopls
        go
        nixd
        lua-language-server
        nodePackages_latest.bash-language-server
        jdk11
        nodejs_20
        gcc
        gnumake
        just
        gnupatch
        rsync
        bzip2
        mercurial
        darcs
        subversion
        unixtools.xxd
        hack-font
        ( nerdfonts.override { fonts = [ "FiraCode" "Meslo"]; } )
        wl-clipboard
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

    home.shellAliases = {
        gs = "git status";
        ls = "exa";
        # cd = "z";
        grep = "grep --color=auto";
        ncu = "sudo nix-channel --update";
        hms = "home-manager switch --flake $XDG_CONFIG_HOME/home-manager/#$USER";
        nrs = "sudo nixos-rebuild switch --flake $XDG_CONFIG_HOME/nixos/#$NIXOS_CONFIG_PROFILE";
        tsm = "tmux-session-manager";
        gcm = "conventional-commit";
        path = "echo $PATH | tr : '\n'";
        kitty-tmux = "kitty tmux-session-manager home";
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
        # wallpaper = {
        #     recursive = true;
        #     source = ../dotfiles/wallpaper;
        #     target = "./.config/wallpaper";
        # };
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
