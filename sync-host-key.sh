#!/usr/bin/env bash
#
# sync-host-key.sh — make THIS host's /etc/ssh/ssh_host_ed25519_key match the
# key stored in secrets/hosts/<host>.yaml (root.ssh_private_key), so sops-nix
# can decrypt its secrets.
#
# Use this when a host's live SSH host key doesn't match the &host_<name> key
# enrolled in .sops.yaml — symptom during `nixos-rebuild`/`nh os switch`:
#
#     sops-install-secrets: failed to decrypt '.../common.yaml':
#       Error getting data key: 0 successful groups required, got 0
#
# Run it LOCALLY on the host, at the console, with your admin YubiKey plugged
# in (needed to decrypt the stored key — the host itself can't yet). Best run
# inside `nix develop` so sops/ssh-to-age are on PATH.
#
# Usage:  ./sync-host-key.sh [hostname]      (defaults to `hostname`)
# After it finishes:  just os                (rebuild so sops materializes)

set -euo pipefail

host="${1:-$(hostname)}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"
secret="secrets/hosts/${host}.yaml"

# --- preflight ---
for t in sops ssh-to-age ssh-keygen awk sudo install; do
  command -v "$t" >/dev/null 2>&1 || { echo "missing tool: $t (run inside 'nix develop')" >&2; exit 1; }
done
[[ -f "$secret" ]] || { echo "no such secret file: $secret" >&2; exit 1; }

# --- expected recipient from .sops.yaml (anti-lockout: never install a key
#     that isn't the one the secrets are actually encrypted to) ---
alias_name="host_$(echo "$host" | tr '-' '_')"
want="$(awk -v a="&$alias_name" '$1=="-" && $2==a {print $3; exit}' .sops.yaml)"
[[ -n "$want" ]] || { echo "no &$alias_name recipient in .sops.yaml" >&2; exit 1; }

# --- decrypt the stored host key to a temp file, guaranteed-shred on exit ---
tmp="$(mktemp)"
trap 'shred -u "$tmp" 2>/dev/null || rm -f "$tmp"' EXIT INT TERM
chmod 600 "$tmp"

echo "==> decrypting host key from $secret (YubiKey touch/PIN) ..."
sops decrypt --extract '["root"]["ssh_private_key"]' "$secret" > "$tmp"

# --- verify it matches the enrolled recipient BEFORE touching /etc/ssh ---
got="$(ssh-keygen -y -f "$tmp" | ssh-to-age)"
[[ "$got" == "$want" ]] || {
  echo "MISMATCH: stored key is $got but .sops.yaml expects $want — ABORT" >&2
  exit 1
}
echo "    verified: stored key == $want"

# --- install locally as the host key + regenerate the public half ---
echo "==> installing /etc/ssh/ssh_host_ed25519_key ..."
sudo install -m 600 -o root -g root "$tmp" /etc/ssh/ssh_host_ed25519_key
sudo ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key \
  | sudo tee /etc/ssh/ssh_host_ed25519_key.pub >/dev/null
sudo chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
sudo systemctl restart sshd.service
echo "    host key installed; sshd restarted"

cat <<EOF

==> done. eddie's host key now matches sops.
    Next: rebuild so the secrets get materialized:

        just os

    NOTE: this host's SSH identity changed. On any OTHER machine that SSHes
    here, clear the stale entry first:  ssh-keygen -R $host
EOF
