use anyhow::Result;
use session::Manifest;
use tracing::info;

use crate::cli::WorktreeRemoveArgs;

/// Stub for `repo-manager worktree remove`.
///
/// # Errors
/// Currently infallible; signature reserved for future fallible logic.
#[allow(clippy::unused_async)] // stub; will await real `git worktree remove` work later
pub async fn run(args: WorktreeRemoveArgs, _manifest: &Manifest) -> Result<()> {
    info!(name = %args.name, "worktree remove stub");
    println!("repo-manager worktree remove (stub) name={}", args.name);
    Ok(())
}
