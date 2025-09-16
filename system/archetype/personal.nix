{ config, lib, pkgs, ... }:
let 
    cfg = config.personal;
in {
    imports = [
        ./work.nix
        ../modules/user-definitions.nix
        ../modules/gaming.nix
    ];

    options = {
        personal.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        work.enable = true;
        user-definitions.ajlow.enable = true;
        gaming.enable = true;

        networking.firewall.checkReversePath = false;
        environment.systemPackages = with pkgs; [
            wireguard-tools 
            protonvpn-gui
        ];
    };
}
