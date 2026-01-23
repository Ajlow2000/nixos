{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.docker;
in {
    options.modules.services.docker = {
        enable = lib.mkEnableOption "Docker container runtime";
    };

    config = lib.mkIf cfg.enable {
        virtualisation.docker = {
            enable = true;
            daemon.settings.data-root = "$XDG_DATA_HOME/docker";
        };
    };
}
