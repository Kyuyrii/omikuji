use std::io::{Error, ErrorKind, Result};
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn binary_path() -> Result<PathBuf> {
    let p = crate::runtime_dir().join("hpatchz");
    if !p.exists() {
        return Err(Error::new(
            ErrorKind::NotFound,
            format!(
                "hpatchz not found at {}. drop the binary there (chmod +x) — first-run fetcher comes later",
                p.display()
            ),
        ));
    }
    Ok(p)
}

// aag-core checks stdout for "patch ok!", same approach here
pub fn patch(file: &Path, patch: &Path, output: &Path) -> Result<()> {
    let bin = binary_path()?;

    if let Ok(meta) = std::fs::metadata(&bin) {
        let mode = meta.permissions().mode();
        if mode & 0o111 == 0 {
            let mut perms = meta.permissions();
            perms.set_mode(mode | 0o755);
            let _ = std::fs::set_permissions(&bin, perms);
        }
    }

    let out = Command::new(&bin)
        .arg("-f")
        .arg(file)
        .arg(patch)
        .arg(output)
        .output()?;

    if String::from_utf8_lossy(&out.stdout).contains("patch ok!") {
        Ok(())
    } else {
        let err = String::from_utf8_lossy(&out.stderr);
        Err(Error::other(
            format!("hpatchz failed: {}", err.trim()),
        ))
    }
}
