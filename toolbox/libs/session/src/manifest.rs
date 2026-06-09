//! On-disk manifest of directories that can become sessions.
//!
//! Persisted as a plain-text, one-path-per-line file (UTF-8). Writes are
//! atomic (write-temp-then-rename). The default manifest lives at
//! `dirs::data_dir().join("ajlow-session/manifest")`.

use std::env;
use std::fs;
use std::io::{self, BufRead, BufReader, Write};
use std::path::{Path, PathBuf};

use tempfile::NamedTempFile;

/// Path fragment, relative to the platform data dir. Public so consumers can
/// reference it (e.g., as a clap default); prefer `default_manifest_path()`
/// when you want the fully resolved path.
pub const DEFAULT_MANIFEST_PATH: &str = "managed-sessions/manifest";

/// Returns the fully-resolved default manifest path,
/// `dirs::data_dir().join(DEFAULT_MANIFEST_PATH)`.
///
/// Falls back to `./DEFAULT_MANIFEST_PATH` if the platform data dir cannot
/// be resolved (rare; would mean no `$HOME` on Unix). Always returns a value
/// so CLI default-value attributes never fail.
#[must_use]
pub fn default_manifest_path() -> PathBuf {
    dirs::data_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join(DEFAULT_MANIFEST_PATH)
}

/// Owns reads/writes to the on-disk manifest of tracked session directories.
pub struct Manifest {
    path: PathBuf,
}

impl Manifest {
    /// Opens a handle pointing at the default manifest location.
    ///
    /// # Errors
    /// Returns an `io::Error` of kind `NotFound` if the platform data
    /// directory cannot be resolved (e.g., no `$HOME` set on Unix).
    pub fn open_default() -> io::Result<Self> {
        let data = dirs::data_dir().ok_or_else(|| {
            io::Error::new(
                io::ErrorKind::NotFound,
                "could not resolve platform data directory",
            )
        })?;
        Ok(Self {
            path: data.join(DEFAULT_MANIFEST_PATH),
        })
    }

    /// Opens a handle pointing at the given file path. Useful for tests or
    /// for callers that want to use a non-default location.
    #[must_use]
    pub fn at(path: impl Into<PathBuf>) -> Self {
        Self { path: path.into() }
    }

    /// Returns the file path this handle reads from / writes to.
    #[must_use]
    pub fn path(&self) -> &Path {
        &self.path
    }

    /// Returns every tracked directory in insertion order.
    ///
    /// If the manifest file does not exist yet, returns an empty vec.
    ///
    /// # Errors
    /// Returns the underlying I/O error if reading the file fails for any
    /// reason other than "file not found".
    pub fn list(&self) -> io::Result<Vec<PathBuf>> {
        let file = match fs::File::open(&self.path) {
            Ok(f) => f,
            Err(e) if e.kind() == io::ErrorKind::NotFound => return Ok(Vec::new()),
            Err(e) => return Err(e),
        };
        let reader = BufReader::new(file);
        let mut out = Vec::new();
        for line in reader.lines() {
            let line = line?;
            let trimmed = line.trim();
            if !trimmed.is_empty() {
                out.push(PathBuf::from(trimmed));
            }
        }
        Ok(out)
    }

    /// Adds `dir` to the manifest. Idempotent: a no-op if `dir` is already
    /// present (after normalization).
    ///
    /// Relative paths are joined with the current working directory; no
    /// symlink resolution is performed. Creates the parent directory and the
    /// manifest file on first call.
    ///
    /// # Errors
    /// Returns the underlying I/O error if normalization, reading, parent
    /// creation, or the atomic write fails.
    pub fn add(&self, dir: impl AsRef<Path>) -> io::Result<()> {
        let dir = absolutize(dir.as_ref())?;
        let mut entries = self.list()?;
        if entries.contains(&dir) {
            return Ok(());
        }
        entries.push(dir);
        self.write_atomic(&entries)
    }

    /// Removes `dir` from the manifest if present (after normalization).
    /// No-op if `dir` is not in the manifest or the file does not exist.
    ///
    /// # Errors
    /// Returns the underlying I/O error if normalization, reading, or the
    /// atomic write fails.
    pub fn remove(&self, dir: impl AsRef<Path>) -> io::Result<()> {
        let dir = absolutize(dir.as_ref())?;
        let entries = self.list()?;
        if !entries.contains(&dir) {
            return Ok(());
        }
        let filtered: Vec<PathBuf> = entries.into_iter().filter(|e| e != &dir).collect();
        self.write_atomic(&filtered)
    }

    fn write_atomic(&self, entries: &[PathBuf]) -> io::Result<()> {
        let parent = self.path.parent().ok_or_else(|| {
            io::Error::new(io::ErrorKind::InvalidInput, "manifest path has no parent")
        })?;
        fs::create_dir_all(parent)?;
        let mut tmp = NamedTempFile::new_in(parent)?;
        for entry in entries {
            // Path::display is lossy on non-UTF8; acceptable for v0.
            writeln!(tmp, "{}", entry.display())?;
        }
        tmp.persist(&self.path).map_err(|e| e.error)?;
        Ok(())
    }
}

fn absolutize(p: &Path) -> io::Result<PathBuf> {
    Ok(absolutize_in(p, &env::current_dir()?))
}

fn absolutize_in(p: &Path, cwd: &Path) -> PathBuf {
    if p.is_absolute() {
        p.to_path_buf()
    } else {
        cwd.join(p)
    }
}

#[cfg(test)]
mod tests {
    use super::{absolutize_in, Manifest};
    use std::path::{Path, PathBuf};
    use tempfile::tempdir;

    #[test]
    fn roundtrip_add_list_remove() {
        let tmp = tempdir().unwrap();
        let m = Manifest::at(tmp.path().join("manifest"));
        m.add("/a").unwrap();
        m.add("/b").unwrap();
        assert_eq!(
            m.list().unwrap(),
            vec![PathBuf::from("/a"), PathBuf::from("/b")]
        );
        m.remove("/a").unwrap();
        assert_eq!(m.list().unwrap(), vec![PathBuf::from("/b")]);
    }

    #[test]
    fn add_is_idempotent() {
        let tmp = tempdir().unwrap();
        let m = Manifest::at(tmp.path().join("manifest"));
        m.add("/a").unwrap();
        m.add("/a").unwrap();
        assert_eq!(m.list().unwrap(), vec![PathBuf::from("/a")]);
    }

    #[test]
    fn list_on_missing_file_returns_empty() {
        let tmp = tempdir().unwrap();
        let m = Manifest::at(tmp.path().join("does-not-exist"));
        assert!(m.list().unwrap().is_empty());
    }

    #[test]
    fn add_creates_parent_dir() {
        let tmp = tempdir().unwrap();
        let nested = tmp.path().join("a/b/c/manifest");
        let m = Manifest::at(&nested);
        m.add("/x").unwrap();
        assert!(nested.exists());
    }

    #[test]
    fn remove_missing_is_noop() {
        let tmp = tempdir().unwrap();
        let m = Manifest::at(tmp.path().join("manifest"));
        m.add("/a").unwrap();
        m.remove("/never-added").unwrap();
        assert_eq!(m.list().unwrap(), vec![PathBuf::from("/a")]);
    }

    #[test]
    fn absolutize_in_makes_relative_absolute() {
        let cwd = Path::new("/tmp/work");
        assert_eq!(
            absolutize_in(Path::new("foo"), cwd),
            PathBuf::from("/tmp/work/foo")
        );
        assert_eq!(absolutize_in(Path::new("/abs"), cwd), PathBuf::from("/abs"));
    }
}
