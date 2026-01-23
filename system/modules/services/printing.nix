{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.printing;
in {
    options.modules.services.printing = {
        enable = lib.mkEnableOption "CUPS printing service";
    };

    config = lib.mkIf cfg.enable {
        services.printing.enable = true;
    };
}
