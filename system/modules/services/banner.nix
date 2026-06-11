{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.banner;

  hostText = if cfg.text != null then cfg.text else config.networking.hostName;

  banner = pkgs.runCommand "banner-${hostText}" { } ''
    ${pkgs.figlet}/bin/figlet -f ${lib.escapeShellArg cfg.font} ${lib.escapeShellArg hostText} > $out
  '';
in
{
  options.modules.services.banner = {
    enable = lib.mkEnableOption "SSH login banner with hostname ASCII art";

    font = lib.mkOption {
      type = lib.types.str;
      default = "standard";
      description = "figlet font name (see `figlist` for options).";
    };

    text = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Override banner text. Defaults to networking.hostName.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."banner".source = banner;

    environment.loginShellInit = ''
      if [ -n "$SSH_CONNECTION" ] && [ -t 1 ]; then
        cat /etc/banner
        read -r _l1 _l2 _l3 _rest < /proc/loadavg
        printf '\n up %s  ·  load %s %s %s  ·  /  %s used\n\n' \
          "$(${pkgs.procps}/bin/uptime -p | sed 's/^up //')" \
          "$_l1" "$_l2" "$_l3" \
          "$(df -h / | awk 'NR==2 {print $5}')"
        unset _l1 _l2 _l3 _rest
      fi
    '';
  };
}
