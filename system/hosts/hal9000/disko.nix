/*
  Disk layout for hal9000.

  Three SSDs, all ~1TB:
    nvme  /dev/nvme0n1  Samsung 970 EVO  (NVMe)
    a     /dev/sda      Samsung 860 EVO  (SATA)
    b     /dev/sdb      Samsung 860 EVO  (SATA)

  btrfs spans all three: -d single (all ~3TB usable), -m dup (metadata redundant).
  ESP and swap stay on nvme outside the btrfs pool.

  Disko formats disks alphabetically — a and b are partitioned before nvme so
  their raw partitions exist when nvme's mkfs.btrfs lists them as extra devices.

  Reinstall workflow:
    1. Boot installer ISO
    2. disko --mode disko --flake .#hal9000
    3. Set disko.enableConfig = true in default.nix
    4. Remove fileSystems and swapDevices from hardware.nix
    5. Remove /mnt/ssd1 and /mnt/ssd2 tmpfiles rules from default.nix
    6. nixos-install --flake .#hal9000
*/
{
  disko.devices.disk = {
    a = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          # No content — partition is created raw; incorporated into btrfs by nvme's mkfs
        };
      };
    };

    b = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "gpt";
        partitions.data = {
          size = "100%";
          # No content — same as above
        };
      };
    };

    nvme = {
      type = "disk";
      device = "/dev/nvme0n1";
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
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          swap = {
            size = "8G";
            content.type = "swap";
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-d" "single"
                "-m" "dup"
                "/dev/disk/by-partlabel/gpt-a-data"
                "/dev/disk/by-partlabel/gpt-b-data"
              ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "discard=async"
                  ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "discard=async"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "discard=async"
                  ];
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                    "discard=async"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
