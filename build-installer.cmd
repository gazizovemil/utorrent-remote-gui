@echo off
setlocal
cd /d "%~dp0"
set "ROOT=%~dp0"
set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
  echo Inno Setup not found: %ISCC%
  exit /b 1
)
subst T: /d >nul 2>&1
subst T: "%ROOT%"
if errorlevel 1 (
  echo subst T: failed — drive letter may be in use
  exit /b 1
)
"%ISCC%" "T:\utorrentgui.iss"
set "IERR=%ERRORLEVEL%"
subst T: /d >nul 2>&1
exit /b %IERR%
