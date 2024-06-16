{ config, pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.ajlow = {
    isNormalUser = true;
    description = "Alec Lowry";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}
