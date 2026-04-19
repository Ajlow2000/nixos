{ lib, ... }:
{
  imports = [
    ../../profiles/server.nix
    ./hardware.nix
  ];

  profiles.system.server.enable = true;

  networking.hostName = "glados";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
