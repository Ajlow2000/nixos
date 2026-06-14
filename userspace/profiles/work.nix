{
  config,
  pkgs,
  lib,
  osConfig ? null,
  ...
}:
let
  cfg = config.profiles.user.work;
  # Only set nixpkgs config when running standalone (not as NixOS module)
  isStandalone = osConfig == null;
  hostHasImpermanence =
    (osConfig.modules.impermanence.persistence.enable or false);
in
{
  imports = [
    ../modules/pde.nix
    ../modules/env.nix
    ../modules/gui_utilities.nix
    ../modules/work.nix
    ../modules/de.nix
    ../modules/easyeffects.nix
    ../modules/ssh-identity.nix
    ../modules/impermanence-home.nix
    ../modules/git-cloner.nix
    ../modules/sops-identity.nix
  ];

  options.profiles.user.work = {
    enable = lib.mkEnableOption "work user profile";
  };

  config = lib.mkIf cfg.enable {
    # Only set allowUnfree when running standalone (for non-NixOS systems)
    nixpkgs.config = lib.mkIf isStandalone {
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [ "ventoy-1.1.12" ];
    };

    # Enable modules (with de conditional on Linux)
    pde.enable = true;
    env.enable = true;
    gui_utilities.enable = true;
    de.enable = pkgs.stdenv.isLinux;
    easyeffects.enable = pkgs.stdenv.isLinux;

    ssh-identity.enable = true;
    impermanence-home.enable = hostHasImpermanence;
    git-cloner.enable = true;
    sops-identity.enable = true;
    git-cloner.repos = [
      # Work repos go here. Set per-host or per-profile.
    ];

    # Let Home Manager install and manage itself
    programs.home-manager.enable = true;
  };
}
