hostname := `hostname`
user := `whoami`
system := `nix eval --impure --raw --expr 'builtins.currentSystem'`

update-toolbox:
    nix flake lock --update-input toolbox

# impure required for marvin build
os:
    sudo nixos-rebuild switch --flake ./#{{hostname}} --impure

hm:
    home-manager switch -b backup --flake ./#{{user}}@{{system}}

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
