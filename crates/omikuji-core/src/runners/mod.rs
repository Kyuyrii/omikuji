use crate::archive_source;
use crate::settings::ArchiveSource;
use anyhow::Result;
use std::path::PathBuf;
use std::process::Command;

pub fn runners_dir() -> PathBuf {
    crate::runners_dir()
}

pub fn list_sources() -> Vec<ArchiveSource> {
    crate::settings::get().runners.clone()
}

pub fn source_by_name(name: &str) -> Option<ArchiveSource> {
    list_sources().into_iter().find(|s| s.name == name)
}

pub async fn fetch_versions(source: &ArchiveSource) -> Result<Vec<archive_source::ReleaseInfo>> {
    archive_source::fetch_versions(source).await
}

pub async fn install_version(
    source: &ArchiveSource,
    release: &archive_source::ReleaseInfo,
) -> Result<PathBuf> {
    archive_source::install_version("runners", source, release, &runners_dir()).await
}

pub fn list_installed(source: &ArchiveSource) -> Vec<String> {
    archive_source::list_installed(source, &runners_dir())
}

pub fn delete_version(source: &ArchiveSource, tag: &str) -> Result<()> {
    archive_source::delete_version(source, &runners_dir(), tag)
}

pub fn list_installed_runners() -> Vec<String> {
    let mut runners = vec![];
    
    if let Ok(entries) = std::fs::read_dir(runners_dir()) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                let name = path.file_name()
                    .and_then(|n| n.to_str())
                    .unwrap_or("");
                
                let has_wine = path.join("bin/wine").exists();
                let has_proton = path.join("files/bin/wine64").exists()
                    || path.join("proton").exists();
                
                if has_wine || has_proton {
                    runners.push(name.to_string());
                }
            }
        }
    }
    
    if let Some(steam_dir) = crate::steam::local::find_steam_dir()
        && let Ok(entries) = std::fs::read_dir(steam_dir.join("compatibilitytools.d"))
    {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() && path.join("files").exists()
                && let Some(name) = path.file_name().and_then(|n| n.to_str())
            {
                runners.push(format!("steam:{name}"));
            }
        }
    }

    for steamapps in crate::steam::local::get_steamapps_dirs() {
        let common = steamapps.join("common");
        let Ok(entries) = std::fs::read_dir(&common) else { continue };
        for entry in entries.flatten() {
            let path = entry.path();
            let Some(name) = path.file_name().and_then(|n| n.to_str()) else { continue };
            if name.starts_with("Proton ") && path.join("files").exists() {
                runners.push(format!("steam:{name}"));
            }
        }
    }
    
    if which::which("wine").is_ok() {
        runners.push("system".to_string());
    }
    
    runners.sort();
    runners.dedup();
    runners
}

pub fn list_gpus() -> Vec<(String, String)> {
    let mut gpus = vec![("Default".to_string(), "".to_string())];
    
    if let Ok(output) = Command::new("lspci").output() {
        let stdout = String::from_utf8_lossy(&output.stdout);
        for line in stdout.lines() {
            if line.contains("VGA") || line.contains("3D controller") || line.contains("Display controller") {
                let parts: Vec<&str> = line.splitn(2, ':').collect();
                if parts.len() >= 2 {
                    let pci_slot = parts[0].trim();
                    let desc = parts[1].trim();
                    if let Some(idx) = desc.find(':') {
                        let name = desc[idx+1..].trim();
                        let clean_name = name
                            .replace("Advanced Micro Devices, Inc.", "AMD")
                            .replace("NVIDIA Corporation", "NVIDIA")
                            .replace("Intel Corporation", "Intel")
                            .replace("Corp.", "");
                        gpus.push((clean_name.to_string(), pci_slot.to_string()));
                    }
                }
            }
        }
    }
    
    if gpus.len() == 1
        && let Ok(entries) = std::fs::read_dir("/sys/class/drm") {
            for entry in entries.flatten() {
                let name = entry.file_name();
                let name_str = name.to_string_lossy();
                
                if name_str.starts_with("card") && !name_str.contains('-') {
                    let device_path = entry.path().join("device");
                    
                    if let Ok(vendor) = std::fs::read_to_string(device_path.join("vendor")) {
                        let vendor = vendor.trim();
                        let label = match vendor {
                            "0x1002" => "AMD GPU",
                            "0x10de" => "NVIDIA GPU",
                            "0x8086" => "Intel GPU",
                            _ => "GPU",
                        };
                        gpus.push((format!("{} ({})", label, name_str), name_str.to_string()));
                    } else {
                        gpus.push((format!("GPU {}", name_str), name_str.to_string()));
                    }
                }
            }
        }
    
    if gpus.len() > 2 {
        gpus.push(("PRIME Render Offload".to_string(), "DRI_PRIME=1".to_string()));
    }
    
    gpus
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_runners_dir() {
        let dir = runners_dir();
        assert!(dir.to_string_lossy().contains("omikuji"));
    }
    
    #[test]
    fn test_list_gpus() {
        let gpus = list_gpus();
        assert!(!gpus.is_empty());
        assert_eq!(gpus[0].0, "Default");
    }
}
