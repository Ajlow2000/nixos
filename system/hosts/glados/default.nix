{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ../../profiles/base.nix
    ../../modules/user-definitions.nix
  ];

  profiles.system.base.enable = true;

  user-definitions.ajlow.enable = true;

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "glados";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
