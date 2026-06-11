# Self-hosted git server: gitolite backend + two cgit web UIs.
#
# Two cgit instances scan the same repo dir:
#   - `private` (port `cfg.port`)        — shows everything.
#   - `public`  (port `cfg.publicPort`)  — shows only repos whose bare dir
#                                          contains `git-daemon-export-ok`
#                                          (via cgit `strict-export`).
# Both bind to wt0 only. The intent is to route `publicPort` to the internet
# externally (e.g. Netbird routing); this module keeps the firewall closed.
#
# A repo opts into the public instance by setting `config gitweb.public = "1"`
# in its `gitolite.conf` stanza. A POST_COMPILE trigger (see `markerTrigger`)
# walks all bare repos after each gitolite recompile and touches/removes the
# export marker to match. Default is private (marker absent).
#
# Admin keys are managed declaratively via `adminPubkeys` (attrset where the
# attribute name becomes the user's gitolite identity). Whichever name sorts
# first is used as gitolite's bootstrap key; a one-shot systemd service then
# clones gitolite-admin server-side and rewrites keydir/ + the gitolite-admin
# RW+ list to match the nix-declared set exactly.
#
# First-time setup:
#   1. nixos-rebuild switch (materializes /srv/git, bootstraps gitolite, and
#      runs git-server-admin-sync to align gitolite-admin with adminPubkeys)
#   2. From any machine whose SSH key is listed in `adminPubkeys`:
#        git clone gitolite@hal9000:gitolite-admin
#      (resolve `hal9000` over the Netbird mesh — Netbird IP or hosts entry)
#   3. Edit conf/gitolite.conf to declare non-admin repos:
#        repo testing
#          RW+ = ajlow
#          config gitweb.owner = "ajlow"
#          config gitweb.description = "first test repo"
#          config gitweb.public = "1"          # omit to keep private
#      Commit + push. Gitolite materializes the bare repo server-side and the
#      marker trigger toggles its visibility on the public instance.
#   4. Browse: http://<hal9000-wt0-ip>:<cfg.port>/        (private)
#             http://<hal9000-wt0-ip>:<cfg.publicPort>/  (public)
#
# Verification:
#   - systemctl status gitolite-init gitolite-admin-sync   (active/exited)
#   - sudo -u gitolite ls /srv/git/repositories
#   - sudo -u gitolite git -C /srv/git/repositories/gitolite-admin.git \
#       show HEAD:conf/gitolite.conf | grep gitolite-admin -A2
#   - curl http://localhost:8082/                          (HTML repo index)
#   - On a repo's "about" page: README renders, ```mermaid blocks become
#     diagrams, relative <img> paths load from /<repo>/plain/…
#   - Source files have inline syntax highlighting in the tree view.
#
# Deferred TODOs:
#   - Vendor mermaid.esm.min.mjs into the Nix store instead of using the CDN
#   - Move to a dedicated host once one exists (this module is host-agnostic)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.git-server;

  # Stage 2 of the about-filter pipeline. Reads HTML on stdin and:
  #   - Rewrites ```mermaid fenced blocks (which cmark-gfm emits as
  #     <pre><code class="language-mermaid">…</code></pre>) into
  #     <div class="mermaid">…</div> for mermaid.js to pick up.
  #   - Rewrites relative <img src="…"> to /$CGIT_REPO_URL/plain/… so README
  #     image references resolve against the repo's plain view rather than
  #     against the about-page URL.
  #   - Appends a single <script> that loads mermaid.js from a CDN.
  aboutFilterPerl = pkgs.writeText "cgit-about-filter.pl" ''
    use strict;
    use warnings;
    my $repo = $ENV{CGIT_REPO_URL} // "";
    local $/;
    my $html = <STDIN>;
    $html =~ s|<pre><code class="language-mermaid">(.*?)</code></pre>|<div class="mermaid">$1</div>|gs;
    $html =~ s{<img([^>]*?)\s+src="(?!https?://|/|data:)([^"]+)"}{<img$1 src="/$repo/plain/$2"}g;
    print $html;
    print qq(<script type="module">\n);
    print qq(  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid\@10/dist/mermaid.esm.min.mjs";\n);
    print qq(  mermaid.initialize({startOnLoad: true});\n);
    print qq(</script>\n);
  '';

  aboutFilter = pkgs.writeShellApplication {
    name = "cgit-about-filter";
    runtimeInputs = [
      pkgs.cmark-gfm
      pkgs.perl
    ];
    text = ''
      cmark-gfm \
        --unsafe \
        --extension table \
        --extension autolink \
        --extension strikethrough \
        --extension tasklist \
      | perl ${aboutFilterPerl}
    '';
  };

  # cgit invokes source filters with the filename as $1 and file contents
  # on stdin. -I emits inline CSS so we don't need a separate token-color
  # stylesheet.
  sourceFilter = pkgs.writeShellScript "cgit-source-filter" ''
    exec ${pkgs.highlight}/bin/highlight \
      --force -f -I -O xhtml \
      --syntax-by-name="$1" 2>/dev/null
  '';

  # Settings shared by both cgit instances. Per-instance overrides (title,
  # strict-export) are merged on top.
  commonCgitSettings = {
    readme = ":README.md :readme.md :README";
    about-filter = "${aboutFilter}/bin/cgit-about-filter";
    source-filter = "${sourceFilter}";
    enable-blame = 1;
    enable-commit-graph = 1;
    enable-log-filecount = 1;
    enable-log-linecount = 1;
    enable-index-links = 1;
    enable-tree-linenumbers = 1;
    side-by-side-diffs = 1;
    snapshots = "tar.gz zip";
    max-stats = "quarter";
  };

  # POST_COMPILE trigger: for each bare repo under repositories/, touch
  # `git-daemon-export-ok` iff the repo has `gitweb.public` truthy in its
  # gitolite config (set via `config gitweb.public = "1"` in gitolite.conf,
  # materialized by the upstream `update-git-configs` trigger that runs
  # earlier in POST_COMPILE). cgit's public instance honors this marker via
  # `strict-export`; the private instance ignores it.
  markerTrigger = pkgs.writeShellScript "cgit-export-marker" ''
    set -eu
    base=${cfg.dataDir}/repositories
    [ -d "$base" ] || exit 0
    ${pkgs.findutils}/bin/find "$base" -type d -name '*.git' | while read -r repo; do
      pub=$(${pkgs.git}/bin/git -C "$repo" config --bool gitweb.public 2>/dev/null || echo false)
      marker="$repo/git-daemon-export-ok"
      if [ "$pub" = "true" ]; then
        ${pkgs.coreutils}/bin/touch "$marker"
      else
        ${pkgs.coreutils}/bin/rm -f "$marker"
      fi
    done
  '';

  # Gitolite resolves trigger names via `_which("triggers/$name")`, which
  # only searches `$GL_BINDIR/triggers/` and `$LOCAL_CODE/triggers/`. We
  # can't write to GL_BINDIR (read-only nix store path of pkgs.gitolite),
  # so build a tiny LOCAL_CODE tree containing just our trigger under the
  # required `triggers/` subdir.
  gitoliteLocalCode = pkgs.runCommand "gitolite-local-code" { } ''
    mkdir -p $out/triggers
    install -m 0555 ${markerTrigger} $out/triggers/cgit-export-marker
  '';

  adminNames = lib.attrNames cfg.adminPubkeys;
  bootstrapName = lib.head (lib.sort lib.lessThan adminNames);
  bootstrapPubkey = cfg.adminPubkeys.${bootstrapName};
  adminListSpace = lib.concatStringsSep " " adminNames;

  adminPubkeysJson = pkgs.writeText "git-server-admin-pubkeys.json" (
    builtins.toJSON cfg.adminPubkeys
  );
in
{
  options.modules.services.git-server = {
    enable = lib.mkEnableOption "self-hosted git server (gitolite + cgit)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = ''
        Port the private cgit nginx vhost listens on. Bound only to wt0;
        shows every repo regardless of export marker.
      '';
    };

    publicPort = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = ''
        Port the public cgit nginx vhost listens on. Still bound only to
        wt0 by this module — route to the public internet externally
        (e.g. Netbird routing). Only shows repos with
        `config gitweb.public = "1"` in gitolite.conf.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/srv/git";
      description = "Where gitolite stores its state and bare repos.";
    };

    adminPubkeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = ''
        SSH public keys that should have admin rights — RW+ on the
        `gitolite-admin` repo. The attribute name becomes the user's gitolite
        identity (e.g. `microvac`, `hal9000`).

        The alphabetically-first name is used as gitolite's bootstrap key; a
        post-init systemd service then renames it and adds the remaining keys
        so that gitolite-admin's keydir/ and `RW+ = …` line match this attrset
        exactly.
      '';
      example = lib.literalExpression ''
        {
          microvac = "ssh-ed25519 AAAA...";
          hal9000  = "ssh-ed25519 AAAA...";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.adminPubkeys != { };
        message = "modules.services.git-server.adminPubkeys must contain at least one key.";
      }
    ];

    # The NixOS gitolite module only auto-creates its dataDir (via systemd
    # StateDirectory) when dataDir is at its default. With a custom path
    # we materialize it ourselves so gitolite-init can chdir in.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 gitolite gitolite -"
    ];

    services.gitolite = {
      enable = true;
      dataDir = cfg.dataDir;
      user = "gitolite";
      adminPubkey = bootstrapPubkey;
      # UMASK 0027 → new repos are group-readable (0750) so the cgit user
      # (added to the gitolite group below) can serve them via the web UI.
      #
      # GIT_CONFIG_KEYS '.*' → allow any `config foo.bar = …` line in
      # gitolite.conf. Defaults to empty (all rejected), which kills
      # compile on common stanzas like `config gitweb.description = …`.
      # Sole-admin personal box, so unconstrained is fine.
      #
      # Append our marker trigger to POST_COMPILE so the export marker tracks
      # `config gitweb.public` after every recompile. Order matters: it
      # appends, so it runs after the built-in `update-git-configs` which
      # is what writes `gitweb.public` into each bare repo's git config.
      # Trigger names are bare; gitolite resolves them under
      # `$LOCAL_CODE/triggers/` (preferred) or `$GL_BINDIR/triggers/`.
      #
      # Two trigger-list adjustments here, both of which have to happen
      # in `extraGitoliteRc` (the user rc file) because gitolite's
      # `non_core_expand()` walks ENABLE *after* the rc file has been
      # `do`'d, and POST_COMPILE / POST_CREATE arrays don't even exist
      # yet at that point:
      #
      #   - Drop the built-in 'daemon' feature: its post-compile
      #     trigger writes `git-daemon-export-ok` based on whether
      #     gitolite's `daemon` pseudo-user has R access (implicit
      #     for `@all`). We don't run git-daemon, and we want
      #     `gitweb.public` to be the sole visibility switch for the
      #     public cgit instance.
      #
      #   - Register our `cgit-export-marker` trigger via NON_CORE +
      #     ENABLE so non_core_expand appends it to POST_COMPILE in
      #     order. Appending matters: it must run *after* the
      #     built-in `git-config` trigger, which is what writes the
      #     `gitweb.public` value into each repo's git config.
      extraGitoliteRc = ''
        $RC{UMASK} = 0027;
        $RC{GIT_CONFIG_KEYS} = '.*';
        $RC{LOCAL_CODE} = '${gitoliteLocalCode}';
        @{$RC{ENABLE}} = grep { $_ ne 'daemon' } @{$RC{ENABLE}};
        $RC{NON_CORE} = "cgit-export-marker POST_COMPILE .\n";
        push @{$RC{ENABLE}}, 'cgit-export-marker';
      '';
    };

    # One-shot: after gitolite-init lays down its default gitolite-admin
    # (with one user named "admin"), align keydir/ and the gitolite-admin
    # RW+ list with the nix-declared adminPubkeys attrset. Idempotent — if
    # nothing changed since the last boot, no commit is produced.
    systemd.services.gitolite-admin-sync = {
      description = "Sync gitolite admin keys from nix config";
      after = [ "gitolite-init.service" ];
      requires = [ "gitolite-init.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        git
        gawk
        coreutils
        jq
        findutils
        # The bare repo's post-update hook spawns `gitolite compile` /
        # `gitolite trigger SSH_AUTHKEYS` to regenerate authorized_keys
        # from keydir; needs the gitolite binary on PATH and ssh-keygen
        # for pubkey fingerprinting.
        gitolite
        openssh
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "gitolite";
        Group = "gitolite";
        RemainAfterExit = true;
      };
      script = ''
        set -eu
        WORK=$(mktemp -d)
        trap 'rm -rf "$WORK"' EXIT

        cd "$WORK"
        git clone "${cfg.dataDir}/repositories/gitolite-admin.git" admin
        cd admin
        git config user.email 'admin-sync@gitolite.local'
        git config user.name  'gitolite-admin-sync'

        # Wipe stale top-level admin keys; nix is the source of truth here.
        # Deeper paths (keydir/<subdir>/...) belong to non-admin users and
        # are managed via the gitolite-admin repo itself, so leave them be.
        find keydir -maxdepth 1 -type f -name '*.pub' -delete

        # Write fresh admin pubkeys from the nix-rendered JSON.
        jq -r 'to_entries[] | "\(.key)\t\(.value)"' ${adminPubkeysJson} \
          | while IFS=$'\t' read -r name key; do
              printf '%s\n' "$key" > "keydir/$name.pub"
            done

        # Rewrite the gitolite-admin RW+ line to enumerate exactly our admins.
        # Scoped to the `repo gitolite-admin` block so other repo rules in
        # this conf (managed by humans via gitolite-admin) stay untouched.
        awk -v admins='${adminListSpace}' '
          BEGIN { in_admin = 0 }
          /^repo gitolite-admin/ { in_admin = 1; print; next }
          /^repo / && in_admin { in_admin = 0 }
          in_admin && /^[[:space:]]*RW\+[[:space:]]*=/ {
            sub(/=.*/, "=   " admins)
            print
            next
          }
          { print }
        ' conf/gitolite.conf > conf/gitolite.conf.new
        mv conf/gitolite.conf.new conf/gitolite.conf

        git add -A
        if ! git diff --cached --quiet; then
          git commit -m 'gitolite-admin-sync: align with nix-declared admins'
          # The bare repo's update hook is gitolite's Perl script that loads
          # modules from GL_LIBDIR and validates the pushing GL_USER against
          # the ACL. A local push inherits this process's env, so:
          #   - point GL_BINDIR/GL_LIBDIR at the gitolite package so the
          #     hook's `use lib $ENV{GL_LIBDIR}` resolves
          #   - set GL_BYPASS_ACCESS_CHECKS=1 so the hook returns immediately
          #     without an ACL lookup (this sync IS the ACL change; there's
          #     no real user pushing)
          export GL_BINDIR=${pkgs.gitolite}/bin
          export GL_LIBDIR=${pkgs.gitolite}/bin/lib
          export GL_BYPASS_ACCESS_CHECKS=1
          git push origin HEAD
        fi

        # Unconditional reconciliation: extract the bare repo's master tree
        # into GL_ADMIN_BASE and rebuild authorized_keys. The push's
        # post-update hook normally does this, but doing it here too means:
        #   - a partial prior run (push landed, post-update bailed) heals on
        #     the next activation, even when there's no fresh diff to push
        #   - drift between bare repo HEAD and ~/.gitolite/ from any other
        #     cause gets corrected idempotently
        # Both ops are no-ops when state already matches.
        GIT_DIR="${cfg.dataDir}/repositories/gitolite-admin.git" \
        GIT_WORK_TREE="${cfg.dataDir}/.gitolite" \
          git read-tree --reset -u master
        gitolite compile
        gitolite trigger POST_COMPILE
      '';
    };

    # Give cgit's CGI process read access to gitolite-owned repos.
    users.users.cgit.extraGroups = [ "gitolite" ];

    # SSH-only pushes/clones via gitolite — no smart HTTP needed. Disabling
    # gitHttpBackend on both instances also sidesteps the cgit module's
    # checkExportOkFiles assertion, since gitolite repos don't carry the
    # `git-daemon-export-ok` marker by default (the marker we manage above
    # is for cgit's `strict-export`, not for git-http-backend).
    services.cgit."private" = {
      enable = true;
      scanPath = "${cfg.dataDir}/repositories";
      nginx.virtualHost = "git-private";
      gitHttpBackend.enable = false;
      settings = commonCgitSettings // {
        root-title = "ajlow's git";
        root-desc = "All repositories";
      };
    };

    services.cgit."public" = {
      enable = true;
      scanPath = "${cfg.dataDir}/repositories";
      nginx.virtualHost = "git-public";
      gitHttpBackend.enable = false;
      settings = commonCgitSettings // {
        root-title = "ajlow's public git";
        root-desc = "Public repositories";
        # Only show repos whose bare dir contains this marker file. The
        # POST_COMPILE trigger above maintains the marker against the
        # `gitweb.public` per-repo config.
        strict-export = "git-daemon-export-ok";
      };
    };

    services.nginx.virtualHosts."git-private" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = cfg.port;
        }
      ];
    };

    services.nginx.virtualHosts."git-public" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = cfg.publicPort;
        }
      ];
    };

    # Both vhosts reach only over the Netbird mesh (wt0). Deliberately not
    # added to the global allowedTCPPorts — exposing the public one to the
    # internet is the operator's call (e.g. Netbird routing).
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      cfg.port
      cfg.publicPort
    ];
  };
}
