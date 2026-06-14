{
  config,
  lib,
  keys,
  ...
}:
let
  cfg = config.sops-identity;
  username = config.home.username;
  adminKeys = keys.age.admin or { };
  myKeys = lib.filterAttrs (
    name: value:
    lib.hasPrefix "${username}-" name && value ? identity
  ) adminKeys;
  renderedKeys = lib.concatMapStringsSep "\n" (
    name:
    let
      v = myKeys.${name};
    in
    ''
      # ${name} (recipient: ${v.recipient})
      ${v.identity}
    ''
  ) (lib.attrNames myKeys);
in
{
  options.sops-identity = {
    enable = lib.mkEnableOption "render ~/.config/sops/age/keys.txt from keys.nix";
  };

  config = lib.mkIf (cfg.enable && myKeys != { }) {
    xdg.configFile."sops/age/keys.txt" = {
      text = renderedKeys;
      # 0600 isn't strictly needed (stubs are public), but sops/age expects
      # tight perms on this path by convention and will warn otherwise.
      onChange = ''
        chmod 600 "$HOME/.config/sops/age/keys.txt" || true
      '';
    };
  };
}
