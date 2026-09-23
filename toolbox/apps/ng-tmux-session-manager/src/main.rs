use session::Manifest;
use std::collections::HashMap;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio, exit};
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    let manifest = Manifest::open_default();
    let paths: Vec<PathBuf> = manifest.list().unwrap_or_default();
    let active = tmux_sessions();
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let mut lines: Vec<String> = Vec::new();
    let mut manifest_sessions: HashMap<String, PathBuf> = HashMap::new();

    for path in &paths {
        let name = path_to_session_name(path);
        manifest_sessions.insert(name.clone(), path.clone());
        if let Some(&created) = active.get(&name) {
            let uptime = format_uptime(now.saturating_sub(created));
            lines.push(format!("* {}\t[{}]", path.display(), uptime));
        } else {
            lines.push(format!("  {}", path.display()));
        }
    }

    for (session, &created) in &active {
        if !manifest_sessions.contains_key(session) {
            let uptime = format_uptime(now.saturating_sub(created));
            lines.push(format!("@ {}\t[{}]", session, uptime));
        }
    }

    if lines.is_empty() {
        eprintln!("ng-tsm: manifest is empty and no active tmux sessions");
        exit(1);
    }

    let selected = run_fzf(&lines);
    if selected.is_empty() {
        exit(0);
    }

    // Strip the tab-separated uptime column before parsing
    let data = selected.split('\t').next().unwrap_or(&selected);

    if let Some(name) = data.strip_prefix("@ ") {
        tmux_attach_or_switch(name);
    } else {
        let path_str = data
            .strip_prefix("* ")
            .or_else(|| data.strip_prefix("  "))
            .unwrap_or(data);
        let path = PathBuf::from(path_str);
        let name = path_to_session_name(&path);
        if !active.contains_key(&name) {
            let status = Command::new("tmux")
                .args(["new-session", "-d", "-s", &name, "-c", path_str])
                .status()
                .expect("failed to spawn tmux");
            if !status.success() {
                eprintln!("ng-tsm: failed to create session '{}'", name);
                exit(1);
            }
        }
        tmux_attach_or_switch(&name);
    }
}

fn path_to_session_name(path: &Path) -> String {
    path.file_name()
        .unwrap_or_default()
        .to_string_lossy()
        .to_lowercase()
        .replace(['.', ' ', ':'], "-")
}

fn tmux_sessions() -> HashMap<String, u64> {
    let out = Command::new("tmux")
        .args(["list-sessions", "-F", "#{session_name} #{session_created}"])
        .output();
    match out {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout)
            .lines()
            .filter_map(|line| {
                let mut parts = line.splitn(2, ' ');
                let name = parts.next()?.to_owned();
                let ts: u64 = parts.next()?.trim().parse().ok()?;
                Some((name, ts))
            })
            .collect(),
        _ => HashMap::new(),
    }
}

fn format_uptime(secs: u64) -> String {
    if secs < 60 {
        format!("{}s", secs)
    } else if secs < 3600 {
        format!("{}m", secs / 60)
    } else if secs < 86400 {
        let h = secs / 3600;
        let m = (secs % 3600) / 60;
        if m == 0 {
            format!("{}h", h)
        } else {
            format!("{}h {}m", h, m)
        }
    } else {
        let d = secs / 86400;
        let h = (secs % 86400) / 3600;
        if h == 0 {
            format!("{}d", d)
        } else {
            format!("{}d {}h", d, h)
        }
    }
}

fn run_fzf(lines: &[String]) -> String {
    let mut child = Command::new("fzf")
        .args(["--reverse"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("failed to spawn fzf");

    {
        let stdin = child.stdin.as_mut().expect("failed to open fzf stdin");
        stdin
            .write_all(lines.join("\n").as_bytes())
            .expect("failed to write to fzf");
    }

    let output = child.wait_with_output().expect("fzf did not exit cleanly");
    String::from_utf8_lossy(&output.stdout).trim_end().to_owned()
}

fn tmux_attach_or_switch(session: &str) {
    let inside_tmux = std::env::var("TMUX").is_ok();
    let args: &[&str] = if inside_tmux {
        &["switch-client", "-t", session]
    } else {
        &["attach", "-t", session]
    };
    let status = Command::new("tmux")
        .args(args)
        .status()
        .expect("failed to spawn tmux");
    exit(status.code().unwrap_or(1));
}
