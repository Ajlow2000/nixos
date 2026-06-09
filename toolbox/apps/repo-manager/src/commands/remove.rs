use anyhow::Result;
use session::Manifest;
use tracing::info;

use crate::cli::RemoveArgs;

/// Stub for `repo-manager remove`.
///
/// # Errors
/// Currently infallible; signature reserved for future fallible logic.
#[allow(clippy::unused_async)] // stub; will await real work once fleshed out
pub async fn run(args: RemoveArgs, _manifest: &Manifest) -> Result<()> {
    info!(force = args.force, "remove stub");
    println!("repo-manager remove (force={})", args.force);
    Ok(())
}
