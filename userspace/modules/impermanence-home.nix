{
  config,
  lib,
  ...
}:
let
  cfg = config.impermanence-home;
in
{
  options.impermanence-home = {
    enable = lib.mkEnableOption "home-manager persistence under /persist";

    persistRoot = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = ''
        Backing storage root. The home path is appended automatically by
        impermanence (so "/persist" maps to "/persist/home/<user>").
      '';
    };

    extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = "Extra directories to persist beyond the defaults.";
    };

    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = "Extra files to persist beyond the defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.persistence.${cfg.persistRoot} = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Music"
        "Desktop"
        "repos"

        ".local/share/atuin"
        ".local/share/zoxide"
        ".local/share/direnv"
        ".local/share/zsh"
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/share/zellij"
        ".cache/nix"
        ".local/share/nix"

        ".local/share/containers"
        ".docker"
        ".cargo"
        ".rustup"

        ".mozilla"
        ".config/google-chrome"
        ".config/chromium"
        ".config/BraveSoftware"

        ".config/discord"
        ".config/Signal"
        ".local/share/Signal"

        ".local/share/Steam"
        ".steam"
        ".local/share/lutris"
        ".local/share/PrismLauncher"
        ".config/heroic"

        ".local/share/keyrings"
        ".gnupg"
        ".password-store"

        ".config/cosmic"
        ".local/state/cosmic"
        ".config/dconf"

        ".config/gh"
      ] ++ cfg.extraDirectories;

      files = [
        ".bash_history"
        ".zsh_history"
      ] ++ cfg.extraFiles;
    };
  };
}
