{ config, lib, pkgs, ... }:
let
    cfg = config.profiles.system.base;
in {
    imports = [
        # ../modules/services/netbird-agent.nix
    ];

    options.profiles.system.base = {
        enable = lib.mkEnableOption "base system configuration";
    };

    config = lib.mkIf cfg.enable {
        # modules.services.netbird-agent.enable = true;

        services.netbird.enable = true; # for netbird service & CLI
        systemd.services.${config.services.netbird.clients.default.service.name}.path = [ pkgs.shadow ]; # https://github.com/NixOS/nixpkgs/issues/505846
        # systemd.services.netbird.environment.PATH = lib.mkForce "/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";

        nixpkgs.config.allowUnfree = true;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.settings.auto-optimise-store = true;
        nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
        };

        programs.zsh.enable = true;
        programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
            gcc
            stdenv.cc.cc
            clang
        ];

        environment.systemPackages = with pkgs; [
            neovim
            git
            wget
            curl
            home-manager
            coreutils
            inetutils
            docker-compose
            killall
            parted
        ];

        environment.sessionVariables = rec {
            EDITOR = "nvim";
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";
            XDG_BIN_HOME = "$HOME/.local/bin";
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

        services.udev.extraRules = ''
            SUBSYSTEM=="usb", ATTR{idVendor}=="303a", MODE="0660", GROUP="dialout"
            KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess"
        '';

        networking.networkmanager.enable = true;
        services.openssh.enable = true;

        # Redirect port 22 on the Netbird interface (wt0) to Netbird's built-in
        # SSH server on port 22022, so `netbird ssh` works while system sshd
        # continues to handle port 22 on all other interfaces normally.
        # Note: 22022 is where Netbird SSH lands when sshd already holds port 22.
        # If this ever breaks, verify the port with: ss -tlnp | grep :22022
        networking.firewall.extraCommands = ''
            iptables -t nat -A PREROUTING -i wt0 -p tcp --dport 22 -j REDIRECT --to-port 22022
        '';
        networking.firewall.extraStopCommands = ''
            iptables -t nat -D PREROUTING -i wt0 -p tcp --dport 22 -j REDIRECT --to-port 22022 || true
        '';
    };
}
