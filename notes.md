  1. Pre-generate the keys (no passphrase; privates stay local)

  rm -rf /tmp/microvac-keys && mkdir -p /tmp/microvac-keys && chmod 700 /tmp/microvac-keys
  ssh-keygen -t ed25519 -N "" -C root@microvac  -f /tmp/microvac-keys/ssh_host_ed25519_key
  ssh-keygen -t ed25519 -N "" -C ajlow@microvac -f /tmp/microvac-keys/ajlow_id_ed25519

  2. Derive microvac's age recipient + the new ajlow pubkey

  ssh-to-age -i /tmp/microvac-keys/ssh_host_ed25519_key.pub   # -> age1...  (microvac sops identity)
  cat /tmp/microvac-keys/ajlow_id_ed25519.pub                 # -> ssh-ed25519 ... ajlow@microvac

  3. Enroll the host in .sops.yaml

  - Replace + uncomment the placeholder:
  - &host_microvac age1<from-step-2>
  - In the secrets/common\.yaml$ rule, uncomment:
  - *host_microvac
  - Add a per-host rule (copy hal9000's block):
  - path_regex: secrets/hosts/microvac\.yaml$
    key_groups:
      - age:
          - *admin_yubikey_01
          - *admin_yubikey_02
          - *admin_backup
          - *host_microvac

  4. Update keys.nix

  Set personal.microvac to the pubkey from step 2:
  microvac = "ssh-ed25519 AAAA... ajlow@microvac";

  5. Create the per-host secret (YubiKey inserted)

  mkpasswd -m yescrypt            # type root password twice -> copy the $y$... hash
  sops secrets/hosts/microvac.yaml
  Add:
  root_passwd: $y$j9T$<hash>
  ajlow_ssh_key: |
    <paste full /tmp/microvac-keys/ajlow_id_ed25519>
  ssh_host_ed25519_key: |
    <paste full /tmp/microvac-keys/ssh_host_ed25519_key>   # DR backup only; not auto-deployed

  6. Re-key shared secrets so microvac can read ajlow_passwd

  sops updatekeys secrets/common.yaml

  7. Enable sops on microvac

  In system/hosts/microvac/default.nix add:
  modules.sops.enable = true;

  8. Verify before touching hardware

  nixfmt keys.nix system/hosts/microvac/default.nix
  nix eval .#nixosConfigurations.microvac.config.users.mutableUsers          # -> false
  nix eval .#nixosConfigurations.microvac.config.users.users.ajlow.hashedPasswordFile  # -> a path, not null
  nix build .#nixosConfigurations.microvac.config.system.build.toplevel      # builds clean

  9. Stage the host key for --extra-files

  rm -rf /tmp/microvac-extra && mkdir -p /tmp/microvac-extra/etc/ssh
  cp /tmp/microvac-keys/ssh_host_ed25519_key{,.pub} /tmp/microvac-extra/etc/ssh/
  chmod 600 /tmp/microvac-extra/etc/ssh/ssh_host_ed25519_key

  10. Boot microvac into the installer + run the install

  lsblk over SSH to confirm the disk is /dev/nvme0n1, then:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#microvac \
    --extra-files /tmp/microvac-extra \
    --ssh-option StrictHostKeyChecking=accept-new \
    root@<installer-ip>
  Reformats the whole NVMe, installs btrfs, seeds the host key → sops decrypts on first boot.

  11. Verify on microvac, then clean up

  findmnt -t btrfs        # @ /@home /@nix /@persist /@log, compress=zstd
  swapon --show           # /swap/swapfile
  ls -l ~/.ssh/id_ed25519 # mode 0600, from sops
  # console/GUI login with the sops password works
  shred -u /tmp/microvac-keys/*; rm -rf /tmp/microvac-keys /tmp/microvac-extra

  Ordering that matters: step 3 before 5/6 (sops reads recipients from .sops.yaml); step 5 before 7/8 (the build hashes the
  secret file — it must exist); step 9's host key must be the one from step 1 (matches the step-3 recipient). Skip/mismatch
  the host key → first boot can't decrypt → mutableUsers=false console lockout (your ajlow SSH key still gets you in to
  recover).


