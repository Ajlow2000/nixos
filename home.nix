{ config, pkgs, ... }: {
    # imports = [
    #     ./user_packages.nix
    # ];

    home.username = "ajlow";
    home.homeDirectory = "/home/ajlow";

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
        ".config/nvim/init.lua".source = ./dotfiles/nvim/init.lua;
    };

    home.sessionPath = [
        "$HOME/.local/bin"
    ];

    home.packages = with pkgs; [
        neovim
        tmux
        nmap
        neofetch
        kitty
        firefox
        rustup
        ripgrep
        gnugrep
        exa
        zoxide
        fzf
        lf
        xplr
    ];

    home.shellAliases = {
        gs = "git status";
        ls = "exa";
        # cd = "z";
        p = "tmux-session-wizard";
        grep = "grep --color=auto";
        hms = "home-manager switch --flake $XDG_CONFIG_HOME/flakes/home-manager/#$USER";
        nrs = "sudo nixos-rebuild switch --flake $XDG_CONFIG_HOME/flakes/nixos/#$NIXOS_CONFIG_PROFILE";
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        zplug = {
            enable = true;
            plugins = [
                { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; }
            ];
        };
        localVariables = {
            POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
        };
    };

    programs.git = {
        enable = true;
        userName = "Ajlow2000";
        userEmail = "ajlow2000@gmail.com";
        aliases = {
            cm = "commit -m";
            plog = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
    };

    # TODO default apps
    # xdg.mimeApps.defaultApplications

    # You can also manage environment variables but you will have to manually
    # source
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/ajlow/etc/profile.d/hm-session-vars.sh
    #
    # if you don't want to manage your shell through Home Manager.
    home.sessionVariables = {
        EDITOR = "neovim";
        
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "23.05"; # Please read the comment before changing.
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}
