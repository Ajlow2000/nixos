# Self-hosted git server: gitolite backend + cgit web UI.
#
# First-time setup:
#   1. nixos-rebuild switch (materializes /srv/git and bootstraps gitolite
#      with the admin key configured here)
#   2. From a machine whose SSH key matches `adminPubkey`:
#        git clone gitolite@hal9000:gitolite-admin
#      (resolve `hal9000` over the Netbird mesh — Netbird IP or hosts entry)
#   3. Edit conf/gitolite.conf to declare repos:
#        repo testing
#          RW+ = ajlow
#          config gitweb.owner = "ajlow"
#          config gitweb.description = "first test repo"
#      Commit + push. Gitolite materializes the bare repo server-side.
#   4. Browse: http://<hal9000-wt0-ip>:8082/
#
# Verification:
#   - systemctl status gitolite-init   (active, exited)
#   - sudo -u gitolite ls /srv/git/repositories
#   - curl http://localhost:8082/      (HTML index of repos)
#   - On a repo's "about" page: README renders, ```mermaid blocks become
#     diagrams, relative <img> paths load from /<repo>/plain/…
#   - Source files have inline syntax highlighting in the tree view.
#
# Deferred TODOs:
#   - Vendor mermaid.esm.min.mjs into the Nix store instead of using the CDN
#   - Move to a dedicated host once one exists (this module is host-agnostic)
#   - Iterate on customCssBody for theming once the rest is verified
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.git-server;

  customCssBody = ''
    body { background: #1d2021; color: #ebdbb2; font-family: sans-serif; }
    a { color: #83a598; }
    a:visited { color: #b16286; }
    div#cgit table#header { background: #282828; color: #fbf1c7; }
    div#cgit table#header a { color: #fabd2f; }
    div.cgit-panel { background: #282828; color: #ebdbb2; }
    pre, code { background: #282828; color: #ebdbb2; }
    div.commit-subject { color: #fbf1c7; }
    table.list tr:nth-child(even) { background: #282828; }
    table.list tr:hover { background: #3c3836; }
    table.list tr.nohover:hover { background: inherit; }
    table.diff td.add { background: #32361a; }
    table.diff td.del { background: #421e1e; }
  '';

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
    print qq(  mermaid.initialize({startOnLoad: true, theme: "dark"});\n);
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
      --syntax-by-name="$1" \
      --style=base16/gruvbox-dark-hard 2>/dev/null
  '';
in
{
  options.modules.services.git-server = {
    enable = lib.mkEnableOption "self-hosted git server (gitolite + cgit)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Port the cgit nginx vhost listens on (Netbird-only).";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/srv/git";
      description = "Where gitolite stores its state and bare repos.";
    };

    adminPubkey = lib.mkOption {
      type = lib.types.str;
      description = ''
        SSH public key for the initial gitolite admin user. The holder of
        this key can clone the gitolite-admin repo to manage repos & ACLs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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
      adminPubkey = cfg.adminPubkey;
      # UMASK 0027 → new repos are group-readable (0750) so the cgit user
      # (added to the gitolite group below) can serve them via the web UI.
      extraGitoliteRc = ''
        $RC{UMASK} = 0027;
      '';
    };

    # Give cgit's CGI process read access to gitolite-owned repos.
    users.users.cgit.extraGroups = [ "gitolite" ];

    services.cgit."main" = {
      enable = true;
      scanPath = "${cfg.dataDir}/repositories";
      nginx.virtualHost = "git";
      settings = {
        root-title = "ajlow's git";
        root-desc = "Self-hosted repositories";
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
    };

    # The cgit module declares /cgit.css with mkDefault; override the alias
    # to serve our themed stylesheet instead of the upstream default.
    services.nginx.virtualHosts."git" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = cfg.port;
        }
      ];
      locations."= /cgit.css".alias = lib.mkForce (
        toString (pkgs.writeText "cgit.css" customCssBody)
      );
    };

    # Reachable only over the Netbird mesh (wt0). Deliberately not added
    # to the global allowedTCPPorts — the public interface stays closed.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];
  };
}
