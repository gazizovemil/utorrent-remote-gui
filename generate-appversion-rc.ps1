# Generate appversion.rc from VERSION for windres (PE version info).
param(
  [string]$Root = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
$VersionFile = Join-Path $Root 'VERSION'
if (-not (Test-Path $VersionFile)) { Write-Error "Missing $VersionFile"; exit 1 }
$Ver = (Get-Content $VersionFile -Raw).Trim()
$Parts = $Ver.Split('.')
$Major = [int]$Parts[0]
$Minor = if ($Parts.Length -gt 1) { [int]$Parts[1] } else { 0 }
$Patch = if ($Parts.Length -gt 2) { [int]$Parts[2] } else { 0 }
$Build = 0
$RcPath = Join-Path $Root 'appversion.rc'
$Rc = @"
1 VERSIONINFO
FILEVERSION $Major,$Minor,$Patch,$Build
PRODUCTVERSION $Major,$Minor,$Patch,$Build
FILEFLAGSMASK 0x3fL
FILEFLAGS 0x0L
FILEOS 0x00000004L
FILETYPE 0x00000001L
FILESUBTYPE 0x00000000L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "041904E4"
        BEGIN
            VALUE "CompanyName", "gazizovemil"
            VALUE "FileDescription", "uTorrent Remote GUI"
            VALUE "FileVersion", "$Ver"
            VALUE "InternalName", "utorrentgui"
            VALUE "LegalCopyright", "Copyright (c) 2026 gazizovemil"
            VALUE "OriginalFilename", "utorrentgui.exe"
            VALUE "ProductName", "uTorrent Remote GUI"
            VALUE "ProductVersion", "$Ver"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0419, 1252
    END
END
"@
Set-Content -Path $RcPath -Value $Rc -Encoding ASCII
Write-Host "Generated $RcPath for version $Ver"
