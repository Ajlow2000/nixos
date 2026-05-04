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

    programs.home-manager.enable = true;
  };
}
