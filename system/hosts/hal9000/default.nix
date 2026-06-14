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
    inputs.nix-citizen.nixosModules.StarCitizen
    inputs.sops-nix.nixosModules.sops
    ./hardware.nix
    ./disko.nix
    ../../profiles/laptop.nix
    ../../modules/desktop/cosmic.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/game-streaming.nix
    ../../modules/services/ollama.nix
    ../../modules/services/star-citizen.nix
    ../../modules/services/minecraft/1502adams.nix
    ../../modules/services/playit.nix
    ../../modules/services/git-server.nix
    ../../modules/services/yubikey.nix
    ../../modules/user-definitions.nix
    ../../modules/impermanence/rollback.nix
    ../../modules/impermanence/persistence.nix
  ];

  # Keep hardware.nix managing fileSystems until next reinstall.
  # On reinstall: flip to true and remove the root / boot / swap entries from
  # hardware.nix. Keep the /mnt/ssd1 and /mnt/ssd2 entries — those drives are
  # not managed by disko.
  disko.enableConfig = false;

  profiles.system.laptop.enable = true;

  modules.desktop.cosmic.enable = true;

  modules.desktop.display-manager.enable = lib.mkForce false;

  modules.services.gaming.enable = true;
  modules.services.game-streaming.server.enable = true;
  modules.services.game-streaming.client.enable = true;
  modules.services.ollama.enable = true;
  modules.services.star-citizen.enable = true;
  modules.services.minecraft."1502adams".enable = true;
  modules.services.playit.enable = true;
  modules.services.yubikey.enable = true;

  modules.services.git-server = {
    enable = true;
    adminPubkeys =
      let
        keys = (import ../../../keys.nix).personal;
      in
      {
        inherit (keys) microvac hal9000;
      };
  };

  modules.impermanence.rollback.enable = true;
  modules.impermanence.persistence = {
    enable = true;
    # Service state for hal9000-specific workloads. Paths are best-guess —
    # adjust after first boot once `systemctl status <unit>` confirms where
    # each service actually writes.
    extraDirectories = [
      "/var/lib/private/gitea"
      "/var/lib/playit"
      # Minecraft worlds (1502adams) — confirm path against the module:
      # "/var/lib/minecraft"
    ];
  };

  boot.initrd.systemd.enable = true;

  # See microvac/default.nix for the secret-declaration template. Hal9000
  # follows the same pattern; uncomment after bootstrap once secrets exist.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

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
