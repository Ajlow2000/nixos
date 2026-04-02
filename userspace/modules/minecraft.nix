{ config, lib, pkgs, inputs, system, ... }:
let
    cfg = config.minecraft;

    fabulously-optimized-mrpack = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/1KVo5zza/versions/lwASzTsb/Fabulously.Optimized-v12.0.8.mrpack";
        hash = "sha256-noAs75kk7lKUVLyP9jD8GbNOGsPe6q9V7CiqglORvHM=";
    };

    # TODO
    # - better statistics screen 
    # - book scroll ?
    # - freecam
    # - mouse tweaks - OVERLAP WITH FO
    # - Litematics -- create builds in creative and see blueprint in survival
    # - no resource packs warnings 
    # - preventer
    # - renderscale
    # - shulker box tooltip 
    # - simple fog control
    # - smooth swapping 
    # - sounds
    # - status effect bars
    # - voxy
    # - UI zoom worst client
    # - xaeros minimap - OVERLAP WITH FO
    # - 
    # - 
    # - 
    mods = {
        "BetterF3.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8shC1gFX/versions/Qw1nhj7u/BetterF3-17.0.0-Fabric-1.21.11.jar";
            hash = "sha256-Wv0zOhHAElktUY3mB80PjvqBUxbl2cViXHLvz/qrCUM=";
        };
        "xaeroworldmap.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/NcUtCpym/versions/CkZVhVE0/xaeroworldmap-fabric-1.21.11-1.40.11.jar";
            hash = "sha256-916LgIsaT3F2HToVohaDfQkq7M6BTlvoneXRe2UNKPw=";
        };
        "inventive-inventory.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/bUHfVbsa/versions/QoNjSI49/inventive-inventory-1.3.5.jar";
            hash = "sha256-LP5G9WrNpWQf3Eez7AU7FPAH+GBL458jPfnuBbNJoio=";
        };
    };

    modsToFiles = ms: lib.mapAttrs' (name: src: {
        name = "mods/${name}";
        value = { source = src; method = "symlink"; };
    }) ms;

    configsToFiles = cs: lib.mapAttrs' (path: src: {
        name = path;
        value = { source = src; method = "symlink"; };
    }) cs;

    configs = {
        "options.txt" = ./minecraft_configs/options.txt;
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
                        files = (modsToFiles mods) // (configsToFiles configs);
                    };
                };
            };
            server.instances = {};
        };
    };
}
