# secrets/

Encrypted secrets for sops-nix. All `.yaml` files in this tree are committed
to git in encrypted form; only people (or hosts) listed in `../.sops.yaml`
can decrypt them.

## Layout

```
secrets/
├── README.md              this file
├── microvac.yaml          host-specific to microvac (root pw, host secrets)
├── hal9000.yaml           ...
├── mindgame.yaml
├── marvin.yaml
├── eddie.yaml
├── multivac.yaml
├── do-prod-01.yaml
├── common.yaml            secrets shared by all hosts (wifi PSK, etc.)
└── users/
    ├── ajlow.yaml         secrets that follow the ajlow user across hosts
    └── alowry.yaml        (work identity — marvin/eddie only)
```

Which keys can decrypt which file is defined by `creation_rules` in
`../.sops.yaml`. Per-host files are decryptable only by that host (plus the
admin). Per-user files are decryptable by every host that user logs into.

## Encryption model

Two key types, both [age](https://github.com/FiloSottile/age):

- **Admin keys** — your personal identities, all listed as recipients on
  every file so you can decrypt and edit anything. Three distinct
  identities, all interchangeable:
    - `admin_ajlow_yk01` — daily-driver YubiKey #1, PIV-backed via
      [age-plugin-yubikey](https://github.com/str4d/age-plugin-yubikey).
    - `admin_ajlow_yk02` — backup YubiKey #2, also PIV-backed.
    - `admin_ajlow_recovery` — software age key, private part stored ONLY
      in Bitwarden. Break-glass for when both YubiKeys are lost or destroyed.
- **Host keys** — one per machine, derived from `/etc/ssh/ssh_host_ed25519_key`
  (or `/persist/etc/ssh/...` on impermanent hosts) via `ssh-to-age`. The host
  uses its key automatically at boot to decrypt secrets it needs.

Adding a new key (admin or host) means: paste into `../.sops.yaml`, then run
`sops updatekeys <file>` on every file that should be readable by that key.

> **Note on YubiKey applets.** `age-plugin-yubikey` uses the **PIV applet**,
> which is separate from the **FIDO2 applet** your SSH keys live in. Both
> coexist on the same YubiKey. The PIN you set for PIV is different from the
> FIDO2 PIN.

---

## One-time admin setup

Admin identities are **per human, not per host**. You generate each identity
exactly once (ever); the matching public key goes in `.sops.yaml` and the
private material stays on a YubiKey (or in Bitwarden for the recovery key).

Three identities to set up:

### 1. Enroll YubiKey #1 (`admin_ajlow_yk01`)

Insert YubiKey #1. On a host that has `age-plugin-yubikey` (all your
admin-capable laptops do — `microvac`, `hal9000`, `mindgame`, `marvin`,
`eddie`, `multivac`):

```bash
# Optional: set/change the PIV PIN if you haven't yet (default is 123456):
ykman piv access change-pin

# Generate an age identity in a PIV slot. Slot 1 (retired key management
# slot 82) is conventional for the first key.
age-plugin-yubikey --generate \
  --slot 1 \
  --name "ajlow-yk01" \
  --touch-policy cached \
  --pin-policy once
```

Output looks like:

```
🎲 Generating key...
🔏 Generating certificate...

Recipient: age1yubikey1q...                  ← public key
AGE-PLUGIN-YUBIKEY-1M...                     ← identity stub (safe to keep)
```

Save both pieces:

```bash
mkdir -p ~/.config/sops/age
echo 'AGE-PLUGIN-YUBIKEY-1M...' >> ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Paste the `age1yubikey1q...` recipient into `../.sops.yaml` as
`&admin_ajlow_yk01`, replacing the placeholder.

The **identity stub** (`AGE-PLUGIN-YUBIKEY-1M...`) contains a YubiKey serial
number and slot reference but no secret material. It's safe to commit to git
or sync via dotfiles — without the physical YubiKey, the stub is useless.

### 2. Enroll YubiKey #2 (`admin_ajlow_yk02`)

Eject YubiKey #1, insert YubiKey #2. Repeat the same command (using slot 1
on this YubiKey too — slots are per-device):

```bash
age-plugin-yubikey --generate \
  --slot 1 \
  --name "ajlow-yk02" \
  --touch-policy cached \
  --pin-policy once
```

Append the new identity stub to `~/.config/sops/age/keys.txt` and paste the
new recipient into `.sops.yaml` as `&admin_ajlow_yk02`.

After both YubiKeys are enrolled, `~/.config/sops/age/keys.txt` has two
lines (plus comments). sops tries each identity in turn — whichever YubiKey
is plugged in wins; if neither is plugged in, you get an error.

### 3. Generate the recovery key (`admin_ajlow_recovery`)

Pure software — generate once, *never write it to a long-lived location*:

```bash
# Generate to a tmpfs path that vanishes on reboot:
TMP=$(mktemp -d -p /run/user/$UID)
age-keygen -o "$TMP/recovery.txt"
cat "$TMP/recovery.txt"            # contains both private + public
age-keygen -y "$TMP/recovery.txt"  # prints just the public
```

Copy the **entire contents** of `recovery.txt` (including the `AGE-SECRET-KEY-1...`
line) into Bitwarden as a Secure Note titled `sops admin recovery key`.

Copy the public `age1...` line into `.sops.yaml` as `&admin_ajlow_recovery`.

Then **shred the file**:

```bash
shred -u "$TMP/recovery.txt" && rm -rf "$TMP"
```

The recovery key now exists in exactly one place: Bitwarden. It's used
only when both YubiKeys are lost — at which point you'd fetch it, run
`sops updatekeys` on every file with a fresh YubiKey enrolled, then
re-shred.

### 4. Apply the new keys

After all three slots in `.sops.yaml` are filled, every secrets file needs
to be re-encrypted to the new recipients. The first time, the files don't
exist yet, so there's nothing to do — just commit `.sops.yaml`. As you
create secrets, they'll be encrypted to all three admin keys plus the
relevant host keys per `creation_rules`.

### Adding an additional admin machine

Copying the YubiKey identity stub is all you need (the *private key never
moves* — it lives on the YubiKey):

```bash
mkdir -p ~/.config/sops/age
# Paste the same identity stub(s) from your other machine:
$EDITOR ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Plug in a YubiKey, `sops <file>` works.

### PIN reset / lockout recovery

The PIV PIN locks after 3 wrong attempts. If that happens, unblock with the
PUK (default `12345678`):

```bash
ykman piv access change-pin --pin <new-pin> --puk <current-puk>
# If PUK is also blocked, you need to factory-reset PIV (LOSES THE KEY):
ykman piv reset
```

Resetting the PIV applet on a YubiKey destroys the age key on it; you'd
need to re-enroll that YubiKey (new recipient, `sops updatekeys` everywhere).
The FIDO2 applet (and your SSH keys) is unaffected.

---

## Per-host bootstrap (during reinstall)

Each impermanent host (microvac, hal9000, mindgame, marvin, eddie, multivac)
follows the same steps. Run from the installer ISO after `disko` and before
`nixos-install`. The full reinstall workflow lives in each host's
`system/hosts/<host>/disko.nix` docstring; the secrets-specific bits below
are the parts that touch this directory.

```bash
# After disko mounts /mnt/persist, generate the persistent host key:
sudo mkdir -p /mnt/persist/etc/ssh
sudo ssh-keygen -t ed25519 -N "" \
  -f /mnt/persist/etc/ssh/ssh_host_ed25519_key \
  -C "root@<host>"

# Derive the age public key from it:
nix run nixpkgs#ssh-to-age -- \
  -i /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
# Prints: age1xxx...
```

On a machine that already has your admin key (or a trusted laptop you carry
to the installer):

```bash
# 1. Paste the age1... into ../.sops.yaml as &host_<name>, replacing the
#    placeholder. Also paste it into ../keys.nix's `age.hosts` block for
#    human reference.
#
# 2. Re-encrypt every file that grants access to this host. Look at
#    creation_rules in .sops.yaml; for a fresh host that includes:
sops updatekeys secrets/<host>.yaml
sops updatekeys secrets/users/ajlow.yaml
sops updatekeys secrets/common.yaml
# (Add other files if the host is referenced in their creation_rules.)
#
# 3. Commit and push so the installer can fetch the updated flake.
```

For **cloud hosts** (`do-prod-01`): the host key lives at
`/etc/ssh/ssh_host_ed25519_key` (no `/persist`). After the droplet is
provisioned, ssh in and run `ssh-to-age` on that file directly. Same
`.sops.yaml` paste + `sops updatekeys` flow.

---

## Creating a secret file for a host

After the host's age key is registered, you create its secrets file by
opening it with sops — sops reads `creation_rules` to know which keys to
encrypt to, and creates the file if it doesn't exist:

```bash
sops secrets/microvac.yaml
```

Inside, write the file as plain YAML:

```yaml
root:
  password-hash: "$y$j9T$...generated-by-mkpasswd..."

ajlow:
  ssh:
    id_ed25519: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAA...
      -----END OPENSSH PRIVATE KEY-----
    id_ed25519.pub: "ssh-ed25519 AAAAC3Nz...comment"

wireguard:
  microvac-private: "abc...="
```

Generate password hashes with `mkpasswd -m yescrypt`. Generate SSH keypairs
once with `ssh-keygen -t ed25519 -f /tmp/k -N ""` then paste both files.

On save, sops writes the file to disk **encrypted**. `git diff` shows
ciphertext — that's expected.

---

## Referencing a secret in NixOS config

Once a secret exists, declare it in the host's `default.nix`. Pattern:

```nix
sops.defaultSopsFile = ../../../secrets/microvac.yaml;

sops.secrets."root/password-hash" = {
  neededForUsers = true;                    # decrypt early, for user activation
};

sops.secrets."ajlow/ssh/id_ed25519" = {
  sopsFile = ../../../secrets/users/ajlow.yaml;
  owner    = "ajlow";
  group    = "users";
  mode     = "0600";
  path     = "/run/secrets/ajlow_id_ed25519";
};

users.users.root.hashedPasswordFile  = config.sops.secrets."root/password-hash".path;
users.users.ajlow.hashedPasswordFile = config.sops.secrets."ajlow/password-hash".path;
users.mutableUsers = false;
```

Key rules:

- **Path resolution**: `sops.secrets."<name>".path` is `/run/secrets/<name>`
  by default. Override with `path = "..."` for stable paths. For secrets
  with `neededForUsers = true` it's `/run/secrets-for-users/<name>`.
- **`neededForUsers = true`** is mandatory whenever a secret feeds
  `users.users.*.hashedPasswordFile` — otherwise the secret decrypts *after*
  user activation runs and the first boot has no password.
- **`users.mutableUsers = false`** is required so `passwd` at runtime
  doesn't drift from the sops-managed hash.

See `system/hosts/microvac/default.nix` for the canonical commented template
covering passwords, SSH keys, and where to extend it for other secrets
(wireguard, API tokens, etc.).

---

## Common operations

**Edit an existing file**

```bash
sops secrets/microvac.yaml
```

`$EDITOR` opens the decrypted plaintext; sops re-encrypts on save.

**Add a new admin or host key**

1. Paste the age public key into `../.sops.yaml`.
2. Mirror it into `../keys.nix`'s `age` block.
3. `sops updatekeys <file>` for every file in `creation_rules` that lists
   the new key.

**Rotate a leaked secret**

1. Edit the file with `sops`, replace the value.
2. Rebuild the affected hosts (`nixos-rebuild switch`). They'll pick up the
   new ciphertext on next activation; sops-install-secrets writes it to
   `/run/secrets/...` at boot.

**Rotate the host age key** (e.g. after a host SSH key rotation)

1. Generate a new host key on the machine, place at
   `/persist/etc/ssh/ssh_host_ed25519_key` (or `/etc/ssh/...` for cloud
   hosts).
2. Derive the new age pubkey with `ssh-to-age`.
3. Replace the old `&host_<name>` value in `.sops.yaml`.
4. `sops updatekeys` everything referencing that host.
5. Commit, push, rebuild.

**Inspect what's encrypted to whom**

```bash
sops -d secrets/microvac.yaml   # decrypt to stdout
sops -i secrets/microvac.yaml   # print metadata (recipients, etc.)
```

---

## Gotchas

- **Don't `git add` plaintext**. sops only encrypts on save through the
  sops binary. If you write YAML directly with `vim secrets/foo.yaml`,
  `git` will happily commit it in the clear. Always use `sops <file>`.
- **`creation_rules` paths are regex**. The `\.yaml$` anchors matter —
  drop them and you can accidentally match adjacent files.
- **Re-encrypting after key change**. `sops updatekeys` is the only command
  that re-encrypts a file to the current `.sops.yaml`. Just editing won't
  pull in new recipients.
- **Backups**. Losing both the admin key and a host's key locks the
  contents of that host's file permanently. Bitwarden holds the admin
  key; the host key is recoverable by re-installing and re-running the
  bootstrap (you'd then re-encrypt to the new key — but the *contents*
  are lost forever if not also stored elsewhere).
