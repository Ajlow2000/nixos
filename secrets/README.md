# Secrets

This directory holds sops-encrypted secret files. The currently-managed scope
is **per-host root and user login passwords**. Everything is encrypted at rest
in the repo and decrypted on the target host at NixOS activation time using
the host's SSH ed25519 host key.

## Layout

```
secrets/
├── README.md              this file
└── hosts/
    └── <hostname>.yaml    one encrypted file per host
```

Each `hosts/<host>.yaml` contains hashed passwords keyed by username, e.g.:

```yaml
root:  $y$j9T$...
ajlow: $y$j9T$...
alowry: $y$j9T$...   # only on hosts where alowry is enabled
```

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

For each (host, account) pair, generate a yescrypt hash:

```sh
mkpasswd -m yescrypt
```

Type the password twice. The output (`$y$j9T$...`) is what goes into the
secrets file. Plan a password per host per account up front.

### 6. Create and encrypt the per-host secret files

For each enrolled host:

```sh
cat > secrets/hosts/<host>.yaml <<EOF
root:  $y$j9T$...REPLACE_WITH_HASH_FROM_STEP_5
ajlow: $y$j9T$...
alowry: $y$j9T$...     # only on hosts that enable alowry
EOF

sops --encrypt --in-place secrets/hosts/<host>.yaml
```

(You'll need at least one YubiKey inserted; sops will prompt for touch.)

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
sops secrets/hosts/hal9000.yaml

# Re-key after editing .sops.yaml (added/removed recipients)
sops updatekeys secrets/hosts/hal9000.yaml

# Decrypt to stdout for inspection
sops --decrypt secrets/hosts/hal9000.yaml
```

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
