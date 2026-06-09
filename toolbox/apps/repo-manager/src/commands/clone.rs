use anyhow::Result;
use session::Manifest;
use tracing::info;

use crate::cli::CloneArgs;

/// Stub for `repo-manager clone`.
///
/// # Errors
/// Currently infallible; signature reserved for future fallible logic.
#[allow(clippy::unused_async)] // stub; will await real VCS work once fleshed out
pub async fn run(args: CloneArgs, _manifest: &Manifest) -> Result<()> {
    info!(
        profile = ?args.profile,
        url = %args.url,
        "clone stub",
    );
    println!(
        "repo-manager clone profile={:?} url={}",
        args.profile, args.url,
    );
    Ok(())
}
