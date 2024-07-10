hostname := `hostname`
user := `whoami`

nixos:
    sudo nixos-rebuild switch --impure --flake ./#{{hostname}}

hm:
    home-manager switch --flake ./#{{user}}

