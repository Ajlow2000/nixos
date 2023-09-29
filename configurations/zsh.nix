{ config, lib, pkgs, ... }:

{
    programs.zsh = {
        enable = true;
        localVariables = {
            REPORTTIME = 60;
        };
        initExtra = ''
        precmd() {
            precmd() {
                echo
            }
        }

        function chpwd() {
            emulate -L zsh
            zoxide add $(pwd)
        }

        setopt inc_append_history_time

        # opam configuration
        [[ ! -r /home/ajlow/.opam/opam-init/init.zsh ]] || source /home/ajlow/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

        eval "$(zoxide init zsh)"

        PROMPT="%{$fg[green]%}[%{$fg[blue]%}%n@%{$fg[blue]%}%m%{ $fg[green]%}%~]%{$reset_color%} "
        RPROMPT="%(?..%F{red}%?%f )[%* %D{%Z}]"
        '';
        zplug = {
            enable = true;
            plugins = [
                { name = "jeffreytse/zsh-vi-mode"; }
            ];
        };
    };

    
}
