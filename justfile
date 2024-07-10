hostname := `hostname`
user := `whoami`

nixos:
    sudo nixos-rebuild switch --flake ./#{{hostname}}

hm:
    home-manager switch --flake ./#{{user}}

