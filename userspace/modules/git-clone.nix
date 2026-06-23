{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.git-clone;

  repoOpts =
    { name, ... }:
    {
      options = {
        url = lib.mkOption {
          type = lib.types.str;
          description = "Git URL to clone.";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = ''
            Directory to clone into under baseDir (the final `git clone <url> <dir>`
            argument). Defaults to the attribute name.
          '';
        };
      };
    };
in
{
  options.modules.git-clone = {
    enable = lib.mkEnableOption "auto-clone git repos on activation (clone-only)";

    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/repos/personal";
      description = "Directory under which repos are cloned (created if missing).";
    };

    repos = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule repoOpts);
      default = { };
      example = lib.literalExpression ''
        {
          ajlow2000_foo.url = "git@github.com:ajlow/foo.git";
          bar = {
            url = "https://example.com/bar.git";
            name = "ajlow2000_bar";
          };
        }
      '';
      description = ''
        Repos to clone into baseDir. Clone-only: an existing checkout is left
        untouched (never pulled/reset). Keyed by a label; the clone directory is
        the submodule's `name` (defaults to the label).
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.repos != { }) {
    home.activation.gitCloneRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      let
        git = "${pkgs.git}/bin/git";
        clone = repo: ''
          dest=${lib.escapeShellArg "${cfg.baseDir}/${repo.name}"}
          if [ ! -e "$dest" ]; then
            echo "git-clone: cloning ${repo.url} -> $dest"
            $DRY_RUN_CMD ${git} clone ${lib.escapeShellArg repo.url} "$dest" \
              || echo "git-clone: WARN failed to clone ${repo.url}" >&2
          fi
        '';
      in
      ''
        export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg cfg.baseDir}
        ${lib.concatMapStringsSep "\n" clone (lib.attrValues cfg.repos)}
      ''
    );
  };
}
