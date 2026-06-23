{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop.cosmic;
in
{
  options.modules.desktop.cosmic = {
    enable = lib.mkEnableOption "COSMIC desktop environment";

    xwayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable XWayland support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.xwayland.enable = cfg.xwayland;

    # COSMIC enables gnome-keyring, whose ssh component hijacks $SSH_AUTH_SOCK
    # and re-adds keys after `ssh-add -D`. Disable it entirely (daemon + the PAM
    # services that auto-launch it) and use a plain openssh agent instead.
    # Trade-off: this removes the Secret Service provider (org.freedesktop.secrets),
    # so libsecret-based apps lose that credential store.
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
    security.pam.services.greetd.enableGnomeKeyring = lib.mkForce false;

    programs.ssh.startAgent = true;
  };
}
