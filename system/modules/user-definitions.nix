{
  config,
  lib,
  pkgs,
  inputs,
  keys,
  ...
}:
let
  cfg = config.user-definitions;
in
{
  options = {
    user-definitions.ajlow.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    user-definitions.ajlow.profile = lib.mkOption {
      type = lib.types.enum [
        "personal"
        "work"
        "server"
      ];
      default = "personal";
      description = "Which home-manager profile to use for ajlow";
    };

  };

  config = lib.mkMerge [
    (lib.mkIf cfg.ajlow.enable {
      users.users.ajlow = {
        isNormalUser = true;
        description = "Alec Lowry";
        extraGroups = [
          "networkmanager"
          "wheel"
          "wireshark"
          "docker"
          "dialout"
          "plugdev"
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [ keys.ajlow ];
        hashedPasswordFile = lib.mkIf config.modules.sops.enable config.sops.secrets."ajlow-passwd".path;
      };

      modules.sops.users = lib.mkIf config.modules.sops.enable [ "ajlow" ];

      # Home Manager integration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit inputs keys;
          system = pkgs.stdenv.hostPlatform.system;
        };
        users.ajlow = import (../../userspace/users + "/ajlow-${cfg.ajlow.profile}.nix");
        sharedModules = [
          inputs.nix-index-database.homeModules.nix-index
        ];
      };
    })
  ];
}
