{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.git-cloner;

  repoType = lib.types.submodule {
    options = {
      url = lib.mkOption {
        type = lib.types.str;
        description = "Git URL to clone (https:// or git@host:owner/repo.git).";
        example = "git@github.com:ajlow2000/ajlow2000_nixos.git";
      };
      path = lib.mkOption {
        type = lib.types.str;
        description = "Where to clone the repo. Leading ~ is expanded to $HOME.";
        example = "~/repos/personal/ajlow2000_nixos";
      };
      branch = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Branch to check out after clone. null = repo default.";
      };
      depth = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Shallow clone depth. null = full history.";
      };
      remoteName = lib.mkOption {
        type = lib.types.str;
        default = "origin";
      };
      postClone = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Shell snippet run inside the freshly cloned repo. \$REPO_DIR is set.";
      };
    };
  };
in
{
  options.git-cloner = {
    enable = lib.mkEnableOption "declarative cloning of git repositories on home-manager activation";

    repos = lib.mkOption {
      type = lib.types.listOf repoType;
      default = [ ];
      description = "List of repositories to clone if missing.";
    };

    runAfter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "linkSshSecrets"
        "writeBoundary"
      ];
      description = "home.activation entry names this script must run after.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.repos != [ ]) {
    home.activation.gitClonerRepos = lib.hm.dag.entryAfter cfg.runAfter ''
      export PATH=${
        lib.makeBinPath [
          pkgs.git
          pkgs.openssh
          pkgs.coreutils
          pkgs.bash
        ]
      }:$PATH

      ${lib.concatMapStringsSep "\n" (r: ''
        (
          REPO_URL=${lib.escapeShellArg r.url}
          REPO_PATH=${lib.escapeShellArg r.path}
          case "$REPO_PATH" in
            "~/"*) REPO_PATH="$HOME/''${REPO_PATH#~/}" ;;
            "~")    REPO_PATH="$HOME" ;;
          esac

          if [ -d "$REPO_PATH/.git" ]; then
            exit 0
          fi

          $DRY_RUN_CMD mkdir -p "$(dirname "$REPO_PATH")"

          CLONE_ARGS=(--origin ${lib.escapeShellArg r.remoteName})
          ${lib.optionalString (r.branch != null) ''
            CLONE_ARGS+=(--branch ${lib.escapeShellArg r.branch})
          ''}
          ${lib.optionalString (r.depth != null) ''
            CLONE_ARGS+=(--depth ${toString r.depth})
          ''}

          echo "git-cloner: cloning $REPO_URL -> $REPO_PATH"
          if ! $DRY_RUN_CMD ${pkgs.git}/bin/git clone "''${CLONE_ARGS[@]}" "$REPO_URL" "$REPO_PATH"; then
            echo "git-cloner: WARN failed to clone $REPO_URL (continuing)" >&2
            exit 0
          fi

          ${lib.optionalString (r.postClone != "") ''
            (
              cd "$REPO_PATH"
              REPO_DIR="$REPO_PATH"
              export REPO_DIR
              ${pkgs.bash}/bin/bash -c ${lib.escapeShellArg r.postClone}
            ) || echo "git-cloner: WARN postClone failed for $REPO_PATH" >&2
          ''}
        )
      '') cfg.repos}
    '';
  };
}
