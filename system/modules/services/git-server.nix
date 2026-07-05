# Self-hosted git server: gitolite backend + two cgit web UIs.
#
# gitolite handles access management; Nix is the source of truth. The repo
# list and admin/guest pubkeys are declared here, rendered into a gitolite.conf
# + keydir, and reconciled into gitolite on every rebuild (see the reconcile
# service below) — pushes to the gitolite-admin repo are NOT the workflow and
# get overwritten.
#
# Two cgit instances browse the same repositories: `private` shows everything,
# `public` shows only repos marked `public`. Both are reachable only over the
# Netbird mesh (wt0), never the public interface.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.git-server;

  dataDir = "/var/lib/gitolite";
  gitUser = "git";

  adminNames = builtins.attrNames cfg.adminPubkeys;
  guestNames = builtins.attrNames cfg.guestPubkeys;
  adminList = lib.concatStringsSep " " adminNames;
  guestList = lib.concatStringsSep " " guestNames;

  allPubkeys = cfg.adminPubkeys // cfg.guestPubkeys;

  # keydir: one <name>.pub per admin/guest key. `gitolite setup` turns these
  # into ~/.ssh/authorized_keys, mapping each key to the gitolite user <name>.
  keydir = pkgs.runCommand "gitolite-keydir" { } (
    "mkdir -p $out\n"
    + lib.concatStrings (
      lib.mapAttrsToList (
        name: key: "printf '%s\\n' ${lib.escapeShellArg key} > \"$out/${name}.pub\"\n"
      ) allPubkeys
    )
  );

  # Per-repo access block. Admins get RW+; guests get RW only on public repos.
  mkRepoBlock =
    name: repo:
    lib.concatStringsSep "\n" (
      [
        "repo ${name}"
        "    RW+ = ${adminList}"
      ]
      ++ lib.optional (repo.public && guestList != "") "    RW = ${guestList}"
      ++ lib.optional (repo.description != "") ''    config gitweb.description = "${repo.description}"''
      ++ lib.optional (repo.owner != "") ''    config gitweb.owner = "${repo.owner}"''
    );

  gitoliteConf = pkgs.writeText "gitolite.conf" (
    lib.concatStringsSep "\n\n" (
      [
        (lib.concatStringsSep "\n" [
          "repo gitolite-admin"
          "    RW+ = ${adminList}"
          # Hide the admin repo from cgit (honoured because enable-git-config=1).
          "    config cgit.ignore = 1"
        ])
      ]
      ++ lib.mapAttrsToList mkRepoBlock cfg.repos
    )
    + "\n"
  );

  # cgit's project-list for the public instance: only repos marked public.
  publicRepoNames = builtins.attrNames (lib.filterAttrs (_: r: r.public) cfg.repos);
  publicProjectList = pkgs.writeText "cgit-public-projects" (
    lib.concatMapStringsSep "\n" (n: "${n}.git") publicRepoNames + "\n"
  );

  # Clone URLs shown in the "Clone" box. cgit expands $CGIT_REPO_URL to the
  # repo's path (the name, since remove-suffix is on). The HTTP port is
  # per-instance, so clone-url is set on each instance rather than in common.
  sshCloneUrl = "ssh://git@${cfg.cloneFqdn}:${toString cfg.sshPort}/$CGIT_REPO_URL";
  httpCloneUrl = port: "http://${cfg.cloneFqdn}:${toString port}/$CGIT_REPO_URL";

  # cgit renders each clone URL as <a rel='vcs-git' href='…'>; label only the
  # HTTP one as read-only (HTTP clone is anonymous read-only; SSH is the RW path).
  cloneNote = pkgs.writeText "cgit-head.html" ''
    <style>
      a[rel='vcs-git'][href^='http://']::after { content: ' (read only)'; color: #888; }
    </style>
  '';

  commonCgitSettings = {
    enable-git-config = true; # read cgit.*/gitweb.* from each repo's git config
    remove-suffix = true; # strip the .git suffix in the UI
    section-from-path = 1;
    snapshots = "tar.gz tar.bz2 zip";
    enable-http-clone = true;
    head-include = "${cloneNote}";
    readme = [
      ":README.md"
      ":readme.md"
      ":README"
      ":readme"
    ];
  };
in
{
  options.modules.services.git-server = {
    enable = lib.mkEnableOption "self-hosted git server (gitolite + cgit)";

    adminPubkeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Administrators, as name -> SSH public key. Each gets RW+ on every repo
        and on the gitolite-admin repo. The name is used as the gitolite user
        and the keydir filename.
      '';
    };

    guestPubkeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Guests, as name -> SSH public key. Each gets RW on repos marked
        `public`; no access to private repos.
      '';
    };

    repos = lib.mkOption {
      default = { };
      description = "Repositories to create and serve, keyed by name.";
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            public = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Show in the public cgit instance and grant guests RW.";
            };
            description = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Repository description shown in cgit.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Repository owner shown in cgit.";
            };
          };
        }
      );
    };

    publicPort = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for the public cgit instance (wt0 only).";
    };

    privatePort = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Port for the private cgit instance (wt0 only).";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = ''
        Extra sshd port for gitolite git-over-SSH over the mesh. Port 22 on wt0
        is redirected to Netbird's own SSH (see netbird-agent.nix), so gitolite
        needs a dedicated port. Clone via ssh://git@<host>:<sshPort>/<repo>.
      '';
    };

    cloneFqdn = lib.mkOption {
      type = lib.types.str;
      description = ''
        Hostname shown in cgit clone URLs, e.g. git.example.com. Must resolve
        over wt0 (mesh IP, netbird name, or internal DNS pointing at the wt0
        address). Required, since a wrong value ships a broken clone link.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.adminPubkeys != { };
        message = "modules.services.git-server: at least one adminPubkeys entry is required.";
      }
    ];

    services.gitolite = {
      enable = true;
      user = gitUser;
      inherit dataDir;
      # Seed key only; the reconcile service below rewrites the full keydir.
      adminPubkey = builtins.head (builtins.attrValues cfg.adminPubkeys);
      # Allow `config gitweb.*` / `config cgit.*` lines in gitolite.conf.
      extraGitoliteRc = ''$RC{GIT_CONFIG_KEYS} = ".*";'';
    };

    # Reconcile gitolite to match this Nix config. The generated conf/keydir are
    # store paths embedded in the script, so any change re-runs this on switch.
    systemd.services.git-server-reconcile = {
      description = "Reconcile gitolite config/keydir from Nix";
      after = [ "gitolite-init.service" ];
      requires = [ "gitolite-init.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.gitolite
        pkgs.git
        pkgs.perl
        pkgs.openssh
        pkgs.bash
        pkgs.coreutils
      ];
      # Reuse gitolite-init's RC vars; without GITOLITE_RC_DEFAULT the nixpkgs
      # gitolite wrapper can't find its bindir and dies with "could not fork".
      environment = {
        HOME = dataDir;
        inherit (config.systemd.services.gitolite-init.environment) GITOLITE_RC GITOLITE_RC_DEFAULT;
      };
      serviceConfig = {
        Type = "oneshot";
        User = gitUser;
        Group = config.services.gitolite.group;
        WorkingDirectory = dataDir;
      };
      script = ''
        install -Dm0644 ${gitoliteConf} ${dataDir}/.gitolite/conf/gitolite.conf
        rm -f ${dataDir}/.gitolite/keydir/*.pub
        install -Dm0644 -t ${dataDir}/.gitolite/keydir ${keydir}/*.pub

        # Create repos on `main`. gitolite's `git init` reads init.defaultBranch
        # from the git user's config ($HOME=${dataDir}).
        git config --global init.defaultBranch main

        gitolite compile
        gitolite trigger POST_COMPILE
        gitolite setup

        # Point HEAD at main on any still-unborn repo (fixes repos gitolite
        # already created on `master`). Repos with commits are left untouched.
        for name in ${lib.escapeShellArgs (builtins.attrNames cfg.repos)}; do
          repo=${dataDir}/repositories/"$name".git
          if ! git -C "$repo" rev-parse --verify --quiet HEAD >/dev/null 2>&1; then
            git -C "$repo" symbolic-ref HEAD refs/heads/main
          fi
        done
      '';
    };

    services.cgit = {
      private = {
        enable = true;
        user = gitUser;
        group = config.services.gitolite.group;
        scanPath = "${dataDir}/repositories";
        gitHttpBackend.checkExportOkFiles = false;
        settings = commonCgitSettings // {
          root-title = "Repositories (private)";
          root-desc = "All repositories";
          clone-url = "${sshCloneUrl} ${httpCloneUrl cfg.privatePort}";
        };
      };
      public = {
        enable = true;
        user = gitUser;
        group = config.services.gitolite.group;
        scanPath = "${dataDir}/repositories";
        gitHttpBackend.checkExportOkFiles = false;
        settings = commonCgitSettings // {
          root-title = "Repositories";
          root-desc = "Public repositories";
          project-list = "${publicProjectList}";
          clone-url = "${sshCloneUrl} ${httpCloneUrl cfg.publicPort}";
        };
      };
    };

    # cgit creates services.nginx.virtualHosts.{public,private}; pin their ports.
    services.nginx.virtualHosts.public.listen = lib.mkForce [
      {
        addr = "0.0.0.0";
        port = cfg.publicPort;
      }
    ];
    services.nginx.virtualHosts.private.listen = lib.mkForce [
      {
        addr = "0.0.0.0";
        port = cfg.privatePort;
      }
    ];

    # sshd also listens on sshPort; wt0:22 stays Netbird's (see netbird-agent.nix).
    services.openssh.ports = [
      22
      cfg.sshPort
    ];

    # Reachable only over the Netbird mesh (wt0). Deliberately not added to the
    # global allowedTCPPorts so the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      cfg.publicPort
      cfg.privatePort
      cfg.sshPort
    ];
  };
}
