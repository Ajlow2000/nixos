{ config, lib, pkgs, inputs, system, ... }:
let
    cfg = config.minecraft;

    fabulously-optimized-mrpack = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/1KVo5zza/versions/lwASzTsb/Fabulously.Optimized-v12.0.8.mrpack";
        hash = "sha256-noAs75kk7lKUVLyP9jD8GbNOGsPe6q9V7CiqglORvHM=";
    };

    # TODO
    # - book scroll ?
    # - freecam
    # - Litematics -- create builds in creative and see blueprint in survival
    # - no resource packs warnings 
    # - preventer
    # - renderscale
    # - shulker box tooltip 
    # - simple fog control
    # - smooth swapping 
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
        "betterstats.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/n6PXGAoM/versions/99mBkJp1/betterstats-5.1.0+fabric-1.21.11.jar";
            hash = "sha256-24QXSN7BBm/qjibL9VnOG2oYd7IchiLv4QMfyUXqIB4=";
        };
        "tcdcommons.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Eldc1g37/versions/X850L9UC/tcdcommons-5.1.0+fabric-1.21.11.jar";
            hash = "sha256-oK0oOiikxsgjbMKIrRDJLnthZ+eEO6483EPIlgQkvSg=";
        };
        "mousetweaks.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/aC3cM3Vq/versions/i1duwnJl/MouseTweaks-fabric-mc1.21.11-2.30.jar";
            hash = "sha256-5nGMbzX2Q1KUYyto748lH+aAvNUyT/tJQ9qkE5DBw8Y=";
        };
        "sounds.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/ZouiUX7t/versions/wvhDSvYI/sounds-2.4.23+edge+1.21.11-fabric.jar";
            hash = "sha256-j6r7mEuJflcFHceA3zJKZe3bxU/9xw6CNgttnTsjUdg=";
        };
        "mru.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/SNVQ2c0g/versions/XXzIJdq5/mru-1.0.26+edge+1.21.11-fabric.jar";
            hash = "sha256-pBzlbpkc85yR+XQ4YMq0vNajssEfioooaGwIhuR/YkQ=";
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
                            extraConfig = {
                                # TODO: nixcraft has a known bug where icons don't work
                                icon = "${./minecraft_configs/grass-block.svg}";
                            };
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
