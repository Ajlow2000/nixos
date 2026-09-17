{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.internalProxy;

  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
    hash = "sha256-dQvk6ezY6TQ1J7PjhCXnThF/SqVgPwBO8/RXzHCY+js=";
  };
in
{
  options.modules.services.internalProxy = {
    enable = lib.mkEnableOption "internal Caddy reverse proxy on wt0";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "internal.aleclowry.com";
      description = "Base domain for internal services (wildcard cert is issued for *.domain).";
    };

    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Map of subdomain name to backend address.";
      example = {
        immich = "localhost:2283";
        mealie = "localhost:9000";
      };
    };

    autheliaUrl = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Authelia base URL for forward auth (e.g. http://glados:9091). Empty disables forward auth.";
    };

    protectedVirtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Virtual hosts that require Authelia forward auth before proxying.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."cloudflare-api-token" = {
      key = "cloudflare/api-token";
    };

    # Render the raw token into a KEY=VALUE env file that systemd can consume.
    sops.templates."caddy-cloudflare-env" = {
      content = "CF_API_TOKEN=${config.sops.placeholder."cloudflare-api-token"}\n";
      owner = "caddy";
      mode = "0400";
    };

    services.caddy = {
      enable = true;
      package = caddyWithCloudflare;
      # Global ACME config: single DNS-01 wildcard challenge for *.domain.
      # Works for internal-only services — no inbound HTTP required.
      globalConfig = ''
        acme_dns cloudflare {env.CF_API_TOKEN}
      '';
      virtualHosts =
        lib.mapAttrs' (name: backend: {
          name = "${name}.${cfg.domain}";
          value.extraConfig = "reverse_proxy ${backend}";
        }) cfg.virtualHosts
        // lib.optionalAttrs (cfg.autheliaUrl != "")
           (lib.mapAttrs' (name: backend: {
             name = "${name}.${cfg.domain}";
             value.extraConfig = ''
               forward_auth ${cfg.autheliaUrl} {
                 uri /api/authz/forward-auth
                 copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
               }
               reverse_proxy ${backend}
             '';
           }) cfg.protectedVirtualHosts);
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      config.sops.templates."caddy-cloudflare-env".path
    ];

    # HTTPS on wt0 only — consistent with every other glados service.
    networking.firewall.interfaces.wt0.allowedTCPPorts = [
      80
      443
    ];
  };
}
