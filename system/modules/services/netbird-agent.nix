{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.netbird-agent;
in {
    options.modules.services.netbird-agent = {
        enable = lib.mkEnableOption "Netbird mesh networking agent";
    };

    config = lib.mkIf cfg.enable {
        services.netbird.clients.wt0 = {
            # Automatically login to your Netbird network with a setup key
            # This is mostly useful for server computers.
            # For manual setup instructions, see the wiki page section below.
            login = {
                enable = true;

                # Path to a file containing the setup key for your peer
                # NOTE: if your setup key is reusable, make sure it is not copied to the Nix store.
                setupKeyFile = "/etc/netbird-agent/setup-key";
            };

            # Port used to listen to wireguard connections
            port = 51821;

            # Set this to true if you want the GUI client
            ui.enable = false;

            # This opens ports required for direct connection without a relay
            openFirewall = true;

            # This opens necessary firewall ports in the Netbird client's network interface
            openInternalFirewall = true;
        };

    };
}
