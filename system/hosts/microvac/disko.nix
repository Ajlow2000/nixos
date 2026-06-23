/*
  Disk layout for microvac (Framework 13, 2TB NVMe).

  Assumed device: /dev/nvme0n1
  Verify with `lsblk` before running disko / nixos-anywhere.

  Layout: GPT
    - ESP   512M  vfat  -> /boot
    - btrfs (rest of disk), zstd-compressed subvolumes:
        @         -> /
        @home     -> /home
        @nix      -> /nix
        @persist  -> /persist   (reserved for future impermanence)
        @log      -> /var/log
        @swap     -> /swap      (16G NoCoW swapfile via `btrfs mkswapfile`)

  This layout is active: default.nix sets `disko.enableConfig = true`, so the
  system's fileSystems/swapDevices come from here (not hardware.nix).

  Reinstall workflow (nixos-anywhere + disko): see ./readme.md. In short, boot
  microvac into an SSH-reachable installer, then from a machine with this repo:

    nix run github:nix-community/nixos-anywhere -- --flake .#microvac root@<ip>

  nixos-anywhere runs disko (formatting per this file) and then nixos-install.
  WARNING: this reformats /dev/nvme0n1 entirely. Back up /home first.
*/
{
  disko.devices = {
    disk = {
      main = {
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
                  "@persist" = {
                    mountpoint = "/persist";
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
    };
  };
}
