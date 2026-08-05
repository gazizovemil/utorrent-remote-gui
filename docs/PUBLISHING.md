# Publishing to GitHub

This project keeps **source code in git** and publishes **binaries only in GitHub Releases** (not in the repository).

---

## What goes into git

**Include:**
- `src\`, `lang\`, `images\`, `docs\`
- `utorrentgui.lpi`, `utorrentgui.lpr`, `utorrentgui.iss`
- `build.cmd`, `build-release.cmd`, `embed-manifest.ps1`
- `README.md`, `README.ru.md`, `CHANGELOG.md`, `LICENSE`, `VERSION`

**Exclude** (already in `.gitignore`):
- `lib\`, `backup\`, `*.exe`, `*.log`, `utorrentgui.ini`
- `release\`, `*.zip`, `*.7z`, `*-setup.exe`

The `dist\` folder is a local build output; do not commit it unless you intentionally want portable builds in the repo (not recommended).

---

## One-time setup

```bat
cd D:\Distr\#projects\transgui
git init
git remote add origin https://github.com/gazizovemil/utorrent-remote-gui.git
git branch -M main
```

Install [GitHub CLI](https://cli.github.com/) (`gh`) and authenticate:

```bat
gh auth login
```

---

## Push source code

```bat
git add .
git status
git commit -m "Release v0.22.0: settings UI, menu icons, installer"
git push -u origin main
```

Use a meaningful commit message; keep `CHANGELOG.md` updated before each release.

---

## Build release artifacts

```bat
build-release.cmd
```

Output in **`release\`**:

| File | Purpose |
|------|---------|
| `utorrentgui-0.22.0-win64.zip` | Portable build (zip) |
| `utorrentgui-0.22.0-win64.7z` | Portable build (7-Zip) |
| `utorrentgui-0.22.0-setup.exe` | Windows installer |

Version comes from [`VERSION`](VERSION).

---

## Create a GitHub Release

### Option A — GitHub CLI (recommended)

```bat
gh release create v0.22.0 ^
  --title "v0.22.0" ^
  --notes-file CHANGELOG.md ^
  release\utorrentgui-0.22.0-win64.zip ^
  release\utorrentgui-0.22.0-win64.7z ^
  release\utorrentgui-0.22.0-setup.exe
```

Replace `v0.22.0` and filenames when the version changes.

### Option B — Web UI

1. Open **Releases → Draft a new release**
2. Tag: `v0.22.0` (create from `main`)
3. Title: `v0.22.0`
4. Description: paste the `[0.22.0]` section from `CHANGELOG.md`
5. Attach all three files from `release\`
6. Publish release

---

## Recommended workflow per version

1. Update `src/appversion.pas`, `VERSION`, `utorrentgui.lpi` title, `utorrentgui.iss` `#define MyAppVersion`
2. Update `CHANGELOG.md`
3. `build-release.cmd`
4. Test `release\utorrentgui-0.22.0-setup.exe` and portable zip
5. Commit and push source
6. `gh release create …` with artifacts

---

## Notes

- **Do not** commit `release\` archives to git — upload them only to GitHub Releases.
- Project path contains `#`; `build-release.cmd` uses `subst T:` for Inno Setup.
- Screenshots for README live in `docs/screenshots/` and are part of the source repo.
