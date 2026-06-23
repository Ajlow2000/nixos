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
    ../../profiles/laptop.nix
    ../../modules/desktop/cosmic.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/ollama.nix
    ../../modules/user-definitions.nix
  ];

  # disko owns fileSystems/swapDevices (btrfs layout in ./disko.nix); they were
  # removed from hardware.nix accordingly.
  # WARNING: this config now matches the post-reinstall btrfs disk, NOT the live
  # ext4 system. Do not `nh os switch`/reboot microvac into a new generation
  # before the nixos-anywhere reinstall (see ./readme.md) or it will be unbootable.
  disko.enableConfig = true;

  profiles.system.laptop.enable = true;

  modules.desktop.cosmic.enable = true;

  modules.desktop.display-manager.enable = lib.mkForce false;

  modules.services.gaming.enable = true;
  modules.services.ollama.enable = true;

  modules.sops.enable = true;

  user-definitions.ajlow.enable = true;

  modules.services.virtualization.users = [ "ajlow" ];

  environment.systemPackages = with pkgs; [
    cosmic-bg
    cosmic-ext-ctl
    wireguard-tools
    proton-vpn
  ];

  networking.firewall.checkReversePath = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "microvac";
  system.stateVersion = "24.05";
}
