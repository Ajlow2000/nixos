{ pkgs, ... }:
{
  imports = [
    ../profiles/work.nix
  ];

  profiles.user.work.enable = true;

  home.username = "ajlow";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/ajlow" else "/home/ajlow";
  home.stateVersion = "22.11";
}
