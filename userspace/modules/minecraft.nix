{ config, lib, pkgs, inputs, system, ... }:
let
    cfg = config.minecraft;

    simply-optimized-mrpack = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/BYfVnHa7/versions/vZZwrcPm/Simply%20Optimized-1.21.1-5.0.mrpack";
        hash = "sha256-n2BxHMmqpOEMsvDqRRYFfamcDCCT4ophUw7QAJQqXmg=";
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
                        };
                        mrpack = {
                            enable = true;
                            file = simply-optimized-mrpack;
                        };
                    };
                };
            };
            server.instances = {};
        };
    };
}
