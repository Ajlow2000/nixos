{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.de;
in
{
  imports = [
    ./my_hypr.nix
  ];

  options = {
    de.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    my_hypr.enable = true;

    # Prevent gnome-keyring from starting via XDG autostart.
    # User entries in ~/.config/autostart/ override /etc/xdg/autostart/.
    xdg.configFile."autostart/gnome-keyring-pkcs11.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    xdg.configFile."autostart/gnome-keyring-secrets.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';

    # Shadow the D-Bus service file so gnome-keyring can't be activated on-demand.
    # User-level files in ~/.local/share/dbus-1/services/ take precedence over system ones.
    xdg.dataFile."dbus-1/services/org.freedesktop.secrets.service".text = ''
      [D-BUS Service]
      Name=org.freedesktop.secrets
      Exec=${pkgs.coreutils}/bin/false
    '';
  };
}
