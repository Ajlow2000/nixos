# microvac

> Multivac is a fictional powerful computer appearing in over a 
> dozen science fiction stories by American writer Isaac Asimov. 
> Asimov's depiction of Multivac, a mainframe computer accessible 
> by terminal, originally by specialists using machine code and 
> later by any user, and used for directing the global economy 
> and humanity's development, has been seen as the defining 
> conceptualization of the genre of computers for the period 
> (1950s–1960s). Multivac has been described as the direct ancestor 
> of HAL 9000. 

\- [wikipedia](https://en.wikipedia.org/wiki/Multivac)

## Hardware Specs

| Field         | Value |
|---------------|-------|
| Make          | Framework |
| Model         | Framework 13 |
| Architecture  | x86_64 |
| CPU           | AMD Ryzen 7 7840U |
| GPU           | Radeon 780M Graphics |
| Memory        | 2x32gb DDR5 |
| Storage       | 2tb NVME SSD |
| Date Acquired | 2024-06-09 |

## Disk Layout

Managed by [disko](./disko.nix) (`disko.enableConfig = true`). GPT on
`/dev/nvme0n1`:

- `ESP` 512M vfat → `/boot`
- btrfs (rest of disk), zstd-compressed subvolumes:
  - `@` → `/`
  - `@home` → `/home`
  - `@nix` → `/nix`
  - `@persist` → `/persist` (reserved for future impermanence)
  - `@log` → `/var/log`
  - `@swap` → `/swap` (16G NoCoW swapfile)

## Reinstall (nixos-anywhere + disko)

> **Destructive.** This reformats all of `/dev/nvme0n1`. Back up `/home` (and
> anything else you care about) first.

1. **On microvac**, boot into an SSH-reachable installer running as `root` — the
   repo's `installer` ISO, a kexec image, or any NixOS live env with `sshd` and
   your key authorized. Confirm the disk is still `/dev/nvme0n1` with `lsblk`.
2. **From a machine with this repo checked out**, run:

   ```sh
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#microvac \
     root@<microvac-ip>
   ```

   (No `--disk-encryption-keys`; the layout is unencrypted.)
3. nixos-anywhere runs disko (formats per [disko.nix](./disko.nix)) then
   `nixos-install`, and reboots into the new btrfs system.
4. Verify after boot: `findmnt -t btrfs` shows the subvolumes with
   `compress=zstd`, and `swapon --show` lists `/swap/swapfile`. Restore `/home`
   from backup as needed.

