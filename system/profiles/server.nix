{
  config,
  pkgs,
  lib,
  keys,
  ...
}:
let
  cfg = config.profiles.system.server;
in
{
  imports = [
    ./base.nix
  ];

  options.profiles.system.server = {
    enable = lib.mkEnableOption "headless bare-metal server configuration";
  };

  config = lib.mkIf cfg.enable {
    profiles.system.base.enable = true;

    users.users.ajlow = {
      isNormalUser = true;
      description = "Alec Lowry";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = builtins.attrValues keys.personal;
    };

    security.sudo.wheelNeedsPassword = false;
  };
}
