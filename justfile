hostname := `hostname`
user := `whoami`
system := `nix eval --impure --raw --expr 'builtins.currentSystem'`

# Hostname → ajlow home-manager profile mapping
# Add new machines here (unknown hosts default to "work")
_ajlow_profile := if hostname == "hal9000"  { "personal" } else \
             if hostname == "mindgame"      { "personal" } else \
             if hostname == "eddie"         { "work"     } else \
             if hostname == "marvin"        { "work"     } else \
             if hostname == "glados"        { "server"   } else \
             if hostname == "do-prod-01"    { "server"   } else \
                                            { "work"     }

fmt:
    find . -name '*.nix' -exec nixfmt {} +

# Re-encrypt every secrets/*.yaml to its current .sops.yaml recipients.
# Run after editing .sops.yaml (e.g. enrolling a new &host_<name> key).
# YubiKey required for the decrypt half of each updatekeys.
sops:
    #!/usr/bin/env bash
    set -euo pipefail
    find secrets -type f -name '*.yaml' -print0 | sort -z | while IFS= read -r -d '' f; do
      echo "==> sops updatekeys $f"
      sops updatekeys -y "$f"
    done

update-toolbox:
    nix flake lock --update-input toolbox

# impure required for marvin build
os:
    nh os switch --impure .

# Stages the host key (= root's sops key) from secrets/hosts/<hostname>.yaml into a
# /tmp/<pid> dir, seeds it with --extra-files, and ALWAYS shreds it afterward.
# Preconditions: host is install-ready (modules.sops.enable = true, &host_<hostname>
# enrolled in .sops.yaml, and `sops updatekeys secrets/common.yaml` run). YubiKey
# required for the sops decrypt.
#
# DESTRUCTIVE first-time nixos-anywhere install (reformats target). Usage: just install <hostname> <ip>
install hostname ip:
    #!/usr/bin/env bash
    set -euo pipefail

    secret="secrets/hosts/{{hostname}}.yaml"

    # --- preflight ---
    for t in sops ssh-to-age ssh-keygen nix ping shred awk; do
      command -v "$t" >/dev/null 2>&1 || { echo "missing tool: $t (run inside 'nix develop')" >&2; exit 1; }
    done
    [[ -f "$secret" ]] || { echo "no such secret file: $secret" >&2; exit 1; }

    # --- 1. reachability ---
    echo "==> pinging {{ip}} ..."
    ping -c1 -W3 {{ip}} >/dev/null 2>&1 || { echo "{{ip}} is not reachable" >&2; exit 1; }
    echo "    reachable"

    # --- staging dir + guaranteed shred (set BEFORE writing any key material) ---
    stage="/tmp/$$"
    mkdir -p "$stage/etc/ssh"
    cleanup() {
      if [[ -d "$stage" ]]; then
        find "$stage" -type f -exec shred -vzu {} + 2>/dev/null || true
        rm -rf "$stage"
      fi
    }
    trap cleanup EXIT INT TERM

    # --- 2. stage host key from sops (root.ssh_private_key) ---
    echo "==> staging host key from $secret ..."
    sops decrypt --extract '["root"]["ssh_private_key"]' "$secret" \
      > "$stage/etc/ssh/ssh_host_ed25519_key"
    chmod 600 "$stage/etc/ssh/ssh_host_ed25519_key"
    ssh-keygen -y -f "$stage/etc/ssh/ssh_host_ed25519_key" \
      > "$stage/etc/ssh/ssh_host_ed25519_key.pub"

    # --- verify the staged key matches the host's sops recipient (avoid lockout) ---
    alias_name="host_$(echo {{hostname}} | tr '-' '_')"
    want="$(awk -v a="&$alias_name" '$1=="-" && $2==a {print $3; exit}' .sops.yaml)"
    got="$(ssh-to-age -i "$stage/etc/ssh/ssh_host_ed25519_key.pub")"
    [[ -n "$want" ]] || { echo "no &$alias_name recipient in .sops.yaml" >&2; exit 1; }
    [[ "$got" == "$want" ]] || { echo "recipient mismatch: staged=$got .sops.yaml=$want" >&2; exit 1; }
    echo "    recipient ok ($got)"

    # --- 3. install ---
    echo "==> installing {{hostname}} -> root@{{ip}} (reformats disk) ..."
    nix run github:nix-community/nixos-anywhere -- \
      --flake ".#{{hostname}}" \
      --extra-files "$stage" \
      --ssh-option StrictHostKeyChecking=accept-new \
      root@{{ip}}

    # --- 4. shred runs automatically via the EXIT trap ---
    echo "==> done"

remote hostname:
    nh os switch \
        --hostname {{hostname}} \
        --target-host ajlow@{{hostname}} \
        --build-host localhost \
        --impure \
        .

hm:
    nh home switch --backup-extension backup -c ajlow-{{_ajlow_profile}} .

lsip:
    echo "$(nix-store --query --requisites /run/current-system | cut -d- -f2-)\n$(home-manager packages)" | sort | uniq

ls-nixos-packages:
    @nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq

ls-hm-packages:
    @home-manager packages | sort | uniq

prefetch url:
    @nix store prefetch-file --hash-type sha256 {{url}}

vm host:
    nix run .#vm-{{host}}

nb:
    netbird up --allow-server-ssh --disable-ssh-auth

# unzip:
#     gunzip < result/nixos-image-*.qcow2.gz > nixos-do-prod-01.qcow2
