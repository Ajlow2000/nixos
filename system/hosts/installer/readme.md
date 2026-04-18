# installer

A minimal NixOS ISO for bootstrapping any host in this configuration. Includes
git, libfido2, and yubikey-manager. SSH is enabled on boot with `keys.personal`
in root's authorized_keys, so you can drive the installation remotely from
another machine using your YubiKey.

## Build the ISO

```bash
nix build .#packages.x86_64-linux.installer-iso
```

The resulting ISO will be at `./result/iso/nixos-*.iso`. Write it to a USB drive:

```bash
# Replace /dev/sdX with your USB drive — double-check with lsblk
dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Installation Workflow

### 1. Boot the ISO on the target machine

Boot from the USB. The installer comes up with SSH enabled automatically.

### 2. Find the machine's IP address

Either read it off the screen (the installer prints it) or check your router/netbird.

### 3. SSH in from another machine using your YubiKey

```bash
ssh-add -K          # load YubiKey resident keys into agent (touch required)
ssh root@<target-ip>
```

### 4. Verify the disk device

```bash
lsblk
```

Compare against the device path in `system/hosts/<hostname>/disko.nix`. Update
the file if the device differs before proceeding.

### 5. Partition and format with disko

```bash
nix run github:nix-community/disko/latest -- --mode disko --flake github:Ajlow2000/ajlow2000_nixos#<hostname>
```

Or if you've cloned the repo locally on the installer:

```bash
git clone https://github.com/Ajlow2000/ajlow2000_nixos.git /mnt/etc/nixos
nix run github:nix-community/disko/latest -- --mode disko /mnt/etc/nixos/system/hosts/<hostname>/disko.nix
```

### 6. Enable disko config and remove old fileSystems

In `system/hosts/<hostname>/default.nix`, change:

```nix
disko.enableConfig = false;
```

to:

```nix
disko.enableConfig = true;
```

Then remove the `fileSystems` and `swapDevices` entries from
`system/hosts/<hostname>/hardware.nix` — disko now owns those.

Commit and push the change before proceeding.

### 7. Install NixOS

```bash
nixos-install --flake github:Ajlow2000/ajlow2000_nixos#<hostname>
```

Set a root password when prompted (or skip if you prefer key-only auth).

### 8. Reboot

```bash
reboot
```

The machine will boot into your full configuration. SSH in with your YubiKey or
the host's device key (if you've added it to `keys.nix` already).

### 9. Generate and register the host device key

On the newly booted machine:

```bash
ssh-keygen -t ed25519 -C "ajlow@<hostname>" -f ~/.ssh/id_ed25519_<hostname>
cat ~/.ssh/id_ed25519_<hostname>.pub
```

Add the public key to `keys.personal` in `keys.nix`, commit, push, then
`nixos-rebuild switch` to deploy the updated authorized_keys to all hosts.

Store the private key in Bitwarden as an SSH Key item labeled `ajlow@<hostname> device key`.

## What's Included

| Package | Purpose |
|---|---|
| git | Clone this config repo |
| libfido2 | YubiKey FIDO2 SSH support |
| yubikey-manager | Inspect YubiKey credentials (`ykman fido credentials list`) |

## Notes

- The ISO only supports `x86_64-linux`. For ARM targets, build a separate ISO.
- `disko.enableConfig = false` on existing hosts means disko describes the disk
  layout without taking over `fileSystems` from `hardware.nix`. Flip it to `true`
  only after running disko during a fresh install.
