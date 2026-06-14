{ config, inputs, lib, ... }:
{
  imports = [
    ../../profiles/digital-ocean.nix
    ../../modules/services/uptime-kuma.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];

  profiles.system.digital-ocean.enable = true;
  modules.services.uptime-kuma.enable = true;

  networking.hostName = "do-prod-01";

  # sops-nix on a DigitalOcean droplet: no /persist (no impermanence), so the
  # host SSH key lives at the default location. After provisioning, derive the
  # host age key from /etc/ssh/ssh_host_ed25519_key.pub via `ssh-to-age`, paste
  # into .sops.yaml as &host_do_prod_01, and run `sops updatekeys` on the
  # relevant secrets files. Then uncomment the secrets declarations below.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Example secret pattern (uncomment after bootstrap):
  #
  # sops.defaultSopsFile = ../../../secrets/do-prod-01.yaml;
  # sops.secrets."uptime-kuma/admin-token" = {
  #   owner = "uptime-kuma";
  #   mode = "0400";
  # };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      system = "x86_64-linux";
      keys = import ../../../keys.nix;
    };
    users.ajlow = import ../../../userspace/users/ajlow-server.nix;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
