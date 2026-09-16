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
  };

  config = lib.mkIf cfg.enable {
    home.activation.sopsAgeKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -d -m700 "$HOME/.config/sops/age"
      # /etc/sops/age/host.txt is pre-derived from the host SSH key by the
      # system activation script (readable by the sops-age group).
      if [ -r /etc/sops/age/host.txt ]; then
        cp /etc/sops/age/host.txt "$HOME/.config/sops/age/keys.txt"
        chmod 600 "$HOME/.config/sops/age/keys.txt"
      fi
    '';
  };
}
