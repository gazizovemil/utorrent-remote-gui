# Changelog

All notable changes to **uTorrent Remote GUI** are documented in this file.

Version format until `1.0.0`: **`0.<build>.0`** (iterative pre-release builds).  
Canonical version: [`src/appversion.pas`](src/appversion.pas) (`AppVerStr`).

---

## [0.24.0] — 2026-08-06

### Added
- **Tray tooltip:** multi-line hint on hover (connection, download/seed counts, speeds) like TransGUI.
- **Run at Windows startup** option in application settings (registry autoload).
- **Torrent error notifications** via tray balloon when a torrent enters error state.

---

## [0.23.0] — 2026-08-06

### Fixed
- **System tray:** restoring the window keeps the previous size (including maximized) instead of opening a small window.
- **Startup:** window position, size, and maximized state are saved to `utorrentgui.ini` (`[Window]`) on exit and restored on launch.

---

## [0.22.0] — 2026-08-05

### Added
- **Menu icons** (16×16) for main menu, torrent context menu, tray menu, and profile menu.
- **`ImageListMenu`** and actions `actAppSettings` / `actUtSettings` wired to menu items.
- Shared helpers **`FitDialogButton`** / **`LayoutRightButtons`** in `utils.pas` for dialog button sizing.

### Changed
- **Application settings** window enlarged to **760×620** (min **680×500**).
- **uTorrent settings** window enlarged to **1024×720** (min **800×580**).
- Dialog buttons (**Apply**, **Close**, **Refresh**, **OK**, **Cancel**) auto-size to caption text (fixes clipped Russian labels).

---

## [0.21.0] — 2026-08-05

### Added
- **`UtSettingLabels`** unit and label files **`lang/utsettings_en.lng`**, **`lang/utsettings_ru.lng`** (~200 uTorrent WebUI setting names).
- Human-readable setting captions in **uTorrent settings** (fallback: auto-formatted key name).

### Fixed
- **Application settings** layout: labels and controls side-by-side, dynamic group box height, resize handling.
- Checkbox / spin row spacing in app settings (no overlapping rows).

---

## [0.20.0] — 2026-08-05

### Added
- **TransGUI-style profile selector** on toolbar: dropdown button with profile list, checkmark on active profile, *New connection…*, *Manage connections…*; click reconnects active profile.
- **uTorrent settings** dialog: category tree (General, Interface, Folders, Connection, Bandwidth, BitTorrent, Scheduler, Advanced, …).
- **Application settings** dialog: tabs General / Advanced / Proxy / Paths.
- **Esc** closes settings dialogs with save prompt when data changed.

### Fixed
- **False “Save changes?”** in uTorrent settings when nothing was edited (value storage indexed by setting name).
- uTorrent settings row layout and bottom **Apply** / **Close** button overlap.
- **PE icon missing in Explorer** after `strip`: build order now strips *before* `embed-manifest.ps1`.

### Changed
- **Connections** moved from *Torrent* menu to **Tools**.
- **View** menu extended: select all, configure columns, toggle filter/details/toolbar/status bar, large/small toolbar.

---

## [0.15.0] and earlier

### Core features (baseline)
- Multiple connection profiles, autoconnect, WebUI auth (Basic + CSRF token + GUID cookie).
- Torrent list, filters, start/pause/stop/recheck, queue, add file/URL, details panels.
- Toolbar, tray, download-complete balloon, 18 UI languages.
- Build pipeline: `build.cmd` → `dist\` package with `lang\` and `images\`.
