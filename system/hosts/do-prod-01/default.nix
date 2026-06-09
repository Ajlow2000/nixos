{ lib, ... }:
{
  imports = [
    ../../profiles/digital-ocean.nix
  ];

  profiles.system.digital-ocean.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
