{ config, lib, ... }:
let 
    cfg = config.star_citizen;
in {
    options = {
        star_citizen.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        # Cachix setup
        nix.settings = {
            substituters = ["https://nix-citizen.cachix.org"];
            trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
        };
        nix-citizen.starCitizen = {
            # Enables the star citizen module
            enable = true;
            # Additional commands before the game starts
            preCommands = ''
                export DXVK_HUD=compiler;
                export MANGO_HUD=1;
            '';
            # Experimental script
            helperScript.enable = true;
            
            # # This option is enabled by default
            # #  Configures your system to meet some of the requirements to run star-citizen
            # # Set `vm.max_map_count` default to `16777216` (sysctl(8))
            # #Set `fs.file-max` default to `524288` (sysctl(8))
            # #Also sets `security.pam.loginLimits` to increase hard (limits.conf(5))
            # # Changes outlined in  https://github.com/starcitizen-lug/knowledge-base/wiki/Manual-Installation#prerequisites
            # setLimits = false;
        };
    };
}
