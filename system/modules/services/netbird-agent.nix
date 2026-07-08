{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.services.netbird-agent;
in
{
  options.modules.services.netbird-agent = {
    enable = lib.mkEnableOption "Netbird mesh networking agent";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      systemd.services.${config.services.netbird.clients.default.service.name} = {
        path = [ pkgs.shadow ]; # https://github.com/NixOS/nixpkgs/issues/505846

        # Don't restart netbird during `nixos-rebuild switch`. Remote deploys run
        # over the mesh (wt0); restarting netbird mid-activation severs the SSH
        # session nh/nixos-rebuild is using, aborting the switch before later
        # services activate. Netbird picks up package/config changes on the next
        # reboot or an explicit `systemctl restart`.
        restartIfChanged = false;
      };

      services.netbird = {
        enable = true; # for netbird service & CLI

        # Persisted equivalents of the old manual `just nb`
        # (`netbird up --allow-server-ssh --disable-ssh-auth`). These merge with
        # the module's config.json defaults (WgIface=wt0, WgPort, DisableAutoConnect).
        clients.default.config = {
          ServerSSHAllowed = true; # --allow-server-ssh
          DisableSSHAuth = true; # --disable-ssh-auth
        };
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
    }

    # Automated first-boot enrollment using the shared setup key, whenever sops
    # is available on the host. Replaces the manual `just nb`: the module's
    # `netbird-login.service` waits until the peer reports NeedsLogin, then runs
    # `netbird up`, auto-picking up the key. No-op once the peer is Connected.
    (lib.mkIf config.modules.sops.enable {
      # Setup key lives in common.yaml (all hosts are decrypt recipients).
      # Default owner root:root / 0400 is fine — the login unit reads it via
      # systemd LoadCredential (as root, before dropping privileges).
      sops.secrets."netbird-enrollment-key".key = "netbird_enrollment_key";

      services.netbird.clients.default.login = {
        enable = true;
        setupKeyFile = config.sops.secrets."netbird-enrollment-key".path;
        # No systemdDependencies: this sops-nix installs secrets via the
        # `setupSecrets` activation script (there is no sops-install-secrets
        # unit), which runs before systemd starts services — so the key file is
        # already present. The login unit also orders after netbird.service.
      };
    })
  ]);
}
