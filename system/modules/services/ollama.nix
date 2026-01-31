{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.ollama;
in {
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
            type = lib.types.enum [ null "rocm" "cuda" "vulkan" ];
            default = "vulkan";
            description = "Hardware acceleration interface";
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
            package = if cfg.acceleration != null then 
                pkgs."ollama-${cfg.acceleration}" 
            else 
                pkgs.ollama;
        };

        networking.firewall.allowedTCPPorts = [ 11434 ];
    };
}