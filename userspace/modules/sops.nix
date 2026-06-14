{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.sops;
in
{
  options.modules.sops = {
    enable = lib.mkEnableOption "user-side sops/age identity deployment";

    ageIdentities = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = lib.literalExpression ''[ "AGE-PLUGIN-YUBIKEY-1..." ]'';
      description = ''
        Identity stubs written to ~/.config/sops/age/keys.txt so that sops/age
        know to invoke age-plugin-yubikey for decryption. Each stub points at
        a specific YubiKey serial + slot and is useless without the hardware.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."sops/age/keys.txt".text = lib.concatStringsSep "\n" cfg.ageIdentities + "\n";
  };
}
