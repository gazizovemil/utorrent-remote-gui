@echo off
cd /d "%~dp0"
set "ROOT=%~dp0"
set "DIST=%ROOT%dist"
set "STRIP=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\strip.exe"
set "FPCRES=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpcres.exe"
set "WINDRES=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\windres.exe"
set "CPP=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\cpp.exe"

echo Generating version resource...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%generate-appversion-rc.ps1"
if errorlevel 1 exit /b 1
if not exist "%ROOT%lib\x86_64-win64" mkdir "%ROOT%lib\x86_64-win64"
subst V: /d >nul 2>&1
subst V: "%ROOT%"
if errorlevel 1 (
  echo subst V: failed
  exit /b 1
)
"%WINDRES%" --preprocessor "%CPP%" "V:\appversion.rc" -O res -o "V:\lib\x86_64-win64\winver.res"
set "WERR=%ERRORLEVEL%"
if not "%WERR%"=="0" (
  subst V: /d >nul 2>&1
  exit /b 1
)
"%FPCRES%" -o "V:\lib\x86_64-win64\winver.o" "V:\lib\x86_64-win64\winver.res"
set "WERR=%ERRORLEVEL%"
subst V: /d >nul 2>&1
if not "%WERR%"=="0" exit /b 1

echo Building uTorrent Remote GUI...
"C:\lazarus\lazbuild.exe" --build-mode=Default "%ROOT%utorrentgui.lpi"
if errorlevel 1 exit /b 1

REM Strip debug only — keep PE version info; icon/manifest re-embedded below.
if exist "%STRIP%" (
  echo Stripping debug symbols...
  "%STRIP%" --strip-debug "%ROOT%utorrentgui.exe" 2>nul
)

echo Embedding manifest + icon + version check...
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
