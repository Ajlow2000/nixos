{ inputs, lib, config, ... }:
{
  imports = [
    ../../profiles/digital-ocean.nix
    ../../modules/services/uptime-kuma.nix
    ../../modules/services/glance.nix
    ../../modules/services/internal-proxy.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  profiles.system.digital-ocean.enable = true;
  modules.services.uptime-kuma.enable = true;
  modules.services.glance.enable = true;

  sops.secrets."netbird-api-key" = { key = "netbird/api-token"; };
  sops.templates."glance-env" = {
    content = "NETBIRD_API_KEY=${config.sops.placeholder."netbird-api-key"}\n";
    owner = "glance";
    mode = "0400";
  };
  systemd.services.glance.serviceConfig.EnvironmentFile = [
    config.sops.templates."glance-env".path
  ];
  services.glance.settings.pages = lib.mkForce [
    {
      name = "Home";
      columns = [
        {
          size = "full";
          widgets = [
            { type = "clock"; }
          ];
        }
        {
          size = "small";
          widgets = [
            {
              type = "bookmarks";
              groups = [
                {
                  title = "Services";
                  links = [
                    { title = "Immich";  url = "https://immich.internal.aleclowry.com"; }
                    { title = "Git";     url = "https://git.internal.aleclowry.com"; }
                    { title = "Mealie";  url = "https://mealie.internal.aleclowry.com"; }
                    { title = "Pijul";   url = "https://pijul.internal.aleclowry.com"; }
                    { title = "Lore";    url = "https://lore.internal.aleclowry.com"; }
                  ];
                }
                {
                  title = "Admin";
                  links = [
                    { title = "Uptime Kuma"; url = "https://uptime.internal.aleclowry.com"; }
                  ];
                }
              ];
            }
          ];
        }
      ];
    }
    {
      name = "Hosts";
      columns = [
        {
          size = "full";
          widgets = [
            {
              type = "server-stats";
              servers = [
                { type = "local";  name = "do-prod-01"; }
                { type = "remote"; name = "glados";   url = "http://glados:27973"; }
                { type = "remote"; name = "hal9000";  url = "http://hal9000:27973"; }
                { type = "remote"; name = "eddie";    url = "http://eddie:27973"; }
                { type = "remote"; name = "marvin";   url = "http://marvin:27973"; }
                { type = "remote"; name = "microvac"; url = "http://microvac:27973"; }
                { type = "remote"; name = "mindgame"; url = "http://mindgame:27973"; }
                { type = "remote"; name = "multivac"; url = "http://multivac:27973"; }
              ];
            }
            {
              type = "custom-api";
              title = "Netbird Devices";
              "title-url" = "https://app.netbird.io/peers";
              url = "https://api.netbird.io/api/peers";
              headers = {
                Accept = "application/json";
                Authorization = "Token \${NETBIRD_API_KEY}";
              };
              cache = "10m";
              template = ''
                {{ $enableOnlineIndicator := false }}

                <style>
                  .device-info-container {
                    position: relative;
                    overflow: hidden;
                    height: 1.5em;
                  }
                  .device-info {
                    display: flex;
                    transition: transform 0.2s ease, opacity 0.2s ease;
                  }
                  .device-ip {
                    position: absolute;
                    top: 0;
                    left: 0;
                    transform: translateY(-100%);
                    opacity: 0;
                    transition: transform 0.2s ease, opacity 0.2s ease;
                  }
                  .device-info-container:hover .device-info {
                    transform: translateY(100%);
                    opacity: 0;
                  }
                  .device-info-container:hover .device-ip {
                    transform: translateY(0);
                    opacity: 1;
                  }
                  .offline-indicator,
                  .online-indicator {
                    width: 8px;
                    height: 8px;
                    border-radius: 50%;
                    display: inline-block;
                    margin-left: 4px;
                    vertical-align: middle;
                  }
                  .online-indicator  { background-color: var(--color-positive); }
                  .offline-indicator { background-color: var(--color-negative); }
                  .device-name-container {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    min-width: 0;
                  }
                  .indicators-container {
                    display: flex;
                    align-items: center;
                    gap: 4px;
                  }
                </style>

                <ul class="list list-gap-10">
                  {{ range .JSON.Array "" }}
                  <li>
                    <div class="flex items-center gap-10">
                      <div class="device-name-container grow">
                        <span class="size-h4 block text-truncate color-primary">
                          {{ .String "hostname" }}
                        </span>
                        <div class="indicators-container">
                          {{ if .Bool "connected" }}
                            {{ if $enableOnlineIndicator }}
                            <span class="online-indicator" data-popover-type="text" data-popover-text="Online"></span>
                            {{ end }}
                          {{ else }}
                            {{ $lastSeen := .String "last_seen" | parseTime "rfc3339" }}
                            <span class="offline-indicator" data-popover-type="text" data-popover-text="Offline - Last seen {{ $lastSeen.Format "Jan 2 3:04pm" }}"></span>
                          {{ end }}
                        </div>
                      </div>
                    </div>
                    <div class="device-info-container">
                      <ul class="list-horizontal-text device-info">
                        <li>{{ .String "os" }}</li>
                        <li>{{ .String "city_name" }}, {{ .String "country_code" }}</li>
                      </ul>
                      <div class="device-ip">
                        {{ .String "ip" }}
                        {{ .String "dns_label" }}
                      </div>
                    </div>
                  </li>
                  {{ end }}
                </ul>
              '';
            }
          ];
        }
      ];
    }

    {
      name = "Services";
      columns = [
        {
          size = "full";
          widgets = [
            {
              type = "monitor";
              cache = "1m";
              title = "Services";
              sites = [
                { title = "Uptime Kuma"; url = "https://uptime.internal.aleclowry.com"; }
                { title = "Immich";      url = "https://immich.internal.aleclowry.com"; }
                { title = "Forgejo";     url = "https://git.internal.aleclowry.com"; }
                { title = "Mealie";      url = "https://mealie.internal.aleclowry.com"; }
                { title = "Pijul Nest";  url = "https://pijul.internal.aleclowry.com"; }
                { title = "Lore";        url = "https://lore.internal.aleclowry.com"; }
              ];
            }
          ];
        }
      ];
    }
  ];

  modules.services.internalProxy = {
    enable = true;
    virtualHosts = {
      # Local services on do-prod-01
      glance = "localhost:8080";
      uptime = "localhost:3001";
      # Services on glados (reached over Netbird mesh)
      immich = "glados:2283";
      git    = "glados:3000";
      mealie = "glados:9000";
      lore   = "glados:41337";
    };
  };

  # pijul-nest requires path-based routing between its API (httpPort 5000)
  # and UI (uiPort 5050) backends — handled directly here since the routing
  # logic lives in the pijul-nest module and can't go through the simple
  # virtualHosts attrset.
  services.caddy.virtualHosts."pijul.internal.aleclowry.com".extraConfig = ''
    @nestApi {
      path /api* /login* /register*
    }
    @pijulProto {
      path_regexp ^/[^/]+/[^/]+/\.pijul
    }
    handle @nestApi {
      reverse_proxy glados:5000
    }
    handle @pijulProto {
      reverse_proxy glados:5000
    }
    handle {
      reverse_proxy glados:5050
    }
  '';

  networking.hostName = "do-prod-01";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs;
      system = "x86_64-linux";
      keys = import ../../../keys.nix;
    };
    users.ajlow = import ../../../userspace/users/ajlow-server.nix;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.05";
}
