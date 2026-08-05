@echo off
cd /d "%~dp0"
set "ROOT=%~dp0"
set "DIST=%ROOT%dist"
set "STRIP=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\strip.exe"

echo Building uTorrent Remote GUI...
"C:\lazarus\lazbuild.exe" --build-mode=Default "%ROOT%utorrentgui.lpi"
if errorlevel 1 exit /b 1

REM Strip BEFORE embedding resources — strip --strip-all removes PE icons.
if exist "%STRIP%" (
  echo Stripping debug symbols...
  "%STRIP%" --strip-all "%ROOT%utorrentgui.exe" 2>nul
)

echo Embedding manifest + icon...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%embed-manifest.ps1"
if errorlevel 1 exit /b 1

echo Packaging release into dist\ ...
if not exist "%DIST%" mkdir "%DIST%"
if not exist "%DIST%\lang" mkdir "%DIST%\lang"
if not exist "%DIST%\images" mkdir "%DIST%\images"

copy /Y "%ROOT%utorrentgui.exe" "%DIST%\utorrentgui.exe" >nul
copy /Y "%ROOT%README.md" "%DIST%\README.md" >nul
copy /Y "%ROOT%CHANGELOG.md" "%DIST%\CHANGELOG.md" >nul
xcopy /E /I /Y "%ROOT%lang\*" "%DIST%\lang\" >nul
xcopy /E /I /Y "%ROOT%images\*" "%DIST%\images\" >nul

for %%A in ("%DIST%\utorrentgui.exe") do echo EXE size: %%~zA bytes
echo.
echo Build OK. Release folder: %DIST%
echo Run: %DIST%\utorrentgui.exe
