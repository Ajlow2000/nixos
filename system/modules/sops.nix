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
  };

  config = lib.mkIf cfg.enable {
    # Shared across all hosts. Per-host secrets can override sopsFile on
    # specific sops.secrets entries when we add them.
    sops.defaultSopsFile = ../../secrets/common.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Secret keys in common.yaml follow the convention <account>_passwd.
    sops.secrets = lib.mkMerge (
      (lib.optional cfg.passwords.root.enable {
        "root_passwd" = {
          neededForUsers = true;
        };
      })
      ++ (map (u: {
        "${u}_passwd" = {
          neededForUsers = true;
        };
      }) cfg.passwords.users)
    );

    users.mutableUsers = false;

    users.users.root.hashedPasswordFile =
      lib.mkIf cfg.passwords.root.enable
        config.sops.secrets."root_passwd".path;
  };
}
