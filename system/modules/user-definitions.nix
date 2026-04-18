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
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = builtins.attrValues keys.personal;
      };

      # Home Manager integration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs keys;
          system = pkgs.stdenv.hostPlatform.system;
        };
        users.ajlow = import ../../userspace/users/ajlow.nix;
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
        ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = builtins.attrValues keys.sram;
      };

      # Home Manager integration
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
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
