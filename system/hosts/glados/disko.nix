/*
  Disk layout for glados (NAS / home server).

  Two independent things live here:
    1. Boot SSD (128G)   -> btrfs, zstd-compressed subvolumes (like microvac)
    2. Storage pool      -> ZFS raidz2 across 5x 4TB HDDs, pool name "tank"

  DEVICE PATHS — READ BEFORE DEPLOYING
  ------------------------------------
  With six drives attached, /dev/sdX ordering is NOT stable across boots, so we
  pin every drive by /dev/disk/by-id/. The REPLACE_ME_* placeholders below must
  be filled in from the target machine before running disko/nixos-anywhere:

    lsblk -o NAME,SIZE,MODEL,SERIAL          # identify the 128G SSD vs the 4TB HDDs
    ls -l /dev/disk/by-id/                   # map each drive to a stable by-id path

  Prefer the /dev/disk/by-id/ata-... or nvme-... names (the ones carrying the
  model+serial), NOT the wwn-... aliases, so the config is human-checkable.

  Reinstall workflow: see ./readme.md (nixos-anywhere + disko). WARNING: this
  reformats ALL SIX drives.
*/
{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-nvme.1e4b-514d48383531573030303337395031313033-4169724469736b20313238474220535344-00000001";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # Swap kept on the SSD (NOT on ZFS — a swapfile on a zvol/zfs
                  # can deadlock under memory pressure).
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };

      # ---- Storage HDDs (5x 4TB), members of the "tank" zpool ---------------
      hdd0 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFZZ-68CPAN0_WD-WX12D16978LC";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFZZ-68CPAN0_WD-WX12D1697EEN";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFZZ-68CPAN0_WD-WX12D165EX9Z";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      hdd3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFZZ-68CPAN0_WD-WX72DC5F024J";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      hdd4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFZZ-68CPAN0_WD-WX72DC5F08P6";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
    };

    zpool = {
      tank = {
        type = "zpool";
        mode = "raidz2";
        options = {
          ashift = "12"; # 4K sectors — correct for these 4TB drives
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          # Pool root is a container only; data lives in the dataset below.
          mountpoint = "none";
        };
        # compression=zstd, atime=off, xattr=sa, acltype=posixacl all inherit
        # from rootFsOptions above — only per-dataset overrides are set here.
        #
        # ADDING A DATASET AFTER THE POOL ALREADY EXISTS
        # ----------------------------------------------
        # disko only creates these datasets at initial provisioning (the
        # `disko`/nixos-anywhere run). It does NOT reconcile on `nixos-rebuild`,
        # and re-running disko is DESTRUCTIVE. So to add a dataset to a live pool:
        #
        #   1. Create it live (non-destructive, inherits pool properties):
        #        sudo zfs create -o recordsize=<size> tank/<name>
        #      (add -o quota=<n>, etc. as needed; omit recordsize to inherit)
        #   2. THEN add a matching entry below and rebuild. Order matters:
        #      create-first, then rebuild — the entry generates a fileSystems
        #      mount that assumes the dataset already exists, so rebuilding
        #      before step 1 fails the boot mount.
        #
        # Keeping the entry here (after creating it live) documents the layout
        # and makes the mount declarative. Never re-run disko just to add one.
        datasets = {
          # Immich — phone photo/video backup. Parent is a container (no mount)
          # so `zfs snapshot -r tank/immich@x` captures library + db atomically.
          "immich" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          # Originals from your phone — PRECIOUS. Snapshot + replicate off-box.
          "immich/library" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/immich/library";
            options.recordsize = "1M";
          };
          # Postgres (pgvecto.rs) — small random IO, 16K avoids write amplification.
          "immich/db" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/immich/db";
            options.recordsize = "16K";
          };
          # Thumbnails / transcodes / ML — regenerable, no snapshots, capped.
          "immich/cache" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/immich/cache";
            options = {
              recordsize = "1M";
              quota = "200G";
            };
          };
          # Git server (repos + config) — snapshot frequently.
          "git" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/git";
          };
          # Movies / TV for Plex/Jellyfin — large sequential, re-obtainable, no snapshots.
          "media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/media";
            options.recordsize = "1M";
          };
          # VPN-only Samba share — general user data, snapshot.
          "share" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/share";
          };
          # Publicly-exposed downloads — ISOLATED, served read-only, capped so a
          # compromise can't fill the pool or reach anything private.
          "public" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/public";
            options = {
              recordsize = "1M";
              quota = "500G";
            };
          };
          # Config/state for services that don't warrant their own dataset.
          "appdata" = {
            type = "zfs_fs";
            mountpoint = "/mnt/tank/appdata";
            options.recordsize = "64K";
          };
        };
      };
    };
  };
}
