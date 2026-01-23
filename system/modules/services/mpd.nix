{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.mpd;
in {
    options.modules.services.mpd = {
        enable = lib.mkEnableOption "Music Player Daemon (MPD)";

        user = lib.mkOption {
            type = lib.types.str;
            default = "ajlow";
            description = "User to run MPD as";
        };

        group = lib.mkOption {
            type = lib.types.str;
            default = "users";
            description = "Group to run MPD as";
        };

        musicDirectory = lib.mkOption {
            type = lib.types.str;
            default = "/home/ajlow/media";
            description = "Directory containing music files";
        };

        playlistDirectory = lib.mkOption {
            type = lib.types.str;
            default = "/home/ajlow/media/playlists";
            description = "Directory for playlists";
        };
    };

    config = lib.mkIf cfg.enable {
        services.mpd = {
            enable = true;
            user = cfg.user;
            group = cfg.group;
            startWhenNeeded = true;
            settings = {
                music_directory = cfg.musicDirectory;
                playlist_directory = cfg.playlistDirectory;
            };
        };

        systemd.services.mpd.environment = {
            XDG_RUNTIME_DIR = "/run/user/1000";
        };

        environment.systemPackages = with pkgs; [
            mpc
            rmpc
        ];
    };
}
