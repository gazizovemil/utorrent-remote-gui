@echo off
setlocal
where lazbuild >nul 2>&1
if errorlevel 1 (
  echo Lazarus lazbuild not found in PATH.
  echo Install Lazarus and reopen this prompt, or open utorrentgui.lpi in the IDE.
  exit /b 1
)
lazbuild --build-mode=Default "%~dp0utorrentgui.lpi"
exit /b %ERRORLEVEL%
