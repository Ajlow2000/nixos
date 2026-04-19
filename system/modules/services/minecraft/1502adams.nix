{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.services.minecraft."1502adams";
  mods = import ./mods.nix { inherit pkgs; };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.modules.services.minecraft."1502adams" = {
    enable = lib.mkEnableOption "1502adams Fabric Minecraft server";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      servers."1502adams" = {
        enable = true;
        package = pkgs.fabricServers.fabric-1_21_11;
        jvmOpts = "-Xms1G -Xmx4G";
        # UUID lookup: https://mcuuid.net
        #whitelist = {
        #  "ajlow2000" = "64f3c545-5fae-4ef0-b275-d125cded7fd4";
        #};
        serverProperties = {
          server-port = 25550;
          gamemode = "survival";
          difficulty = "normal";
          online-mode = true;
          white-list = false;
          #enforce-whitelist = true;
        };
        symlinks = {
          "mods/fabric-api.jar" = mods.fabricApi;
          "mods/pneumonocore.jar" = mods.pneumonoCore;
          "mods/balm.jar" = mods.balm;
          "mods/gravestones.jar" = mods.gravestones;
          "mods/waystones.jar" = mods.waystones;
        };
      };
    };
  };
}
