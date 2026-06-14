{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    ./hardware.nix
    ./disko.nix
    ../../profiles/desktop.nix
    ../../modules/desktop/gnome.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/ollama.nix
    ../../modules/services/yubikey.nix
    ../../modules/user-definitions.nix
    ../../modules/impermanence/rollback.nix
    ../../modules/impermanence/persistence.nix
  ];

  # Keep hardware.nix managing fileSystems until next reinstall.
  # On reinstall: flip to true and remove fileSystems/swapDevices from hardware.nix.
  disko.enableConfig = false;

  profiles.system.desktop.enable = true;

  modules.desktop.gnome.enable = true;
  modules.desktop.display-manager.enable = true;

  modules.services.gaming.enable = true;
  modules.services.ollama.enable = true;
  modules.services.yubikey.enable = true;

  modules.impermanence.rollback.enable = true;
  modules.impermanence.persistence.enable = true;

  boot.initrd.systemd.enable = true;

  # See microvac/default.nix for the secret-declaration template.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

  user-definitions.ajlow.enable = true;

  modules.services.virtualization.users = [ "ajlow" ];

  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
    proton-vpn
    sops
    ssh-to-age
    age
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "multivac";
  system.stateVersion = "24.05";
}
