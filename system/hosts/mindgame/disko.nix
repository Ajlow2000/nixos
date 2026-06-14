/*
  Disk layout for mindgame.

  Assumed device: /dev/nvme0n1
  Verify with `lsblk` before running disko.

  Layout:
    - ESP            (vfat, /boot, 512M)
    - swap           (8G, random-key encrypted — no hibernation by design)
    - cryptroot      (LUKS2, fills the rest)
        btrfs with subvolumes:
          /root      -> /                (wiped each boot from /root-blank)
          /home      -> /home            (wiped each boot)
          /nix       -> /nix
          /log       -> /var/log
          /snapshots -> /.snapshots      (reserved for snapper)
          /persist   -> /persist         (impermanence target)
        All mounted with compress=zstd,noatime.

  Boot behavior: one passphrase prompt at boot to unlock cryptroot.

  Reinstall workflow:
    1. Back up anything you care about from the old system.
    2. Boot the installer ISO, verify the device path matches `lsblk`.
    3. Run disko:
         sudo disko --mode disko --flake .#mindgame
    4. Snapshot the blank root for the rollback service:
         sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt/btrfs
         sudo btrfs subvolume snapshot -r /mnt/btrfs/root /mnt/btrfs/root-blank
         sudo umount /mnt/btrfs
    5. Generate mindgame's persistent host SSH key:
         sudo mkdir -p /mnt/persist/etc/ssh
         sudo ssh-keygen -t ed25519 -N "" \
           -f /mnt/persist/etc/ssh/ssh_host_ed25519_key \
           -C "root@mindgame"
    6. Derive the age public key:
         nix run nixpkgs#ssh-to-age -- \
           -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
       Paste into .sops.yaml as &host_mindgame and:
         sops updatekeys secrets/users/ajlow.yaml
       Commit, push, refetch.
    7. Flip `disko.enableConfig = true` in default.nix and strip the
       `fileSystems` / `swapDevices` blocks from hardware.nix.
    8. Install:
         sudo nixos-install --flake .#mindgame --no-root-passwd
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
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            cryptroot = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
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
