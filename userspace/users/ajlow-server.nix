{ pkgs, ... }:
{
  imports = [
    ../profiles/server.nix
  ];

  profiles.user.server.enable = true;

  home.username = "ajlow";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/ajlow" else "/home/ajlow";
  home.stateVersion = "22.11";
}
