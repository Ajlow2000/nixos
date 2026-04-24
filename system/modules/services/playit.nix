# playit.gg tunnel agent
#
# First-time setup (one-time per machine):
#   1. Claim the agent:
#        nix run github:pedorich-n/playit-nixos-module#playit-cli -- start
#      Visit the printed URL and claim the agent on the playit.gg dashboard.
#
#   2. Copy the generated secret to the expected path:
#        sudo mkdir -p /etc/playit
#        sudo cp ~/.config/playit_gg/playit.toml /etc/playit/secret.toml
#
#   3. Restart the service:
#        sudo systemctl restart playit
#
# Tunnel port mappings are configured on the playit.gg web dashboard.
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.services.playit;
in
{
  imports = [ inputs.playit-nixos-module.nixosModules.default ];

  options.modules.services.playit = {
    enable = lib.mkEnableOption "playit.gg tunnel agent";
  };

  config = lib.mkIf cfg.enable {
    services.playit = {
      enable = true;
      secretPath = "/etc/playit/secret.toml";
    };
  };
}
