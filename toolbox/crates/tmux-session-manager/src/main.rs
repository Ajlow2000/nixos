use std::process::{exit, Command};

// Verbatim port of https://github.com/27medkamal/tmux-session-wizard. This crate
// is a placeholder so the `tmux-session-manager` binary keeps existing under the
// same name (it is referenced by tmux.conf, hyprland.conf, and zsh aliases)
// while a pure-Rust implementation is in flight.
const SCRIPT: &str = r##"
set -o errexit
set -o nounset
set -o pipefail

__fzfcmd() {
    [ -n "${TMUX_PANE:-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS:-}" ]; } &&
        echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

RESULT=$( (tmux list-sessions -F "#{session_name}: #{session_windows} window(s)\
    #{?session_grouped, (group ,}#{session_group}#{?session_grouped,),}\
    #{?session_attached, (attached),}"; zoxide query -l) | $(__fzfcmd) --reverse)

if [ -z "$RESULT" ]; then
    exit 0
fi

if [[ $RESULT == *":"* ]]; then
    SESSION=$(echo -e "$RESULT" | awk '{print $1}')
    SESSION=${SESSION//:/}
else
    SESSION=$(basename "$RESULT" | tr . - | tr ' ' - | tr ':' - | tr '[:upper:]' '[:lower:]')
    if ! tmux has-session -t="$SESSION" 2> /dev/null; then
        tmux new-session -d -s "$SESSION" -c "$RESULT"
    fi
fi

if [ -z "${TMUX:-}" ]; then
    tmux attach -t "$SESSION"
else
    tmux switch-client -t "$SESSION"
fi
"##;

fn main() {
    let status = Command::new("bash")
        .arg("-c")
        .arg(SCRIPT)
        .status()
        .expect("failed to spawn bash");
    exit(status.code().unwrap_or(1));
}
