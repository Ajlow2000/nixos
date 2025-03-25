hostname := `hostname`
user := `whoami`

update-toolbox:
    nix flake lock --update-input toolbox

# impure required for marvin build
os:
    sudo nixos-rebuild switch --flake ./#{{hostname}} --impure 

hm:
    home-manager switch --flake ./#{{user}}

lsip:
    echo "$(nix-store --query --requisites /run/current-system | cut -d- -f2-)\n$(home-manager packages)" | sort | uniq

ls-nixos-packages:
    @nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq

ls-hm-packages:
    @home-manager packages | sort | uniq
