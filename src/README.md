# Source code

Pascal/Lazarus application sources.

| File | Purpose |
|------|---------|
| `appversion.pas` | Version constants (`AppVerStr`) |
| `main.pas` / `main.lfm` | Main window, menus, toolbar |
| `connform.pas` / `connform.lfm` | Connection profiles dialog |
| `aboutform.pas` / `aboutform.lfm` | About dialog |
| `appsettingsform.pas` | Application settings (tabs) |
| `utsettingsform.pas` | Remote uTorrent settings (category tree) |
| `utsettinglabels.pas` | Loads `lang/utsettings_*.lng` captions |
| `rpc.pas` | WebUI client + refresh thread |
| `models.pas` | Torrent data models |
| `profiles.pas` | Connection profiles + app options (INI) |
| `lang.pas` | UI string loader (`lang/*.lng`) |
| `utils.pas` | Formatting, URLs, dialog button layout |
| `torrentmeta.pas` | Read comment from `.torrent` |
| `logger.pas` | File log |

**Lazarus project:** `..\utorrentgui.lpi`  
**Build:** `..\build.cmd` → output in `..\dist\`  
**Version:** `appversion.pas` / `..\VERSION`

Russian notes: [../README.ru.md](../README.ru.md)
