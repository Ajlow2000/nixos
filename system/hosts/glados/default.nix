{ lib, config, inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware.nix
    ./disko.nix
    ../../profiles/base.nix
    ../../modules/user-definitions.nix
    ../../modules/services/immich.nix
    ../../modules/services/forgejo.nix
    ../../modules/services/pijul-nest.nix
  ];

  profiles.system.base.enable = true;

  modules.services.immich.enable  = true;
  modules.services.forgejo.enable = true;
  modules.services.pijulNest = {
    enable = true;
    domain = "pijul.internal.aleclowry.com";
    baseUrl = "https://pijul.internal.aleclowry.com";
    pbkdf2PasswordFile = config.sops.secrets."pijul-nest-pbkdf2-password".path;
    pbkdf2SaltFile = config.sops.secrets."pijul-nest-pbkdf2-salt".path;
  };
sops.secrets."pijul-nest-pbkdf2-password" = {
    key = "pijul_nest/pbkdf2_password";
    owner = config.modules.services.pijulNest.user;
    mode = "0400";
  };
  sops.secrets."pijul-nest-pbkdf2-salt" = {
    key = "pijul_nest/pbkdf2_salt";
    owner = config.modules.services.pijulNest.user;
    mode = "0400";
  };

  # Shared PostgreSQL cluster on the ZFS tank (used by immich and pijul-nest).
  services.postgresql.dataDir = "/mnt/tank/services/postgres";
  systemd.tmpfiles.rules = [ "d /mnt/tank/services/postgres 0700 postgres postgres -" ];
  systemd.services.postgresql.unitConfig.RequiresMountsFor = [ "/mnt/tank/services/postgres" ];

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
