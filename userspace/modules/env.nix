{ config, pkgs, inputs, ... }: {
    home.sessionVariables = {
        EDITOR = "nvim";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin"; 	# Not technically in the official xdg specification
        XDG_DESKTOP_DIR="$HOME/desktop";
        XDG_DOWNLOAD_DIR="$HOME/downloads";

        AJLOW_OCAML_TOOLS="dune merlin ocaml-lsp-server odoc ocamlformat utop
            dune-release core core_unix base";
    };

    home.sessionPath = [
        "$XDG_BIN_HOME"
    ];
}
