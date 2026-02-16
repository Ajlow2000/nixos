{ config, lib, pkgs, ... }:
let
    cfg = config.modules.work.sentinelone;
in {
    options.modules.work.sentinelone = {
        enable = lib.mkEnableOption "SentinelOne endpoint security";

        email = lib.mkOption {
            type = lib.types.str;
            description = "Email for SentinelOne registration";
        };

        serialNumber = lib.mkOption {
            type = lib.types.str;
            description = "Device serial number";
        };

        tokenPath = lib.mkOption {
            type = lib.types.path;
            default = /etc/nixos/sentinelOne.token;
            description = "Path to SentinelOne management token";
        };

        packageSource = lib.mkOption {
            type = lib.types.path;
            description = "Path to SentinelOne .deb package";
        };
    };

    config = lib.mkIf cfg.enable {
        services.sentinelone = {
            enable = true;
            sentinelOneManagementTokenPath = cfg.tokenPath;
            email = cfg.email;
            serialNumber = cfg.serialNumber;
            package = pkgs.sentinelone.overrideAttrs (old: {
                version = "sentinelone.package.version";
                src = cfg.packageSource;
            });
        };
    };
}
