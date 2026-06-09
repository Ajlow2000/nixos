use anyhow::Result;
use session::Manifest;
use tracing::info;

use crate::cli::AuditArgs;

/// Stub for `repo-manager audit`.
///
/// # Errors
/// Currently infallible; signature reserved for future fallible logic.
#[allow(clippy::unused_async)] // stub; will await real work once fleshed out
pub async fn run(_args: AuditArgs, _manifest: &Manifest) -> Result<()> {
    info!("audit stub");
    println!("repo-manager audit");
    Ok(())
}
