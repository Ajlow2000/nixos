{
  pkgs,
  modulesPath,
  keys,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Enable flakes and nix-command for bootstrapping
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    libfido2
    yubikey-manager
  ];

  # SSH in immediately with your YubiKey from another machine
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  users.users.root.openssh.authorizedKeys.keys = builtins.attrValues keys.personal;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
