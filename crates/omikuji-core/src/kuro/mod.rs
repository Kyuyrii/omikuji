// kuro cdn: fetch index.json per game+edition, get a per-file resource list,
// download directly with no archive phase. krdiff patches not wired yet
// per-game/edition index_url moved into manifest.editions[].strategy_config (asset repo) on 2026-04-26.

pub mod api;
pub mod source;
pub mod update;

use anyhow::{anyhow, Result};
use crate::gachas::manifest::GachaManifest;

pub fn index_url_from_manifest(manifest: &GachaManifest, edition_id: &str) -> Result<String> {
    manifest
        .editions
        .iter()
        .find(|e| e.id == edition_id)
        .and_then(|e| e.strategy_config.get("index_url"))
        .and_then(|v| v.as_str())
        .map(|s| s.to_string())
        .ok_or_else(|| anyhow!("no strategy_config.index_url in manifest {} for edition {}", manifest.id, edition_id))
}

pub fn parse_app_id(app_id: &str) -> Result<(String, String)> {
    let mut parts = app_id.splitn(2, ':');
    let game = parts
        .next()
        .filter(|s| !s.is_empty())
        .ok_or_else(|| anyhow::anyhow!("invalid kuro app_id: {}", app_id))?
        .to_string();
    let edition = parts
        .next()
        .filter(|s| !s.is_empty())
        .ok_or_else(|| anyhow::anyhow!("invalid kuro app_id: {}", app_id))?
        .to_string();
    Ok((game, edition))
}

const PUBLISHER_SLUG: &str = "kurogame";

pub fn installed_version(game_slug: &str, edition: &str) -> Option<String> {
    crate::gachas::state::read_installed_version(PUBLISHER_SLUG, game_slug, edition)
}

pub fn set_installed_version(game_slug: &str, edition: &str, version: &str) {
    crate::gachas::state::write_installed_version(PUBLISHER_SLUG, game_slug, edition, version);
}


// no-op today: kuro writes directly into install_dir so theres no scratch to clean , kept for shape-consistency with hoyo/endfield
pub fn cleanup_kuro_state(_app_id: &str, _install_path: &std::path::Path, _temp_dir: Option<&std::path::Path>) {}
