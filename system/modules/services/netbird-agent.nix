{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.netbird-agent;
in {
    options.modules.services.netbird-agent = {
        enable = lib.mkEnableOption "Netbird mesh networking agent";
    };

    config = lib.mkIf cfg.enable {
        systemd.services.${config.services.netbird.clients.default.service.name}.path = [ pkgs.shadow ]; # https://github.com/NixOS/nixpkgs/issues/505846

        services.netbird = {
            enable = true; # for netbird service & CLI
        };

        # Redirect port 22 on the Netbird interface (wt0) to Netbird's built-in
        # SSH server on port 22022, so `netbird ssh` works while system sshd
        # continues to handle port 22 on all other interfaces normally.
        # Note: 22022 is where Netbird SSH lands when sshd already holds port 22.
        # If this ever breaks, verify the port with: ss -tlnp | grep :22022
        networking.firewall.extraCommands = ''
            iptables -t nat -A PREROUTING -i wt0 -p tcp --dport 22 -j REDIRECT --to-port 22022
        '';
        networking.firewall.extraStopCommands = ''
            iptables -t nat -D PREROUTING -i wt0 -p tcp --dport 22 -j REDIRECT --to-port 22022 || true
        '';
    };
}
