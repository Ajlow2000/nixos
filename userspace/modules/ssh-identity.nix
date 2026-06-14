{
  config,
  lib,
  ...
}:
let
  cfg = config.ssh-identity;
in
{
  options.ssh-identity = {
    enable = lib.mkEnableOption "symlink sops-managed SSH identity into ~/.ssh";

    privateKeySource = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/${config.home.username}_id_ed25519";
      description = "Path where sops-nix writes the decrypted private key.";
    };

    publicKeySource = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/${config.home.username}_id_ed25519.pub";
      description = "Path where sops-nix writes the public key.";
    };

    knownHosts = lib.mkOption {
      type = lib.types.lines;
      default = ''
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      '';
      description = "Contents of ~/.ssh/known_hosts.";
    };

    sshConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        Host github.com
          User git
          IdentityFile ~/.ssh/id_ed25519
          IdentitiesOnly yes

        Host *
          AddKeysToAgent yes
          IdentityFile ~/.ssh/id_ed25519
      '';
      description = "Contents of ~/.ssh/config.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/config".text = cfg.sshConfig;
    home.file.".ssh/known_hosts".text = cfg.knownHosts;

    home.activation.linkSshSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD chmod 700 "$HOME/.ssh"

      if [ -e "${cfg.privateKeySource}" ]; then
        $DRY_RUN_CMD ln -sfn "${cfg.privateKeySource}" "$HOME/.ssh/id_ed25519"
      else
        echo "ssh-identity: WARN ${cfg.privateKeySource} missing; private key not linked" >&2
      fi

      if [ -e "${cfg.publicKeySource}" ]; then
        $DRY_RUN_CMD ln -sfn "${cfg.publicKeySource}" "$HOME/.ssh/id_ed25519.pub"
      fi
    '';
  };
}
