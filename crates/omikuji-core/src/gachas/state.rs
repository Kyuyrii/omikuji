
use std::path::{Path, PathBuf};

pub fn game_state_dir(publisher_slug: &str, game_slug: &str) -> PathBuf {
    crate::gachas_dir().join(publisher_slug).join(game_slug)
}

pub fn version_file(publisher_slug: &str, game_slug: &str, edition_id: &str) -> PathBuf {
    game_state_dir(publisher_slug, game_slug).join(format!("{}.version", edition_id))
}

pub fn read_installed_version(
    publisher_slug: &str,
    game_slug: &str,
    edition_id: &str,
) -> Option<String> {
    let path = version_file(publisher_slug, game_slug, edition_id);
    std::fs::read_to_string(&path)
        .ok()
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
}

// errors are logged not returned; caller cant do anything useful with a write failure here
pub fn write_installed_version(
    publisher_slug: &str,
    game_slug: &str,
    edition_id: &str,
    version: &str,
) {
    let path = version_file(publisher_slug, game_slug, edition_id);
    if let Some(parent) = path.parent()
        && let Err(e) = std::fs::create_dir_all(parent) {
            eprintln!(
                "[gachas::state] create_dir_all({}) failed: {}",
                parent.display(),
                e
            );
            return;
        }
    if let Err(e) = std::fs::write(&path, version) {
        eprintln!(
            "[gachas::state] write({}) failed: {}",
            path.display(),
            e
        );
    }
}

pub fn state_path_for(publisher_slug: &str, game_slug: &str) -> impl AsRef<Path> {
    game_state_dir(publisher_slug, game_slug)
}
