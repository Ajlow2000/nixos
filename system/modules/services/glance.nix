{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.services.glance;
in
{
  options.modules.services.glance = {
    enable = lib.mkEnableOption "Glance dashboard";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port the Glance web UI listens on.";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "glance";
      description = "Subdomain under the internal proxy domain for this service.";
    };

    netbirdEnvFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to an env file supplying NETBIRD_API_KEY for the Netbird devices widget.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.glance = {
      isSystemUser = true;
      group = "glance";
    };
    users.groups.glance = {};

    systemd.services.glance.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "glance";
      Group = lib.mkForce "glance";
      EnvironmentFile = lib.mkIf (cfg.netbirdEnvFile != null) [ cfg.netbirdEnvFile ];
    };

    services.glance = {
      enable = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = cfg.port;
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  { type = "clock"; }
                  {
                    type = "hacker-news";
                    limit = 15;
                    "collapse-after" = 5;
                  }
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
                          { title = "Pijul";   url = "https://pijul.internal.aleclowry.com"; }
                        ];
                      }
                    ];
                  }
                  {
                    type = "rss";
                    title = "Software Releases";
                    limit = 10;
                    "collapse-after" = 5;
                    feeds = [
                      { url = "https://www.kernel.org/feeds/kdist.xml"; title = "Linux Kernel"; }
                      { url = "https://github.com/NixOS/nixpkgs/releases.atom"; title = "NixOS"; }
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
                      { title = "Immich";      url = "https://immich.internal.aleclowry.com"; }
                      { title = "Forgejo";     url = "https://git.internal.aleclowry.com"; }
                      { title = "Pijul Nest";  url = "https://pijul.internal.aleclowry.com"; }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    networking.firewall.interfaces.wt0.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
