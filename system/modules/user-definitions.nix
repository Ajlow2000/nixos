{ config, lib, pkgs, ... }:
let 
    cfg = config.user-definitions;
in {
    options = {
        user-definitions.ajlow.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.ajlow.enable {
        users.users.ajlow = {
            isNormalUser = true;
            description = "Alec Lowry";
            extraGroups = [ "networkmanager" "wheel" "wireshark" "docker" ];
            shell = pkgs.zsh;
        };
    };
}
