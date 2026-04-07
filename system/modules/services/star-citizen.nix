{ config, lib, ... }:
let
    cfg = config.modules.services.star-citizen;
in {
    options.modules.services.star-citizen = {
        enable = lib.mkEnableOption "Star Citizen via nix-citizen";
    };

    config = lib.mkIf cfg.enable {
        programs.rsi-launcher = {
            enable = true;
            setLimits = true;
            patchXwayland = true;
            enforceWaylandDrv = true;
        };
    };
}
