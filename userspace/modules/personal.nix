{ config, lib, pkgs, ... }:
let 
    cfg = config.personal;
in {
    options = {
        personal.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = with pkgs; ([
            discord
            webcord
            yt-dlp
            tone
            ffmpeg_6
            vlc
            asunder
            newsboat
            obs-studio
        ]);
    };
}
