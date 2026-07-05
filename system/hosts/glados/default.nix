{ lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./disko.nix
    ../../profiles/base.nix
    ../../modules/user-definitions.nix
  ];

  profiles.system.base.enable = true;

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
  networking.hostId = "REPLACE_ME"; # 8 hex digits, e.g. "a1b2c3d4"
  services.zfs.autoScrub.enable = true;

  networking.hostName = "glados";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
