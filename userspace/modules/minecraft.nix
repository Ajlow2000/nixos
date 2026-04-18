{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
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

  shaders = {
    "ComplementaryUnbound_r5.7.1.zip" = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/R6NEzAwj/versions/d8rcvDTp/ComplementaryUnbound_r5.7.1.zip";
      hash = "sha256-XL9Nmbx85PDfXBWXTSduCUm/aXTUjYinfV4wewub6K8=";
    };
  };

  ninjabrain-bot = pkgs.stdenv.mkDerivation rec {
    pname = "ninjabrain-bot";
    version = "1.5.2";

    src = pkgs.fetchurl {
      url = "https://github.com/Ninjabrain1/Ninjabrain-Bot/releases/download/${version}/Ninjabrain-Bot-${version}.jar";
      hash = "sha256-mAmfYyGpDUrOwTQA6G0F96+NYOVjnC84Qn6WjccUUP8=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/lib/java $out/bin
      install -D $src $out/lib/java/ninjabrain-bot.jar
      makeWrapper ${pkgs.jre}/bin/java $out/bin/ninjabrain-bot \
          --add-flags "-jar $out/lib/java/ninjabrain-bot.jar"
    '';

    meta = with pkgs.lib; {
      description = "Accurate stronghold calculator for Minecraft speedrunning";
      homepage = "https://github.com/Ninjabrain1/Ninjabrain-Bot";
      mainProgram = "ninjabrain-bot";
    };
  };

  modsToFiles =
    ms:
    lib.mapAttrs' (name: src: {
      name = "mods/${name}";
      value = {
        source = src;
        method = "symlink";
      };
    }) ms;

  shadersToFiles =
    ss:
    lib.mapAttrs' (name: src: {
      name = "shaderpacks/${name}";
      value = {
        source = src;
        method = "symlink";
      };
    }) ss;

  configsToFiles =
    cs:
    lib.mapAttrs' (path: src: {
      name = path;
      value = {
        source = src;
        method = "symlink";
      };
    }) cs;

  configs = {
    "options.txt" = ./minecraft_configs/options.txt;
  };

in
{
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
      ninjabrain-bot
    ];

    nixcraft = {
      enable = true;
      client = {
        # shared applies to all instances
        shared = {
          files."screenshots".source =
            config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/screenshots";

          account = {
            username = "ajlow2000";
            uuid = "64f3c545-5fae-4ef0-b275-d125cded7fd4";
            offline = true;
          };

          binEntry.enable = true;
        };

        instances = {
          mcsr = {
            enable = true;

            mrpack = {
              enable = true;
              file = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/1uJaMUOm/versions/jIrVgBRv/SpeedrunPack-mc1.16.1-v5.3.0.mrpack";
                hash = "sha256-uH/fGFrqP2UpyCupyGjzFB87LRldkPkcab3MzjucyPQ=";
              };
            };

            java = {
              extraArguments = [
                "-XX:+UseZGC"
                "-XX:+AlwaysPreTouch"
                "-Dgraal.TuneInlinerExploration=1"
                "-XX:NmethodSweepActivity=1"
              ];
              package = pkgs.jdk17;
              maxMemory = 4000;
              minMemory = 4000;
            };

            saves = {
              "Practice Map" = pkgs.fetchzip {
                url = "https://github.com/Dibedy/The-MCSR-Practice-Map/releases/download/1.0.1/MCSR.Practice.v1.0.1.zip";
                stripRoot = false;
                hash = "sha256-ukedZCk6T+KyWqEtFNP1soAQSFSSzsbJKB3mU3kTbqA=";
              };
            };

            waywall.enable = true;

            binEntry = {
              enable = true;
              name = "minecraft-mcsr";
            };

            desktopEntry = {
              enable = true;
              name = "Minecraft MCSR";
              extraConfig = {
                terminal = true;
              };
            };
          };

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
            files = (modsToFiles mods) // (shadersToFiles shaders) // (configsToFiles configs);
          };
        };
      };
      server.instances = { };
    };
  };
}
