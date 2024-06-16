{ config, pkgs, ... }: {
    environment.sessionVariables = rec {
        EDITOR = "nvim";

        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
        PATH = [ "${XDG_BIN_HOME}" ];
    };
}
