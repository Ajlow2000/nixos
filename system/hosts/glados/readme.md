# glados

> GLaDOS (Genetic Lifeform and Disk Operating System) is a fictional
> artificially superintelligent computer system from the video game series
> Portal. She serves as the primary antagonist, running the Aperture Science
> Enrichment Center and testing the player with a mix of deadly puzzles and
> dry, passive-aggressive commentary.

\- [wikipedia](https://en.wikipedia.org/wiki/GLaDOS)

## Role

NAS / home server.

## Hardware Specs

| Field         | Value |
|---------------|-------|
| Make          |  |
| Model         |  |
| Architecture  | x86_64 |
| CPU           |  |
| GPU           |  |
| Memory        |  |
| Storage       | 128GB SSD (boot) + 5x 4TB HDD (storage pool) |
| Date Acquired |  |

## Disk Layout

Managed by [disko](./disko.nix) (`disko.enableConfig = true`). Two parts:

**Boot SSD (128G)** — GPT, btrfs with zstd-compressed subvolumes:

- `ESP` 512M vfat → `/boot`
- `@` → `/`
- `@home` → `/home`
- `@nix` → `/nix`
- `@log` → `/var/log`
- `@swap` → `/swap` (8G swapfile; kept off ZFS on purpose)

**Storage pool `tank`** — ZFS **raidz2** across the 5x 4TB HDDs
(~12 TB usable, survives any two drive failures). `ashift=12`,
`compression=zstd`, `atime=off`, `xattr=sa`, `acltype=posixacl` (inherited),
`services.zfs.autoScrub.enable = true`. Datasets are defined in
[disko.nix](./disko.nix) and mounted under `/mnt/tank`.

All six drives are pinned by `/dev/disk/by-id/` in `disko.nix` — `/dev/sdX`
ordering is not stable with this many disks.

## Reinstall (nixos-anywhere + disko)

> **Destructive.** This reformats **all six drives** (boot SSD + 5 HDDs). Back up
> anything you care about first.

1. **On glados**, boot into an SSH-reachable installer running as `root` — the
   repo's `installer` ISO, a kexec image, or any NixOS live env with `sshd` and
   your key authorized.
2. **Identify the drives** and pin them in [disko.nix](./disko.nix):

   ```sh
   lsblk -o NAME,SIZE,MODEL,SERIAL     # which is the 128G SSD vs the 4TB HDDs
   ls -l /dev/disk/by-id/              # map each to a stable by-id path
   ```

   Replace device paths in `disko.nix`.
3. **Generate `hardware.nix`** on glados (disko owns the filesystems):

   ```sh
   nixos-generate-config --no-filesystems --show-hardware-config \
     > system/hosts/glados/hardware.nix
   ```
4. **Set `networking.hostId`** in [default.nix](./default.nix) to a unique
   8-hex-digit value:

   ```sh
   head -c4 /dev/urandom | od -A none -t x4
   ```

   Replace the `REPLACE_ME` placeholder.
5. **From a machine with this repo checked out**, run:

   ```sh
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#glados \
     root@<glados-ip>
   ```

   nixos-anywhere runs disko (formats the SSD + builds the raidz2 pool) then
   `nixos-install`, and reboots.
6. **Verify after boot:**
   - `findmnt -t btrfs` → `/`, `/home`, `/nix`, `/var/log` with `compress=zstd`;
     `swapon --show` lists `/swap/swapfile`.
   - `zpool status tank` → `raidz2-0` with all 5 disks `ONLINE`, no errors.
   - `zpool list tank` → ~12 TB; `zfs list` shows `tank/data` at `/mnt/tank`.
   - `systemctl status zfs-scrub.timer` → active.
