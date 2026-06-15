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
    enable = lib.mkEnableOption "sops-nix secrets management for this host";

    passwords.root.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Manage the root password via sops (requires modules.sops.enable).";
    };

    passwords.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        User accounts whose login password should be sops-managed on this host.
        Callers (user-definitions, digital-ocean profile) append to this list
        when the corresponding user is enabled.
      '';
    };

    sshKeys.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        User accounts whose ed25519 SSH private key should be deployed from
        the host's per-host sops file to ~/.ssh/id_ed25519. The corresponding
        public key lives in keys.nix and is not managed here.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # User passwords are shared across hosts and live in common.yaml.
    # Root password is per-host; the secret entry below overrides sopsFile.
    sops.defaultSopsFile = ../../secrets/common.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Secret keys follow the convention <account>_passwd / <account>_ssh_key.
    sops.secrets = lib.mkMerge (
      (lib.optional cfg.passwords.root.enable {
        "root_passwd" = {
          neededForUsers = true;
          sopsFile = ../../secrets/hosts + "/${config.networking.hostName}.yaml";
        };
      })
      ++ (map (u: {
        "${u}_passwd" = {
          neededForUsers = true;
        };
      }) cfg.passwords.users)
      ++ (map (u: {
        "${u}_ssh_key" = {
          path = "/home/${u}/.ssh/id_ed25519";
          owner = u;
          group = "users";
          mode = "0600";
          sopsFile = ../../secrets/hosts + "/${config.networking.hostName}.yaml";
        };
      }) cfg.sshKeys.users)
    );

    # ~/.ssh must exist before sops writes the key into it.
    systemd.tmpfiles.rules = map (u: "d /home/${u}/.ssh 0700 ${u} users -") cfg.sshKeys.users;

    users.mutableUsers = false;

    users.users.root.hashedPasswordFile =
      lib.mkIf cfg.passwords.root.enable
        config.sops.secrets."root_passwd".path;
  };
}
