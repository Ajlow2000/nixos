{ config, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nix.settings.auto-optimise-store = true;
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
        neovim
        git
        wget
        curl
        firefox
        home-manager
    ];

    environment.sessionVariables = rec {
        EDITOR = "nvim";

        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification

        PATH = [ "${XDG_BIN_HOME}" ];
    };

    time.timeZone = "America/Denver";

    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    networking.networkmanager.enable = true;

    services.openssh.enable = true;
}
