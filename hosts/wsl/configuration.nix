# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  wsl.enable = true;
  wsl.defaultUser = "ajlow";
  networking.hostName = "nixos-wsl";

  users.users.ajlow = {
	  isNormalUser = true;
	  description = "Alec Lowry";
	  shell = pkgs.zsh;
	  extraGroups = [ "networkmanager" "wheel" "video" "wireshark"];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
	  neovim
	  git
	  home-manager
  ];

  environment.sessionVariables = rec {
        EDITOR = "nvim";

        NIXOS_CONFIG_PROFILE = "wsl";	# Used to dynamically determine configuration profile in home manager

        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
        #PATH = [ "${XDG_BIN_HOME}" ];
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
