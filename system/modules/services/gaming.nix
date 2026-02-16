{ config, lib, ... }:
let
    cfg = config.modules.services.gaming;
in {
    options.modules.services.gaming = {
        enable = lib.mkEnableOption "Steam gaming platform";
    };

    config = lib.mkIf cfg.enable {
        programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
        };
    };
}
