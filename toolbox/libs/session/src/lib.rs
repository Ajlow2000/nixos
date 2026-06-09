//! Shared session-management primitives.
//!
//! Library crate; the public API will grow as logic is hoisted out of the
//! session-aware app crates (tmux-session-manager, ng-tmux-session-manager,
//! session-aware-cd).

pub mod manifest;
pub use manifest::{default_manifest_path, Manifest, DEFAULT_MANIFEST_PATH};

pub const SESSION_HOME: &str = "AJLOW_SESSION_HOME";
