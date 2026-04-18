/*
  Disk layout for hal9000.

  Assumed device: /dev/nvme0n1
  Verify with `lsblk` before running disko.

  Note: ssd1 and ssd2 are separate physical drives mounted at /mnt/ssd1 and
  /mnt/ssd2 (by label). They are not managed by disko here — add them as
  additional disk entries once device paths are known (e.g. /dev/nvme1n1,
  /dev/nvme2n1). Until then they remain in hardware.nix.

  Reinstall workflow:
    1. Boot installer ISO
    2. Verify/update device path below
    3. disko --mode disko --flake .#hal9000
    4. Set disko.enableConfig = true in default.nix
    5. Remove fileSystems and swapDevices from hardware.nix
       (keep ssd1/ssd2 entries until they are added here)
    6. nixos-install --flake .#hal9000
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
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
