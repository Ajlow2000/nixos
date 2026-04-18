{
  config,
  pkgs,
  lib,
  modulesPath,
  keys,
  ...
}:
let
  cfg = config.profiles.system.digital-ocean;
in
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-image.nix")
    ./base.nix
  ];

  options.profiles.system.digital-ocean = {
    enable = lib.mkEnableOption "DigitalOcean droplet configuration";
  };

  config = lib.mkIf cfg.enable {
    profiles.system.base.enable = true;

    # Override base.nix's NetworkManager — DO provides DHCP on eth0
    networking.networkmanager.enable = lib.mkForce false;
    networking.useDHCP = lib.mkDefault true;

    # Hostname pulled from DO droplet name at boot; hosts can override
    networking.hostName = lib.mkDefault "";

    # Don't attempt nixos-rebuild from DO user-data (flake-managed)
    virtualisation.digitalOcean.rebuildFromUserData = false;

    # Define ajlow without home-manager dependency
    # (user-definitions.nix is coupled to HM; not used here)
    users.users.ajlow = {
      isNormalUser = true;
      description = "Alec Lowry";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = builtins.attrValues keys.personal;
    };

    security.sudo.wheelNeedsPassword = false;
  };
}
