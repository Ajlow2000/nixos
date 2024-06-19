{ config, pkgs, ... }: {
    users.users.ajlow = {
        isNormalUser = true;
        description = "Alec Lowry";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.zsh;
    };
}
