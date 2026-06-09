use std::ffi::OsStr;
use std::path::PathBuf;
use std::process::Command as StdCommand;

use clap::{Args, Parser, Subcommand, ValueEnum};
use clap_complete::engine::ArgValueCompleter;
use clap_complete::CompletionCandidate;
use clap_verbosity_flag::{OffLevel, Verbosity};

#[derive(Parser, Debug)]
#[command(name = "repo-manager", version, about = "Manage local git repos")]
pub struct Cli {
    #[command(flatten)]
    pub verbose: Verbosity<OffLevel>,

    /// Path to the manifest file (the list of tracked repo directories).
    #[arg(long, global = true, default_value_os_t = session::DEFAULT_MANIFEST_PATH.clone())]
    pub manifest: PathBuf,

    #[command(subcommand)]
    pub command: Command,
}

#[derive(Subcommand, Debug)]
pub enum Command {
    /// Clone a repository.
    Clone(CloneArgs),
    /// List tracked repositories.
    List(ListArgs),
    /// Audit tracked repositories for local-only changes
    Audit(AuditArgs),
    /// Remove a tracked repository.
    Remove(RemoveArgs),
    /// Switch setup a worktree/local branch pair
    Switch(SwitchArgs),
}

#[derive(Args, Debug)]
pub struct CloneArgs {
    /// Identity profile to clone under.
    pub profile: GitProfile,

    /// Repository URL.
    pub url: String,
}

/// Named identity profile applied to clones.
#[derive(ValueEnum, Debug, Clone, Copy, PartialEq, Eq)]
pub enum GitProfile {
    Personal,
    Sram,
}

#[derive(Args, Debug)]
pub struct ListArgs {}

#[derive(Args, Debug)]
pub struct AuditArgs {}

#[derive(Args, Debug)]
pub struct RemoveArgs {
    /// Skip safety checks and remove repo from disk and tracked dirs
    #[arg(short, long)]
    pub force: bool,
}

#[derive(Args, Debug)]
pub struct SwitchArgs {
    /// Branch to switch to. Tab-completes from local branches in the current
    /// working directory.
    #[arg(add = ArgValueCompleter::new(local_branches))]
    pub branch: String,
}

/// Lists local git branches matching the current completion prefix.
fn local_branches(current: &OsStr) -> Vec<CompletionCandidate> {
    let prefix = current.to_string_lossy();
    let output = match StdCommand::new("git")
        .args(["branch", "--list", "--format=%(refname:short)"])
        .output()
    {
        Ok(o) if o.status.success() => o.stdout,
        _ => return Vec::new(),
    };
    String::from_utf8_lossy(&output)
        .lines()
        .filter(|b| b.starts_with(prefix.as_ref()))
        .map(CompletionCandidate::new)
        .collect()
}
