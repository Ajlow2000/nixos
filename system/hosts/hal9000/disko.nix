/*
  Disk layout for hal9000.

  Assumed primary device: /dev/nvme0n1
  Verify with `lsblk` before running disko.

  Note: ssd1 and ssd2 are separate physical drives mounted at /mnt/ssd1 and
  /mnt/ssd2 (by label). They are not managed by disko here — they remain in
  hardware.nix and survive the conversion. Add them as additional disk
  entries here once device paths are stable.

  Layout (primary disk):
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
    1. Back up /home/ajlow and any service state under /var/lib (minecraft
       worlds, git-server repos, ollama models, playit keys).
       /mnt/ssd1 and /mnt/ssd2 are on separate disks and survive intact.
    2. Boot the installer ISO, verify the device path matches `lsblk`.
    3. Run disko:
         sudo disko --mode disko --flake .#hal9000
    4. Snapshot the blank root for the rollback service:
         sudo mount -o subvol=/ /dev/mapper/cryptroot /mnt/btrfs
         sudo btrfs subvolume snapshot -r /mnt/btrfs/root /mnt/btrfs/root-blank
         sudo umount /mnt/btrfs
    5. Generate hal9000's persistent host SSH key:
         sudo mkdir -p /mnt/persist/etc/ssh
         sudo ssh-keygen -t ed25519 -N "" \
           -f /mnt/persist/etc/ssh/ssh_host_ed25519_key \
           -C "root@hal9000"
    6. Derive the age public key:
         nix run nixpkgs#ssh-to-age -- \
           -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
       Paste into .sops.yaml as &host_hal9000 and:
         sops updatekeys secrets/users/ajlow.yaml
       Commit, push, refetch.
    7. Flip `disko.enableConfig = true` in default.nix. Remove the root /
       /boot / swap entries from hardware.nix but KEEP /mnt/ssd1 and /mnt/ssd2.
    8. Install:
         sudo nixos-install --flake .#hal9000 --no-root-passwd
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
