{ config, lib, pkgs, inputs, ... }:
let 
    inherit (inputs) toolbox;
    cfg = config.pde;
in {
    options = {
        pde.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        programs = {
            direnv = {
                enable = true;
                enableZshIntegration = true;
                nix-direnv.enable = true;
            };
        };

        home.packages = with pkgs; ([
            ### PDE
            neovim
            tmux
            zellij
            zsh
            delta
            zoxide
            kitty
            hack-font
            lf
            gh
            ( nerdfonts.override { fonts = [ "FiraCode" "Meslo"]; } )

            jq
            gnumake
            bat
            git
            fzf
            ripgrep
            gnugrep
            mercurial
            darcs
            subversion
            xclip
            unixtools.xxd
            gum
            glow
            fd
            sd
            htop
            eza

            openssh
            unzip
            util-linux
            lsb-release
            usbutils
            pciutils
            rsync
            interception-tools
            gnupatch
            bzip2
            gnupg

            bitwarden-cli
            bottom
            hyperfine
            nmap
            arp-scan
            tokei

            ### Global Language Support
            asm-lsp
            lua-language-server
            nodePackages_latest.bash-language-server
            gcc
            # llvmPackages_9.clang-unwrapped
        ] ++ [
            toolbox.packages.${system}.print-path
            toolbox.packages.${system}.audit-dir
            toolbox.packages.${system}.add-repo
            toolbox.packages.${system}.conventional-commit
        ]);

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
            zellij = {
                recursive = true;
                source = ../dotfiles/zellij;
                target = "./.config/zellij";
            };
            git = {
                recursive = true;
                source = ../dotfiles/git;
                target = "./.config/git";
            };
            zsh = {
                recursive = false;
                source = ../dotfiles/zsh/zshrc;
                target = "./.zshrc";
            };
            scripts = {
                recursive = false;
                source = ../dotfiles/scripts;
                target = "./.local/bin";
            };
        };

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
    };
}
