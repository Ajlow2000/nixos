{ inputs, lib, config, ... }:
{
  imports = [
    ../../profiles/digital-ocean.nix
    ../../modules/services/glance.nix
    ../../modules/services/internal-proxy.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  profiles.system.digital-ocean.enable = true;
  modules.services.glance = {
    enable = true;
    netbirdEnvFile = config.sops.templates."glance-env".path;
  };

  sops.secrets."netbird-api-key" = { key = "netbird/api-token"; };
  sops.templates."glance-env" = {
    content = "NETBIRD_API_KEY=${config.sops.placeholder."netbird-api-key"}\n";
    owner = "glance";
    mode = "0400";
  };

  modules.services.internalProxy = {
    enable = true;
    virtualHosts = {
      # Local services on do-prod-01
      glance = "localhost:8080";
      # Services on glados (reached over Netbird mesh)
      immich = "glados:2283";
      git    = "glados:3000";
      links  = "glados:3100";
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

  # 25GB droplet — keep logs and old Nix generations from filling the disk.
  services.journald.settings.Journal.SystemMaxUse = "500M";

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
