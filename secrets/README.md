# Secrets

This directory holds sops-encrypted secret files. The currently-managed scope
is **per-host root and user login passwords**. Everything is encrypted at rest
in the repo and decrypted on the target host at NixOS activation time using
the host's SSH ed25519 host key.

## Layout

```
secrets/
├── README.md              this file
├── common.yaml            shared user-account passwords (every enrolled host decrypts)
└── hosts/
    └── <hostname>.yaml    per-host root password (only that host decrypts)
```

`common.yaml` holds hashed user passwords keyed `<account>_passwd`:

```yaml
ajlow_passwd:  $y$j9T$...
alowry_passwd: $y$j9T$...   # only consumed on hosts where alowry is enabled
```

Each `hosts/<host>.yaml` holds that host's unique root password:

```yaml
root_passwd: $y$j9T$...
```

Split rationale: the user account is the same human across hosts, so sharing
one hash is fine. The root password is per-host so a compromise of one host's
age key doesn't expose root on the others.

## Recipient registry

`.sops.yaml` at the repo root defines who can decrypt what:

- **Admin recipients** (decrypt everything for editing):
  - YubiKey 1 — `age-plugin-yubikey` PIV identity
  - YubiKey 2 — `age-plugin-yubikey` PIV identity
  - Software backup — age key stored in Bitwarden Secure Note "sops admin backup"
- **Per-host recipients** (one per machine, derived from SSH host key) — each
  host can decrypt only its own file at activation time.

## First-time bootstrap

Do these once. Subsequent password changes are just `sops <file>` + redeploy.

### 1. Enter the dev shell (gets sops, age, age-plugin-yubikey, ssh-to-age, mkpasswd)

```sh
nix develop
```

### 2. Generate the YubiKey age identities (do this twice — once per key)

Insert YubiKey 1, then:

```sh
age-plugin-yubikey --generate
```

Prompts for PIN and touch. Output ends with `Recipient: age1...` — copy that
line and paste it into `.sops.yaml` under `&admin_yubikey_01`. Repeat with
YubiKey 2 → `&admin_yubikey_02`.

### 3. Generate the software backup key

```sh
age-keygen -o /tmp/sops-backup.txt
```

- The line beginning `# public key: age1...` is the recipient → paste into
  `.sops.yaml` under `&admin_backup`.
- The line beginning `AGE-SECRET-KEY-1...` is the private key → paste into a
  new Bitwarden Secure Note titled "sops admin backup". Save.
- Shred the temp file: `shred -u /tmp/sops-backup.txt`.

### 4. Capture each host's age recipient

For every host already running NixOS (hal9000, microvac, glados, do-prod-01),
from your admin machine:

```sh
ssh root@<host> 'cat /etc/ssh/ssh_host_ed25519_key.pub' | ssh-to-age
```

Paste the resulting `age1...` line into `.sops.yaml` under the corresponding
`&host_<host>` alias, and uncomment that host's `creation_rules` block.

Hosts that haven't been built yet (mindgame, multivac, eddie, marvin) get
enrolled on first install — leave them commented for now.

### 5. Hash passwords

Generate a yescrypt hash for each password you need:

```sh
mkpasswd -m yescrypt
```

Type the password twice. The output (`$y$j9T$...`) is the value that goes
into a secrets file. You need:

- one hash per user account (shared across hosts) → `common.yaml`
- one hash per host for the root account → `hosts/<host>.yaml`

### 6. Create and encrypt the secret files

Shared user passwords:

```sh
sops secrets/common.yaml
# Then add:
# ajlow_passwd:  $y$j9T$...
# alowry_passwd: $y$j9T$...
```

Per-host root password (run once per enrolled host):

```sh
sops secrets/hosts/<host>.yaml
# Then add:
# root_passwd: $y$j9T$...
```

`sops` picks the right recipient set from `.sops.yaml` based on the file
path. You'll need at least one YubiKey inserted; sops will prompt for touch.

### 7. Enable sops on the host

In `system/hosts/<host>/default.nix`, add:

```nix
modules.sops.enable = true;
```

That flips `users.mutableUsers = false` and points `hashedPasswordFile` at the
decrypted secret for root and any enabled users.

### 8. Deploy carefully

**Have a second login session open** before rebuilding, in case a typo locks
you out. For local hosts:

```sh
just os
```

For do-prod-01:

```sh
just vps
```

Verify console login works with the new password before closing your fallback
session. The DigitalOcean web console is the ultimate fallback for do-prod-01.

## Day-to-day operations

```sh
# Edit an existing secret (prompts YubiKey)
sops secrets/common.yaml
sops secrets/hosts/hal9000.yaml

# Re-key after editing .sops.yaml (added/removed recipients)
sops updatekeys secrets/common.yaml
sops updatekeys secrets/hosts/hal9000.yaml

# Decrypt to stdout for inspection
sops --decrypt secrets/hosts/hal9000.yaml
```

## Rotating ajlow's SSH key on a host

The private key lives in `secrets/hosts/<host>.yaml` under `ajlow_ssh_key`;
the matching public key lives in `keys.nix` under `personal.<host>`. Both
update in the same commit so deploys land them atomically.

```sh
# 1. Generate a fresh keypair locally (no passphrase)
ssh-keygen -t ed25519 -C "ajlow@<host>" -f /tmp/k -N ""

# 2. Paste the private key into the sops file under `ajlow_ssh_key: |`
sops secrets/hosts/<host>.yaml

# 3. Replace the public key in keys.nix under `personal.<host>`
cat /tmp/k.pub          # copy this line
$EDITOR keys.nix

# 4. Wipe the tempfiles
shred -u /tmp/k /tmp/k.pub

# 5. Deploy (local host or remote)
just os                 # or: just vps
```

After the deploy, `/home/ajlow/.ssh/id_ed25519` will contain the new private
key with mode 0600.

## Adding a new host

1. Enroll the host's age key: paste its `ssh-to-age` output into `.sops.yaml`
   under `&host_<name>`, and add `- *host_<name>` to the `common.yaml`
   creation rule (so the host can decrypt shared user passwords).
2. Add a new `creation_rules` block in `.sops.yaml` for
   `secrets/hosts/<name>\.yaml$` with just the admins + that host's key.
3. Re-key shared secrets: `sops updatekeys secrets/common.yaml`.
4. Create the per-host file with a new root password hash:
   `sops secrets/hosts/<name>.yaml`.
5. In the host's `default.nix`, set `modules.sops.enable = true`. The path
   to the per-host file is auto-derived from `config.networking.hostName`.

## Recovering with the Bitwarden backup

If both YubiKeys are unavailable:

```sh
mkdir -p ~/.config/sops/age
# Paste the AGE-SECRET-KEY-1... line from Bitwarden into this file
$EDITOR ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Now sops -d / sops <file> work without a YubiKey
```

Remove the file after the emergency: `shred -u ~/.config/sops/age/keys.txt`.
