use anyhow::Result;
use session::Manifest;
use tracing::info;

use crate::cli::SwitchArgs;

/// Stub for `repo-manager switch`.
///
/// # Errors
/// Currently infallible; signature reserved for future fallible logic.
#[allow(clippy::unused_async)] // stub; will await real work once fleshed out
pub async fn run(args: SwitchArgs, _manifest: &Manifest) -> Result<()> {
    info!(branch = %args.branch, "switch stub");
    println!("repo-manager switch branch={}", args.branch);
    Ok(())
}
