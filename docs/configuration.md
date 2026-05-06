# Configuration

Omikuji's main config lives at `~/.local/share/omikuji/settings.toml`. It's auto-generated on first run with sensible defaults. Edit it freely, restart the launcher to apply (file watcher's only wired for `ui.toml` so far).

The file's split into a few sections, most of which you'll never touch. The interesting ones are `[[runners]]` and `[[dll_packs]]`, since those let you add your own wine/proton/DXVK sources without touching code.

## `[paths]`

Where omikuji stores its stuff. Defaults are XDG-compliant. Don't change these unless you know why.

```toml
[paths]
data_dir = "~/.local/share/omikuji"
library_dir = "~/.local/share/omikuji/library"
gachas_dir = "~/.local/share/omikuji/gachas"
runners_dir = "~/.local/share/omikuji/runners"
dll_packs_dir = "~/.local/share/omikuji/components"
prefixes_dir = "~/.local/share/omikuji/prefixes"
cache_dir = "~/.local/share/omikuji/cache"
logs_dir = "~/.local/share/omikuji/logs"
runtime_dir = "~/.local/share/omikuji/runtime"
```

`~` expands to `$HOME` on read.

## `[assets]`

Where the gacha manifests + posters live. Defaults to a sibling repo of mine.

```toml
[assets]
fetch_url = "https://raw.githubusercontent.com/reakjra/omikuji-assets/main"
```

If you fork the assets repo (e.g. to add a new gacha), point this at your fork.

## `[components]`

Auto-fetched runtime tools. URLs are GitHub release-latest API endpoints (or codeberg for jadeite, raw URL for the EGL dummy). Each tool is fetched on first run if missing.

```toml
[components]
umu_run = "https://api.github.com/repos/Open-Wine-Components/umu-launcher/releases/latest"
hpatchz = "https://api.github.com/repos/sisong/HDiffPatch/releases/latest"
legendary = "https://api.github.com/repos/derrod/legendary/releases/latest"
gogdl = "https://api.github.com/repos/Heroic-Games-Launcher/heroic-gogdl/releases/latest"
jadeite = "https://codeberg.org/api/v1/repos/mkrsym1/jadeite/releases/latest"
egl_dummy = "https://raw.githubusercontent.com/reakjra/omikuji-assets/main/runtime/epic/EpicGamesLauncher.exe"
```

Generally don't touch unless an upstream tool moves repos.

## `[steam]`

```toml
[steam]
api_key = ""
```

Your personal Steam Web API key (get one at [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey)). Optional. Without it, Steam library listing still works (read locally from ACF files), but remote playtime sync is disabled. If you launch Steam games via omikuji, our process manager tracks playtime regardless.

## `[[runners]]`

The interesting bit. This is the list of sources omikuji's runner manager pulls from. Each entry is a github (or compatible) releases API URL and a pattern to match the right asset. Add your own here if you want.

Default entries:

```toml
[[runners]]
name = "Proton-Spritz"
kind = "proton"
api_url = "https://api.github.com/repos/NelloKudo/proton-cachyos/releases"
asset_pattern = "-x86_64.tar.xz"
extract = "tar_xz"

[[runners]]
name = "Proton-GE"
kind = "proton"
api_url = "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases"
asset_pattern = ".tar.gz"
extract = "tar_gz"

[[runners]]
name = "Dawn Winery Proton"
kind = "proton"
api_url = "https://api.github.com/repos/dawn-winery/dwproton-mirror/releases"
asset_pattern = ".tar.xz"
extract = "tar_xz"

[[runners]]
name = "Proton-Cachyos"
kind = "proton"
api_url = "https://api.github.com/repos/CachyOS/proton-cachyos/releases"
asset_pattern = ".tar.xz"
extract = "tar_xz"
```

Field reference:

| field | what it is |
|-------|------------|
| `name` | display name in the runner manager UI. arbitrary string. |
| `kind` | `"wine"` or `"proton"`. drives variant detection at launch time. |
| `api_url` | github releases API. `https://api.github.com/repos/{owner}/{repo}/releases`. github mirrors of gitea/codeberg work too as long as they expose the same JSON shape. |
| `asset_pattern` | substring matched against each release asset's filename. picks the first match. has to be specific enough to dodge `.sha256sum` files and the like. |
| `extract` | `tar_gz` / `tar_xz` / `tar_zst` / `zip`. determines how the archive is unpacked. |

### adding a new runner

Say you want to add `wine-tkg-git` from Frogging-Family:

```toml
[[runners]]
name = "Wine-TkG"
kind = "wine"
api_url = "https://api.github.com/repos/Frogging-Family/wine-tkg-git/releases"
asset_pattern = "-x86_64.tar.zst"
extract = "tar_zst"
```

Restart omikuji, head to Settings => Components, your new entry shows up with a list of available versions to install.

If `asset_pattern` doesn't match anything, the manager will silently skip the source.

## `[[dll_packs]]`

Same shape as runners, but for DXVK / VKD3D-Proton / DXVK-NVAPI builds. Installed under `components/{source.name}/{tag}/` so packs with colliding tags don't clobber each other.

```toml
[[dll_packs]]
name = "DXVK"
kind = "dxvk"
api_url = "https://api.github.com/repos/doitsujin/dxvk/releases"
asset_pattern = ".tar.gz"
extract = "tar_gz"

[[dll_packs]]
name = "VKD3D-Proton"
kind = "vkd3d"
api_url = "https://api.github.com/repos/HansKristian-Work/vkd3d-proton/releases"
asset_pattern = ".tar.zst"
extract = "tar_zst"

[[dll_packs]]
name = "DXVK-NVAPI"
kind = "dxvk_nvapi"
api_url = "https://api.github.com/repos/jp7677/dxvk-nvapi/releases"
asset_pattern = ".tar.gz"
extract = "tar_gz"
```

`kind` here is one of `"dxvk"`, `"vkd3d"`, `"dxvk_nvapi"` (or any string really, used for grouping in the UI).

The auto-inject picker per-pack lives in `components_state.toml` (next to `settings.toml`):

```toml
[dll_packs]
DXVK = "v2.4"
VKD3D-Proton = "v2.13"
DXVK-NVAPI = ""  # empty = disabled
```

Empty string disables that pack's auto-injection. The UI manages this for you, no need to hand-edit unless something's wrong.

## things deliberately not exposed here

The per-game game.toml has its own schema, lives in `~/.local/share/omikuji/library/{slug}_{id}.toml`. Editable too, file-watched by the running launcher. That's a separate doc.

The `defaults.toml` (global per-game seed values) is also separate, has its own UI in Settings => Global Defaults.

`ui.toml` covers categories, nav, display options, etc. All UI-driven, hand-editing is supported but not the main path.
