use std::path::PathBuf;

use clap::{Args, Parser, Subcommand, ValueEnum};
use clap_verbosity_flag::{OffLevel, Verbosity};

#[derive(Parser, Debug)]
#[command(name = "repo-manager", version, about = "Manage local git repos")]
pub struct Cli {
    #[command(flatten)]
    pub verbose: Verbosity<OffLevel>,

    /// Path to the manifest file (the list of tracked repo directories).
    #[arg(long, global = true, default_value_os_t = session::default_manifest_path())]
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
}

#[derive(Args, Debug)]
pub struct CloneArgs {
    /// Identity profile to clone under.
    pub profile: GitProfile,

    /// Repository URL.
    pub url: String,

    /// Version-control system to use.
    #[arg(long, value_enum, default_value_t)]
    pub vcs: SupportedVcs,
}

/// Named identity profile applied to clones.
#[derive(ValueEnum, Debug, Clone, Copy, PartialEq, Eq)]
pub enum GitProfile {
    Personal,
    Sram,
}

/// Supported version-control systems for `repo-manager clone`.
#[derive(ValueEnum, Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum SupportedVcs {
    #[default]
    Git,
    Pijul,
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
