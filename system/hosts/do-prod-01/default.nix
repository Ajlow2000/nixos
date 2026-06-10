{ inputs, lib, ... }:
{
  imports = [
    ../../profiles/digital-ocean.nix
    ../../modules/services/uptime-kuma.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  profiles.system.digital-ocean.enable = true;
  modules.services.uptime-kuma.enable = true;

  networking.hostName = "do-prod-01";

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
