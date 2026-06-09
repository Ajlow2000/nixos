pub mod create;
pub mod remove;

use anyhow::Result;
use session::Manifest;

use crate::cli::{WorktreeArgs, WorktreeCommand};

/// Dispatches the nested `worktree` subcommands.
///
/// # Errors
/// Propagates whatever the selected subcommand returns.
pub async fn run(args: WorktreeArgs, manifest: &Manifest) -> Result<()> {
    match args.command {
        WorktreeCommand::Create(a) => create::run(a, manifest).await,
        WorktreeCommand::Remove(a) => remove::run(a, manifest).await,
    }
}
