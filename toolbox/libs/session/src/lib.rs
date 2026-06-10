//! Shared session-management primitives.
//!
//! Library crate; the public API will grow as logic is hoisted out of the
//! session-aware app crates (tmux-session-manager, ng-tmux-session-manager,
//! session-aware-cd).

use std::path::PathBuf;
use std::sync::LazyLock;

pub mod manifest;
pub use manifest::Manifest;

pub const SESSION_HOME: &str = "AJLOW_SESSION_HOME";

/// Default location of the on-disk manifest, resolved on first access as
/// `dirs::data_dir().join("ajlow-session/manifest")`. Falls back to a path
/// rooted at `.` when no home directory is set (rare).
pub static DEFAULT_MANIFEST_PATH: LazyLock<PathBuf> = LazyLock::new(|| {
    dirs::data_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("managed-sessions/manifest")
});

/// Default location of managed repositories, resolved on first access as
/// `dirs::home_dir().join("repos")`. Falls back to a path rooted at `.` when
/// no home directory is set (rare).
pub static DEFAULT_REPO_HOME: LazyLock<PathBuf> = LazyLock::new(|| {
    dirs::home_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join("ng-repos")
});
