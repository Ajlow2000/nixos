{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-citizen.nixosModules.StarCitizen
    ./hardware.nix
    ../../profiles/laptop.nix
    ../../modules/desktop/cosmic.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/ollama.nix
    ../../modules/services/star-citizen.nix
    ../../modules/user-definitions.nix
  ];

  profiles.system.laptop.enable = true;

  modules.desktop.cosmic.enable = true;

  modules.desktop.display-manager.enable = lib.mkForce false;

  modules.services.gaming.enable = true;
  modules.services.ollama.enable = true;
  modules.services.star-citizen.enable = true;

  user-definitions.ajlow.enable = true;

  modules.services.virtualization.users = [ "ajlow" ];

  environment.systemPackages = with pkgs; [
    cosmic-bg
    cosmic-ext-ctl
    wireguard-tools
    protonvpn-gui
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/ssd1 0755 ajlow users -"
    "d /mnt/ssd2 0755 ajlow users -"
  ];

  networking.firewall.checkReversePath = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hal9000";
  system.stateVersion = "24.05";
}
