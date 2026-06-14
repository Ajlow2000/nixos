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
    inputs.sentinelone.nixosModules.sentinelone
    inputs.sops-nix.nixosModules.sops
    ./hardware.nix
    ./disko.nix
    ../../profiles/laptop.nix
    ../../modules/desktop/cosmic.nix
    ../../modules/desktop/display-manager.nix
    ../../modules/services/gaming.nix
    ../../modules/services/ollama.nix
    ../../modules/services/yubikey.nix
    ../../modules/work/sram-udev.nix
    ../../modules/work/sentinelone.nix
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

  user-definitions.ajlow.enable = true;
  user-definitions.ajlow.profile = "work";

  modules.services.virtualization.users = [ "ajlow" ];

  modules.work.sram-udev.enable = true;
  #modules.work.sentinelone = {
  #  enable = false;
  #  email = "alowry@sram.com";
  #  serialNumber = "DPR8SQ3";
  #  tokenPath = ./sentinelOne.token;
  #  packageSource = ./SentinelAgent_linux_x86_64_v24_3_3_6.deb;
  #};

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "mydatabase" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };

  modules.impermanence.rollback.enable = true;
  modules.impermanence.persistence = {
    enable = true;
    extraDirectories = [
      "/var/lib/postgresql"
    ];
  };

  boot.initrd.systemd.enable = true;

  # See microvac/default.nix for the secret-declaration template.
  sops.age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

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

  boot.blacklistedKernelModules = [ "nouveau" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "eddie";
  system.stateVersion = "24.05";
}
