{ config, pkgs, ... }:

{
    imports =
        [
        ./hardware-multivac.nix
        ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nix.settings.auto-optimise-store = true;

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 60d";
    };

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "multivac";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    services.blueman.enable = true;

    # Set your time zone.
    time.timeZone = "America/Denver";

    # Select internationalisation properties.
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

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.xserver.displayManager = {
        sddm.enable = true;
        sddm.theme = "${import ./sddm-multivac/sddm-theme.nix { inherit pkgs; }}";
    };

    # hyprland
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    # Enable the GNOME Desktop Environment.
    # services.xserver.desktopManager.gnome.enable = true;

    # Configure keymap in X11
    services.xserver = {
        layout = "us";
        xkbVariant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    hardware.brillo.enable = true;

    # Enable sound with pipewire.
    services.pipewire.wireplumber.enable = true;
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

    programs.zsh.enable = true;

    users.users.ajlow = {
        isNormalUser = true;
        description = "Alec Lowry";
        shell = pkgs.zsh;
        extraGroups = [ "networkmanager" "wheel" "video" ];
    };

    # Looking for a ctrl as modifier and esc as key function
    # https://discourse.nixos.org/t/troubleshooting-help-services-interception-tools/20389/4
    # https://ansonvandoren.com/posts/capslock-linux-redux/
    # https://github.com/NixOS/nixpkgs/issues/126681
    # 
    # services.interception-tools = {
    #     enable = true;
    #     plugins = with pkgs; [
    #         interception-tools-plugins.caps2esc
    #     ];
    #     udevmonConfig = ''
    #         - JOB:
    #         "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
    #             DEVICE:
    #                 EVENTS:
    #                     EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    #     '';
    # };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        neovim
        git
        wget
        curl
        firefox
        kitty
        tmux
        home-manager
        libsForQt5.qt5.qtquickcontrols2
        libsForQt5.qt5.qtgraphicaleffects
        interception-tools
        wofi
        (waybar.overrideAttrs (oldAttrs: {
                    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
                })
        )
        swww
        mako
        libnotify
        wl-clipboard
        networkmanagerapplet
    ];

    environment.sessionVariables = rec {
        EDITOR = "nvim";

        NIXOS_CONFIG_PROFILE = "workstation";	# Used to dynamically determine configuration profile in home manager

        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
        PATH = [ "${XDG_BIN_HOME}" ];
    };

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?

}
