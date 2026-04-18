/*
  Disk layout for mindgame.

  Assumed device: /dev/nvme0n1
  Verify with `lsblk` before running disko.

  Reinstall workflow:
    1. Boot installer ISO
    2. Verify/update device path below
    3. disko --mode disko --flake .#mindgame
    4. Set disko.enableConfig = true in default.nix
    5. Remove fileSystems and swapDevices from hardware.nix
    6. nixos-install --flake .#mindgame
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
