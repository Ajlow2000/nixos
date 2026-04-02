{ config, lib, pkgs, inputs, system, ... }:
let
    cfg = config.minecraft;

    fabulously-optimized-mrpack = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/1KVo5zza/versions/lwASzTsb/Fabulously.Optimized-v12.0.8.mrpack";
        hash = "sha256-noAs75kk7lKUVLyP9jD8GbNOGsPe6q9V7CiqglORvHM=";
    };

    better-f3 = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/8shC1gFX/versions/Qw1nhj7u/BetterF3-17.0.0-Fabric-1.21.11.jar";
        hash = "sha256-Wv0zOhHAElktUY3mB80PjvqBUxbl2cViXHLvz/qrCUM=";
    };

in {
    imports = [
        inputs.nixcraft.homeModules.default
    ];

    options = {
        minecraft.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
            prismlauncher
        ];

        nixcraft = {
            enable = true;
            client = {
                # shared applies to all instances
                shared = {
                    files."screenshots".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/screenshots";

                    account = {
                        username = "ajlow2000";
                        uuid = "64f3c545-5fae-4ef0-b275-d125cded7fd4";
                        offline = true;
                    };

                    binEntry.enable = true;
                };

                instances = {
                    forever = {
                        enable = true;

                        desktopEntry = {
                            enable = true;
                            name = "Minecraft Forever";
                        };
                        binEntry = {
                            enable = true;
                            name = "minecraft-forever";
                        };
                        mrpack = {
                            enable = true;
                            file = fabulously-optimized-mrpack;
                        };
                        files."mods/BetterF3.jar" = {
                            source = better-f3;
                            method = "copy";
                        };
                    };
                };
            };
            server.instances = {};
        };
    };
}
