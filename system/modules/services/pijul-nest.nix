{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.services.pijulNest;
  nest = pkgs.pijul-nest;

  q = s: ''"${s}"'';

  apiConfig = pkgs.writeText "nest-config.toml" ''
    repository_cache_size = ${toString cfg.repositoryCacheSize}
    change_cache_size     = ${toString cfg.changeCacheSize}
    host                  = ${q cfg.domain}
    hostname              = ${q cfg.baseUrl}
    origin                = ${q cfg.baseUrl}
    repositories_path     = ${q "${cfg.dataDir}/repositories"}
    partial_change_size   = ${toString cfg.partialChangeSize}
    basic_size_limit      = ${toString cfg.basicSizeLimit}
    pro_size_limit        = ${toString cfg.proSizeLimit}
    user                  = ${q cfg.user}
    group                 = ${q cfg.group}
    postgres              = ${q cfg.postgres}
    etcd_server           = "localhost:2379"

    [http]
    http_port  = ${toString cfg.httpPort}
    https_port = ${toString (cfg.httpPort + 1)}

    [ssh]
    port = ${toString cfg.sshPort}

    [ci]
    url = []
  '';

  replicationConfig = pkgs.writeText "nest-replication.toml" ''
    repositories = ${q "${cfg.dataDir}/repositories"}
  '';

  # api-start reads secrets from files so they don't land in /proc/*/cmdline or
  # the nix store.  exec replaces the wrapper shell so `nest` becomes MainPID,
  # which makes SIGTERM on stop/restart hit the correct process.
  apiStart = pkgs.writeShellScriptBin "nest-api-start" ''
    export ssh_secret=$(cat /etc/ssh/ssh_host_ed25519_key)
    export PBKDF2_PASSWORD=$(cat ${cfg.pbkdf2PasswordFile})
    export PBKDF2_SALT=$(cat ${cfg.pbkdf2SaltFile})
    export PBKDF2_ITERATIONS=${toString cfg.pbkdf2Iterations}
    export SMTP_PASSWORD=$(cat ${cfg.smtpPasswordFile})
    exec ${nest.bins}/bin/nest --config ${apiConfig} --replication ${replicationConfig}
  '';

  uiStart = pkgs.writeShellScriptBin "nest-ui-start" ''
    export DATABASE_URL=${q cfg.postgres}
    export PBKDF2_PASSWORD=$(cat ${cfg.pbkdf2PasswordFile})
    export PBKDF2_SALT=$(cat ${cfg.pbkdf2SaltFile})
    export PBKDF2_ITERATIONS=${toString cfg.pbkdf2Iterations}
    export NEST_API_INTERNAL="http://127.0.0.1:${toString cfg.httpPort}"
    export HOST="0.0.0.0"
    exec ${pkgs.nodejs}/bin/node ${nest.ui} --report-on-signal --perf-basic-prof-only-functions
  '';

in

{
  options.modules.services.pijulNest = {
    enable = mkEnableOption "Pijul Nest forge (API + SvelteKit UI)";

    dataDir = mkOption {
      type = types.str;
      default = "/mnt/tank/services/pijul";
      description = "Root directory for Nest data (repositories, home dir).";
    };

    domain = mkOption {
      type = types.str;
      description = "Public hostname used in clone URLs and the config.";
    };

    baseUrl = mkOption {
      type = types.str;
      description = "Public origin URL (https://…).";
    };

    postgres = mkOption {
      type = types.str;
      default = "postgres://pijul@127.0.0.1:5432/nest?sslmode=disable";
      description = "PostgreSQL connection URL.";
    };

    httpPort = mkOption {
      type = types.port;
      default = 5000;
      description = "Port the Nest Rust API listens on.";
    };

    uiPort = mkOption {
      type = types.port;
      default = 5050;
      description = "Port the SvelteKit SSR server listens on.";
    };

    sshPort = mkOption {
      type = types.port;
      default = 2224;
      description = "Port advertised for pijul-over-SSH clone/push.";
    };

    repositoryCacheSize = mkOption {
      type = types.ints.unsigned;
      default = 64;
    };

    changeCacheSize = mkOption {
      type = types.ints.unsigned;
      default = 64;
    };

    partialChangeSize = mkOption {
      type = types.ints.unsigned;
      default = 1048576;
    };

    basicSizeLimit = mkOption {
      type = types.int;
      default = 100000000000;
    };

    proSizeLimit = mkOption {
      type = types.int;
      default = 100000000000;
    };

    pbkdf2PasswordFile = mkOption {
      type = types.str;
      description = "Path to file containing the PBKDF2 password (sops secret).";
    };

    pbkdf2SaltFile = mkOption {
      type = types.str;
      description = "Path to file containing the PBKDF2 salt (sops secret).";
    };

    pbkdf2Iterations = mkOption {
      type = types.ints.unsigned;
      default = 1;
    };

    smtpPasswordFile = mkOption {
      type = types.str;
      default = "/dev/null";
      description = "Path to SMTP password file; /dev/null disables email.";
    };

    user = mkOption {
      type = types.str;
      default = "nest";
    };

    group = mkOption {
      type = types.str;
      default = "nest";
    };

    exposeInternal = mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = mkOption {
      type = types.str;
      default = "pijul";
      description = "Subdomain under the internal proxy domain.";
    };
  };

  config = mkIf cfg.enable {

    # ── Users ──────────────────────────────────────────────────────────────────
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = "${cfg.dataDir}/home";
    };
    users.groups.${cfg.group} = { };

    # ── Storage ────────────────────────────────────────────────────────────────
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}              0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/repositories 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/home         0750 ${cfg.user} ${cfg.group} -"
    ];

    # ── etcd ───────────────────────────────────────────────────────────────────
    services.etcd = {
      enable = true;
      listenClientUrls = [ "http://127.0.0.1:2379" ];
      advertiseClientUrls = [ "http://127.0.0.1:2379" ];
    };

    # ── PostgreSQL ─────────────────────────────────────────────────────────────
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nest" ];
      ensureUsers = [ { name = cfg.user; ensureDBOwnership = false; } ];
      # Trust loopback connections so the API (running as root) and the
      # preStart script (running as postgres) can both connect over TCP
      # without passwords.
      authentication = mkOverride 10 ''
        local all all trust
        host  all all 127.0.0.1/32 trust
        host  all all ::1/128      trust
      '';
    };

    # ── pijul binary in PATH for SSH-based push/clone ──────────────────────────
    environment.systemPackages = [ pkgs.pijul ];

    # ── Nest API ───────────────────────────────────────────────────────────────
    systemd.services."nest-api" = {
      description = "Pijul Nest API server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" "etcd.service" ];
      wants = [ "postgresql.service" "etcd.service" ];
      unitConfig.RequiresMountsFor = [ cfg.dataDir ];

      path = with pkgs; [ postgresql diesel-cli rustfmt nix bash which ncurses ];

      environment = {
        RUST_BACKTRACE = "full";
        RUST_LOG = "nest=info";
        HOME = "${cfg.dataDir}/home";
        TERM = "vt100";
        DATABASE_URL = cfg.postgres;
      };

      # Create PostgreSQL user/DB and run Diesel migrations on every activation.
      # Using the postgres superuser via trust-loopback so no password is needed.
      preStart = ''
        createuser -h 127.0.0.1 -U postgres ${cfg.user} || true
        # The upstream migration SQL hardcodes GRANT ... TO pijul; this role must
        # exist for the migration to succeed even when the runtime user is different.
        createuser -h 127.0.0.1 -U postgres pijul || true
        createdb   -h 127.0.0.1 -U postgres -O ${cfg.user} nest || true
        # Use a minimal diesel.toml without [print_schema] so diesel does not try
        # to write db.rs back into the read-only nix store after running migrations.
        _diesel_cfg=$(mktemp)
        echo '[migrations_directory]' > "$_diesel_cfg"
        echo 'dir = "${nest.migrations}/migrations"' >> "$_diesel_cfg"
        DATABASE_URL="postgres://postgres@127.0.0.1:5432/nest?sslmode=disable" \
          diesel migration run \
            --migration-dir ${nest.migrations}/migrations \
            --config-file   "$_diesel_cfg"
        rm -f "$_diesel_cfg"
      '';

      serviceConfig = {
        ExecStart = "${apiStart}/bin/nest-api-start";
        # Must run as root to read /etc/ssh/ssh_host_ed25519_key.
        User = "root";
        Restart = "always";
        RestartSec = 5;
        KillMode = "process";
      };
    };

    # ── Nest UI (SvelteKit SSR) ────────────────────────────────────────────────
    systemd.services."nest-ui" = {
      description = "Pijul Nest UI (SvelteKit SSR)";
      wantedBy = [ "multi-user.target" ];
      after = [ "nest-api.service" ];

      environment.PORT = toString cfg.uiPort;
      environment.ORIGIN = cfg.baseUrl;

      path = [ pkgs.openssl ];

      serviceConfig = {
        ExecStart = "${uiStart}/bin/nest-ui-start";
        User = cfg.user;
        Restart = "always";
        RestartSec = 5;
        OOMPolicy = "stop";
      };
    };

    # ── Nest Rank (PageRank timer) ─────────────────────────────────────────────
    systemd.services."nest-rank" = {
      description = "Pijul Nest PageRank";
      after = [ "nest-api.service" ];
      environment.DATABASE_URL = cfg.postgres;
      serviceConfig = {
        ExecStart = "${nest.bins}/bin/nest-rank";
        User = cfg.user;
        Type = "oneshot";
        Environment = "RUST_LOG=nest_rank=info";
      };
    };

    systemd.timers."nest-rank" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "6h";
        Unit = "nest-rank.service";
      };
    };

    # ── Firewall ───────────────────────────────────────────────────────────────
    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.sshPort cfg.httpPort cfg.uiPort ];

    # ── Caddy (multi-backend routing) ─────────────────────────────────────────
    # The Rust API handles /api*, /login*, /register*, and the pijul protocol
    # path.  Everything else — including static assets — goes to the SvelteKit
    # SSR server, which serves them from the nix store via its built-in handler.
    services.caddy.virtualHosts = mkIf cfg.exposeInternal {
      "${cfg.internalSubdomain}.${config.modules.services.internalProxy.domain}" = {
        extraConfig = ''
          @nestApi {
            path /api* /login* /register*
          }
          @pijulProto {
            path_regexp ^/[^/]+/[^/]+/\.pijul
          }
          handle @nestApi {
            reverse_proxy localhost:${toString cfg.httpPort}
          }
          handle @pijulProto {
            reverse_proxy localhost:${toString cfg.httpPort}
          }
          handle {
            reverse_proxy localhost:${toString cfg.uiPort}
          }
        '';
      };
    };
  };
}
