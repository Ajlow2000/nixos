{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.traefik;
  # Cloudflare token is a per-host secret (secrets/hosts/<hostName>.yaml),
  # matching the pattern in system/modules/sops.nix.
  hostFile = ../../../secrets/hosts + "/${config.networking.hostName}.yaml";
in
{
  options.modules.services.traefik = {
    enable = lib.mkEnableOption "Traefik reverse proxy (mesh-internal, TLS)";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "glados.aleclowry.com";
      description = ''
        Base domain for proxied services. Each service is served at
        <service>.<domain>, covered by a single Let's Encrypt wildcard cert
        (*.<domain>) obtained via the Cloudflare DNS-01 challenge.
      '';
    };

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      description = "Contact address for the Let's Encrypt account (expiry notices).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.traefik = {
        enable = true;

        staticConfigOptions = {
          entryPoints.web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          entryPoints.websecure.address = ":443";

          certificatesResolvers.letsencrypt.acme = {
            email = cfg.acmeEmail;
            storage = "${config.services.traefik.dataDir}/acme.json";
            # Services aren't publicly reachable, so HTTP-01 can't work — use
            # DNS-01 via Cloudflare (CF_DNS_API_TOKEN comes from the env file below).
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [
                "1.1.1.1:53"
                "8.8.8.8:53"
              ];
            };
          };
        };

        dynamicConfigOptions.http = {
          routers.immich = {
            rule = "Host(`immich.${cfg.domain}`)";
            entryPoints = [ "websecure" ];
            service = "immich";
            tls = {
              certResolver = "letsencrypt";
              # One wildcard cert for every <service>.<domain>.
              domains = [
                {
                  main = cfg.domain;
                  sans = [ "*.${cfg.domain}" ];
                }
              ];
            };
          };
          services.immich.loadBalancer.servers = [
            { url = "http://127.0.0.1:2283"; }
          ];
        };
      };

      # Reachable only over the Netbird mesh (wt0). Public interface stays closed.
      networking.firewall.interfaces.wt0.allowedTCPPorts = [
        80
        443
      ];
    }

    # Cloudflare API token for the DNS-01 challenge, rendered into an env file
    # traefik loads (lego reads CF_DNS_API_TOKEN). Only when sops is available.
    (lib.mkIf config.modules.sops.enable {
      sops.secrets."cloudflare-dns-token" = {
        key = "cloudflare_dns_api_token";
        sopsFile = hostFile;
      };
      sops.templates."traefik-cf.env".content = ''
        CF_DNS_API_TOKEN=${config.sops.placeholder."cloudflare-dns-token"}
      '';
      services.traefik.environmentFiles = [
        config.sops.templates."traefik-cf.env".path
      ];
    })
  ]);
}
