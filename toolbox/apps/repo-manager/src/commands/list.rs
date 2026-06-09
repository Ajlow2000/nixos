use anyhow::Result;
use owo_colors::{OwoColorize, Stream};
use session::Manifest;
use tracing::info;

use crate::cli::ListArgs;

/// Lists every entry in the manifest, flagging paths that no longer exist
/// with a yellow `[missing]` suffix.
///
/// # Errors
/// Propagates I/O errors from reading the manifest file.
pub fn run(_args: ListArgs, manifest: &Manifest) -> Result<()> {
    info!(manifest = %manifest.path().display(), "listing manifest entries");

    for entry in manifest.list()? {
        if entry.exists() {
            println!("{}", entry.display());
        } else {
            println!(
                "{} {}",
                entry.display(),
                "[missing]".if_supports_color(Stream::Stdout, |s| s.yellow()),
            );
        }
    }
    Ok(())
}
