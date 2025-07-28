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
            (runCommand "nvim-nightly" {} ''
                mkdir -p $out/bin
                ln -s ${inputs.neovim-nightly-overlay.packages.${system}.default}/bin/nvim $out/bin/nvim-nightly
            '')
            tmux
            zellij
            neovim-remote
            zsh
            delta
            zoxide
            kitty
            ghostty
            hack-font
            lf
            xplr
            yazi
            gh
            nerd-fonts.fira-code
            nerd-fonts.meslo-lg

            jq
            gnumake
            bat
            git
            pijul
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
            tealdeer
            gh-dash
            realvnc-vnc-viewer

            openssh
            zip
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
            dig
            whois

            gdb
            bitwarden-cli
            hyperfine
            nmap
            arp-scan
            tokei
            binwalk
            bandwhich
            atuin
            csvlens
            dua
            claude-code
            bottom

            ### Global Language Support
            asm-lsp
            lua-language-server
            nodePackages_latest.bash-language-server
            rust-analyzer
            nil
            marksman
            gcc

            moreutils # only necessary to provide vipe until nix build of conventional-commit is working
        ] ++ [
            toolbox.packages.${system}.print-path
            toolbox.packages.${system}.audit-dir
            toolbox.packages.${system}.repo-manager
            toolbox.packages.${system}.conventional-commit
            toolbox.packages.${system}.tmux-session-manager
            toolbox.packages.${system}.zellij-session-manager
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
            atuin = {
                source = ../dotfiles/atuin;
                target = "./.config/atuin";
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
            repo-manager = {
                recursive = true;
                source = ../dotfiles/repo-manager;
                target = "./.config/repo-manager";
            };
            scripts = {
                recursive = false;
                source = ../dotfiles/scripts;
                target = "./.local/bin";
            };
        };

        xdg.desktopEntries = {
            win11 = {
                name = "Windows11 VM";
                genericName = "VM";
                exec = "virt-manager --connect qemu:///system --show-domain-console win11";
                categories = [ "System" ];
            };
        };
    };
}
