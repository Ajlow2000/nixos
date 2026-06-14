{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.yubikey;
in
{
  options.modules.services.yubikey = {
    enable = lib.mkEnableOption "YubiKey smart card support (pcscd + ykman + age-plugin-yubikey)";
  };

  config = lib.mkIf cfg.enable {
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      yubikey-manager
      age-plugin-yubikey
    ];
  };
}
