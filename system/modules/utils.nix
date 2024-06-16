{ config, pkgs, ... }: {
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    firefox
    home-manager
  ];
}
