/*
  Disk layout for microvac.

  Assumed device: /dev/nvme0n1
  Verify with `lsblk` before running disko.

  Reinstall workflow:
    1. Boot installer ISO
    2. Verify/update device path below
    3. disko --mode disko --flake .#microvac
    4. Set disko.enableConfig = true in default.nix
    5. Remove fileSystems and swapDevices from hardware.nix
    6. nixos-install --flake .#microvac
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
