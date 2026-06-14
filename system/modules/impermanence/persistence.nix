{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.modules.impermanence.persistence;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.modules.impermanence.persistence = {
    enable = lib.mkEnableOption "bind-mount system state from /persist";

    extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional system directories to persist beyond the defaults.";
    };

    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional system files to persist beyond the defaults.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/upower"
        "/var/lib/colord"
        "/var/lib/fprint"
        "/var/lib/AccountsService"
        "/var/lib/sops-nix"
      ] ++ cfg.extraDirectories;
      files = [
        "/etc/machine-id"
      ] ++ cfg.extraFiles;
    };
  };
}
