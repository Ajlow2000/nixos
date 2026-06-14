{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.impermanence.rollback;
in
{
  options.modules.impermanence.rollback = {
    enable = lib.mkEnableOption "btrfs root rollback to blank snapshot on boot";

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/mapper/cryptroot";
      description = "Block device holding the btrfs filesystem.";
    };

    rootSubvol = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "Name of the live root subvolume (without leading slash).";
    };

    blankSubvol = lib.mkOption {
      type = lib.types.str;
      default = "root-blank";
      description = "Name of the read-only snapshot used as the pristine source.";
    };

    keepOldRootsDays = lib.mkOption {
      type = lib.types.int;
      default = 30;
      description = "Days to retain archived old roots under /old_roots before pruning.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.supportedFilesystems = [ "btrfs" ];

    boot.initrd.systemd.services.rollback = {
      description = "Rollback btrfs root subvolume to a pristine snapshot";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-cryptsetup@cryptroot.service" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /btrfs_tmp
        mount -t btrfs -o subvol=/ ${cfg.device} /btrfs_tmp

        if [[ -e /btrfs_tmp/${cfg.rootSubvol} ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/${cfg.rootSubvol})" "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/${cfg.rootSubvol} "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${toString cfg.keepOldRootsDays}); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume snapshot /btrfs_tmp/${cfg.blankSubvol} /btrfs_tmp/${cfg.rootSubvol}
        umount /btrfs_tmp
      '';
    };
  };
}
