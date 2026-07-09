{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./disko.nix
    ../../profiles/base.nix
    ../../modules/user-definitions.nix
    ../../modules/services/immich.nix
    ../../modules/services/forgejo.nix
  ];

  profiles.system.base.enable = true;

  modules.services.immich.enable = true;
  modules.services.forgejo.enable = true;

  # disko owns the filesystem layout (see ./disko.nix): btrfs boot SSD +
  # ZFS raidz2 "tank" pool. fileSystems/swapDevices come from there.
  disko.enableConfig = true;

  user-definitions.ajlow.enable = true;
  user-definitions.ajlow.profile = "server";

  security.sudo.wheelNeedsPassword = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ZFS storage pool ("tank"). networking.hostId must be a unique 8-hex-digit
  # value — generate on install with:
  #   head -c4 /dev/urandom | od -A none -t x4
  # ZFS requires it and refuses to import a pool if it changes unexpectedly.
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "9dd1dbc7";
  services.zfs.autoScrub.enable = true;

  networking.hostName = "glados";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
