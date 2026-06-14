{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  cfg = config.profiles.user.server;
  isStandalone = osConfig == null;
in
{
  imports = [
    ../modules/pde.nix
    ../modules/env.nix
    ../modules/ssh-identity.nix
    ../modules/git-cloner.nix
    ../modules/sops-identity.nix
  ];

  options.profiles.user.server = {
    enable = lib.mkEnableOption "server user profile";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = lib.mkIf isStandalone {
      allowUnfreePredicate = _: true;
    };

    pde.enable = true;
    env.enable = true;

    ssh-identity.enable = true;
    git-cloner.enable = true;
    sops-identity.enable = true;
    git-cloner.repos = [
      # Server repos (e.g. deployment configs) go here.
    ];

    programs.home-manager.enable = true;
  };
}
