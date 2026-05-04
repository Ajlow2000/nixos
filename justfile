hostname := `hostname`
user := `whoami`
system := `nix eval --impure --raw --expr 'builtins.currentSystem'`

# Hostname → ajlow home-manager profile mapping
# Add new machines here (unknown hosts default to "work")
_ajlow_profile := if hostname == "hal9000"  { "personal" } else \
             if hostname == "mindgame" { "personal" } else \
             if hostname == "eddie"    { "work"     } else \
             if hostname == "marvin"   { "work"     } else \
             if hostname == "glados"   { "server"   } else \
                                       { "work"     }

fmt:
    find . -name '*.nix' -exec nixfmt {} +

update-toolbox:
    nix flake lock --update-input toolbox

# impure required for marvin build
os:
    nh os switch --impure .

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
