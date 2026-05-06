
use anyhow::Result;

use crate::gachas::manifest::GachaManifest;

#[derive(Debug, Clone)]
pub struct UpdateInfo {
    pub game_slug: String,
    pub edition: String,
    pub from_version: String,
    pub to_version: String,
    pub download_size: u64,
    // always false until dpatchz is ported
    pub can_diff: bool,
}

pub async fn check_for_update(manifest: &GachaManifest, edition_id: &str) -> Result<Option<UpdateInfo>> {
    let Some(from_version) = super::installed_version(&manifest.game_slug, edition_id) else {
        return Ok(None);
    };
    let info = super::api::fetch_resource_info(manifest, edition_id).await?;
    if info.version == from_version || info.version.is_empty() {
        return Ok(None);
    }
    Ok(Some(UpdateInfo {
        game_slug: manifest.game_slug.clone(),
        edition: edition_id.to_string(),
        from_version,
        to_version: info.version,
        download_size: 0,
        can_diff: false,
    }))
}

pub async fn check_by_app_id(app_id: &str) -> Option<UpdateInfo> {
    let (manifest, edition_id, _) = crate::gachas::strategies::find_for_app_id(app_id)?;
    match check_for_update(&manifest, &edition_id).await {
        Ok(info) => info,
        Err(e) => {
            eprintln!("[kuro] update check for {} failed: {}", app_id, e);
            None
        }
    }
}
