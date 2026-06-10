use std::path::PathBuf;

use anyhow::{bail, Context, Result};
use session::Manifest;
use tokio::process::Command;
use tracing::info;

use crate::cli::WorktreeCreateArgs;

/// Creates a new git worktree as a sibling of the current worktree.
///
/// Layout assumed (non-standard bare clone):
///
/// ```text
/// <session_root>/
///   .git/   (bare)
///   main/   (current worktree — `git rev-parse --show-toplevel`)
///   <name>/ (new worktree created here)
/// ```
///
/// Runs `git rev-parse --show-toplevel`, strips the trailing component to get
/// the session root (where the bare `.git/` lives), checks that path is
/// tracked in the manifest, then runs
/// `git worktree add -b <name> <session_root>/<name>`.
///
/// # Errors
/// - Fails if `git rev-parse` can't find a repo (i.e., not inside a git
///   working tree).
/// - Fails if the worktree root has no parent directory.
/// - Fails if the session root is not present in the manifest — this
///   command only operates on "managed sessions".
/// - Surfaces git's exit code if the worktree creation itself fails.
pub async fn run(args: WorktreeCreateArgs, manifest: &Manifest) -> Result<()> {
    let name = &args.name;

    let repo_root = git_repo_root().await?;
    let session_root = repo_root
        .parent()
        .with_context(|| format!("repo root has no parent: {}", repo_root.display()))?;
    let entries = manifest
        .list()
        .with_context(|| format!("reading manifest {}", manifest.path().display()))?;
    if !entries.iter().any(|e| e == session_root) {
        bail!(
            "not a managed session\n  \
             session root: {}\n  \
             manifest:     {}\n  \
             hint:         add the session root to the manifest first",
            session_root.display(),
            manifest.path().display(),
        );
    }

    let worktree_path = session_root.join(name);
    info!(
        name = %name,
        path = %worktree_path.display(),
        "worktree create: git worktree add -b {name} {}",
        worktree_path.display(),
    );

    // Future: optionally install git hooks for this worktree after creation.

    let status = Command::new("git")
        .args(["worktree", "add", "-b", name])
        .arg(&worktree_path)
        .status()
        .await?;

    if !status.success() {
        bail!(
            "git worktree add failed (exit {})",
            status
                .code()
                .map_or_else(|| "signal".to_string(), |c| c.to_string()),
        );
    }
    Ok(())
}

/// Returns the absolute path to the current repository's working-tree root,
/// via `git rev-parse --show-toplevel`.
async fn git_repo_root() -> Result<PathBuf> {
    let output = Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .output()
        .await?;
    if !output.status.success() {
        bail!(
            "not inside a git repository\n  \
             hint: cd into a tracked worktree before running `worktree create`"
        );
    }
    let s = String::from_utf8_lossy(&output.stdout);
    let trimmed = s.trim();
    if trimmed.is_empty() {
        bail!("git rev-parse --show-toplevel returned an empty path");
    }
    Ok(PathBuf::from(trimmed))
}
