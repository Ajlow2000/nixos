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

    user-definitions.alowry.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
        openssh.authorizedKeys.keys = builtins.attrValues keys.personal;
        hashedPasswordFile = lib.mkIf config.modules.sops.enable config.sops.secrets."ajlow_passwd".path;
      };

      modules.sops.passwords.users = lib.mkIf config.modules.sops.enable [ "ajlow" ];
      modules.sops.sshKeys.users = lib.mkIf config.modules.sops.enable [ "ajlow" ];

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

    (lib.mkIf cfg.alowry.enable {
      users.users.alowry = {
        isNormalUser = true;
        description = "Alec Lowry (Work)";
        extraGroups = [
          "networkmanager"
          "wheel"
          "wireshark"
          "docker"
          "plugdev"
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = builtins.attrValues keys.sram;
        hashedPasswordFile = lib.mkIf config.modules.sops.enable config.sops.secrets."alowry_passwd".path;
      };

      modules.sops.passwords.users = lib.mkIf config.modules.sops.enable [ "alowry" ];

      # Home Manager integration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit inputs keys;
          system = pkgs.stdenv.hostPlatform.system;
        };
        users.alowry = import ../../userspace/users/alowry.nix;
        sharedModules = [
          inputs.nix-index-database.homeModules.nix-index
        ];
      };
    })
  ];
}
