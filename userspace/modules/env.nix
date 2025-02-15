{ config, lib, ... }:
let 
    cfg = config.env;
in {
    options = {
        env.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
        };
    };

    config = lib.mkIf cfg.enable {
        home.sessionVariables = {
            EDITOR = "nvim";
            FILE_BROWSER = "xplr";
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";
            XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
            XDG_DESKTOP_DIR="$HOME/desktop";
            XDG_DOWNLOAD_DIR="$HOME/downloads";

            AJLOW_MANAGED_SESSIONS="$XDG_DATA_HOME/managed-sessions.toml";
            AJLOW_REPO_HOME="$HOME/repos";

            MOZ_ENABLE_WAYLAND="1";
        };

        home.sessionPath = [
            "$XDG_BIN_HOME"
        ];
    };
}
