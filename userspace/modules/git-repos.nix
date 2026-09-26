{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.git-repos;

  urlToDirname =
    url:
    let
      noGit = lib.removeSuffix ".git" url;
      # Extract just the path after host, then join all segments with "_" (lowercased).
      # SSH:   git@gitlab.com:sram/dse/bleetcode  -> split on ":", take last part
      # HTTPS: https://github.com/User/repo        -> strip protocol+host, take remaining
      path =
        if lib.hasInfix "@" noGit then
          lib.last (lib.splitString ":" noGit)
        else
          let
            withoutProto = lib.removePrefix "https://" (lib.removePrefix "http://" noGit);
          in
          lib.concatStringsSep "/" (lib.tail (lib.splitString "/" withoutProto));
    in
    lib.concatStringsSep "_" (map lib.toLower (lib.splitString "/" path));

in
{
  options.modules.git-repos = {
    enable = lib.mkEnableOption "auto-clone git repos on activation (clone-only, never delete)";

    reposRoot = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/repos";
      description = "Root directory that holds all profile subdirectories (e.g. ~/repos).";
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      example = lib.literalExpression ''
        {
          personal = [
            "git@github.com:Ajlow2000/branding.git"
            "https://github.com/Ajlow2000/dotfiles.git"
          ];
          sram = [
            "git@github.com:sram/some-repo.git"
          ];
        }
      '';
      description = ''
        Map of profile name to list of git URLs to clone.
        Each profile clones into ~/repos/<profile>/<user>_<repo>.
        Clone-only: existing checkouts are left untouched. Removing a URL
        from the list does not delete the checkout.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.profiles != { }) {
    home.file.".local/share/managed-sessions/manifest" =
      let
        allPaths = lib.flatten (
          lib.mapAttrsToList (
            profile: urls: map (url: "${cfg.reposRoot}/${profile}/${urlToDirname url}") urls
          ) cfg.profiles
        );
      in
      { text = lib.concatStringsSep "\n" allPaths + "\n"; };

    home.activation.gitCloneRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      let
        git = "${pkgs.git}/bin/git";
        mkdir = "${pkgs.coreutils}/bin/mkdir";

        cloneOne =
          profileDir: url:
          let
            dirname = urlToDirname url;
          in
          ''
            dest=${lib.escapeShellArg "${profileDir}/${dirname}"}
            if [ ! -e "$dest" ]; then
              echo "git-repos: cloning ${url} -> $dest"
              $DRY_RUN_CMD ${git} clone ${lib.escapeShellArg url} "$dest" || echo "git-repos: WARNING: clone failed for ${url}, skipping"
            fi
          '';

        cloneProfile =
          profile: urls:
          let
            profileDir = "${cfg.reposRoot}/${profile}";
          in
          ''
            $DRY_RUN_CMD ${mkdir} -p ${lib.escapeShellArg profileDir}
            ${lib.concatMapStringsSep "\n" (cloneOne profileDir) urls}
          '';
      in
      ''
        export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new"
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList cloneProfile cfg.profiles)}
      ''
    );
  };
}
