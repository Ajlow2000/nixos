{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.game-streaming;
in
{
  options.modules.services.game-streaming = {
    server.enable = lib.mkEnableOption "Sunshine game-streaming host";
    client.enable = lib.mkEnableOption "Moonlight game-streaming client";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      services.sunshine = {
        enable = true;
        autoStart = true;
        openFirewall = true;
        capSysAdmin = true;
      };

      # Sunshine needs uinput to inject virtual gamepad/keyboard/mouse events.
      boot.kernelModules = [ "uinput" ];
      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
      '';
    })

    (lib.mkIf cfg.client.enable {
      environment.systemPackages = [ pkgs.moonlight-qt ];
    })
  ];
}
