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
    ../../profiles/laptop.nix
    ../../modules/desktop/cosmic.nix
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

  profiles.system.laptop.enable = true;

  modules.desktop.cosmic.enable = true;

  modules.desktop.display-manager.enable = lib.mkForce false;

  modules.services.gaming.enable = true;
  modules.services.ollama.enable = true;
  modules.services.yubikey.enable = true;

  modules.impermanence.rollback.enable = true;
  modules.impermanence.persistence.enable = true;

  boot.initrd.systemd.enable = true;

  # sops-nix: derive the host age identity from the persistent SSH host key.
  # `defaultSopsFile` and `sops.secrets.*` declarations are commented out until
  # the bootstrap (see disko.nix step 5-6) has produced the host key and the
  # secrets/*.yaml files have been created and encrypted.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

  # Uncomment after bootstrap once secrets/microvac.yaml exists and is encrypted:
  #
  # sops.defaultSopsFile = ../../../secrets/microvac.yaml;
  #
  # sops.secrets."root/password-hash" = {
  #   neededForUsers = true;
  # };
  # sops.secrets."ajlow/password-hash" = {
  #   sopsFile = ../../../secrets/users/ajlow.yaml;
  #   neededForUsers = true;
  # };
  # sops.secrets."ajlow/ssh/id_ed25519" = {
  #   sopsFile = ../../../secrets/users/ajlow.yaml;
  #   owner = "ajlow";
  #   group = "users";
  #   mode = "0600";
  #   path = "/run/secrets/ajlow_id_ed25519";
  # };
  # sops.secrets."ajlow/ssh/id_ed25519.pub" = {
  #   sopsFile = ../../../secrets/users/ajlow.yaml;
  #   owner = "ajlow";
  #   group = "users";
  #   mode = "0644";
  #   path = "/run/secrets/ajlow_id_ed25519.pub";
  # };
  #
  # users.mutableUsers = false;
  # users.users.root.hashedPasswordFile  = config.sops.secrets."root/password-hash".path;
  # users.users.ajlow.hashedPasswordFile = config.sops.secrets."ajlow/password-hash".path;

  user-definitions.ajlow.enable = true;

  modules.services.virtualization.users = [ "ajlow" ];

  environment.systemPackages = with pkgs; [
    cosmic-bg
    cosmic-ext-ctl
    wireguard-tools
    proton-vpn
    sops
    ssh-to-age
    age
  ];

  networking.firewall.checkReversePath = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "microvac";
  system.stateVersion = "24.05";
}
