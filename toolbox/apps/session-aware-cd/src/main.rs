use std::env;
use std::process::exit;

use session::SESSION_HOME;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.first().map(String::as_str) == Some("init") {
        let shell = args.get(1).map_or("zsh", String::as_str);
        print_init(shell);
        return;
    }

    let target = match args.as_slice() {
        [] => env::var(SESSION_HOME)
            .ok()
            .filter(|s| !s.is_empty())
            .or_else(|| env::var("HOME").ok())
            .unwrap_or_else(|| {
                eprintln!("session-aware-cd: neither ${SESSION_HOME} nor $HOME is set");
                exit(1);
            }),
        [first, ..] => first.clone(),
    };

    println!("{target}");
}

fn print_init(shell: &str) {
    match shell {
        "zsh" => print!(
            r#"# session-aware-cd shell integration.
# Override `cd` so a bare `cd` goes to $AJLOW_SESSION_HOME (when set) instead
# of $HOME. Use zsh's chpwd_functions for any post-cd hooks (eza, etc.) --
# they fire on every directory change regardless of how cd is invoked.
cd() {{
    builtin cd "$(command session-aware-cd "$@")" || return
}}
"#
        ),
        other => {
            eprintln!("session-aware-cd: unsupported shell {other}");
            exit(1);
        }
    }
}
