{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./disko.nix
    ../../profiles/desktop.nix
    ../../modules/desktop/gnome.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/ollama.nix
    ../../modules/user-definitions.nix
  ];

  # Keep hardware.nix managing fileSystems until next reinstall.
  # On reinstall: flip to true and remove fileSystems/swapDevices from hardware.nix.
  disko.enableConfig = false;

  profiles.system.desktop.enable = true;

  modules.desktop.gnome.enable = true;
  modules.desktop.display-manager.enable = true;

  modules.services.gaming.enable = true;
  modules.services.ollama.enable = true;

  user-definitions.ajlow.enable = true;

  modules.services.virtualization.users = [ "ajlow" ];

  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
    proton-vpn
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "multivac";
  system.stateVersion = "24.05";
}
