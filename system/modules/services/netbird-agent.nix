{ config, lib, pkgs, ... }:
let
    cfg = config.modules.services.netbird-agent;
in {
    options.modules.services.netbird-agent = {
        enable = lib.mkEnableOption "Netbird mesh networking agent";
    };

    config = lib.mkIf cfg.enable {
        services.netbird.clients.wt0 = {
            # Port used to listen to wireguard connections
            port = 51821;

            # Set this to true if you want the GUI client
            ui.enable = false;

            # This opens ports required for direct connection without a relay
            openFirewall = true;

            # This opens necessary firewall ports in the Netbird client's network interface
            openInternalFirewall = true;
        };

        # The built-in login service has a bug: it greps for "Connected" which matches
        # "Peers count: 0/0 Connected" even on a fresh unregistered peer, so it always
        # skips the setup key registration. This service replaces it with a correct check.
        systemd.services."netbird-wt0-register" = {
            description = "Register netbird wt0 peer with setup key if not already connected";
            after = [ "netbird-wt0.service" ];
            requires = [ "netbird-wt0.service" ];
            wantedBy = [ "netbird-wt0.service" ];

            environment = {
                NB_CONFIG = "/var/lib/netbird-wt0/config.json";
                NB_DAEMON_ADDR = "unix:///var/run/netbird-wt0/sock";
                NB_INTERFACE_NAME = "nb-wt0";
                NB_LOG_FILE = "console";
                NB_LOG_LEVEL = "info";
                NB_SERVICE = "netbird-wt0";
                NB_STATE_DIR = "/var/lib/netbird-wt0";
                NB_WIREGUARD_PORT = "51821";
            };

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                # Load the setup key from outside the Nix store into a credentials directory
                LoadCredential = "setup-key:/etc/netbird-agent/setup-key";
                ExecStart = pkgs.writeShellScript "netbird-wt0-register-start" ''
                    # Wait for the daemon socket to be ready
                    until ${pkgs.netbird}/bin/netbird status > /dev/null 2>&1; do
                        sleep 1
                    done

                    status=$(${pkgs.netbird}/bin/netbird status 2>/dev/null || true)

                    if echo "$status" | grep -q 'Management: Connected'; then
                        echo "Already connected to management server, skipping registration"
                        exit 0
                    fi

                    echo "Registering peer with setup key..."
                    ${pkgs.netbird}/bin/netbird up --setup-key-file "$CREDENTIALS_DIRECTORY/setup-key" --allow-server-ssh
                '';
            };
        };
    };
}
