{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.ollama;
in
{
  options.modules.services.ollama = {
    enable = lib.mkEnableOption "Ollama AI server";

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "llama3.2:3b"
        "deepseek-r1:1.5b"
        "gemma3:4b"
        "gpt-oss:20b"
        "gpt-oss"
      ];
      description = "Models to automatically download when service starts";
    };

    syncModels = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remove models not declared in the configuration";
    };

    acceleration = lib.mkOption {
      type = lib.types.enum [
        null
        "rocm"
        "cuda"
        "vulkan"
      ];
      default = "vulkan";
      description = "Hardware acceleration interface";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port the Ollama API listens on.";
    };

    exposeInternal = lib.mkEnableOption "register with the internal Caddy proxy";

    internalSubdomain = lib.mkOption {
      type = lib.types.str;
      default = "ollama";
      description = "Subdomain under the internal proxy domain for this service.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      loadModels = cfg.models;
      inherit (cfg) syncModels;
      environmentVariables = {
        OLLAMA_HOST = "0.0.0.0";
      };
      package = if cfg.acceleration != null then pkgs."ollama-${cfg.acceleration}" else pkgs.ollama;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    modules.services.internalProxy.virtualHosts = lib.mkIf cfg.exposeInternal {
      ${cfg.internalSubdomain} = "localhost:${toString cfg.port}";
    };
  };
}
