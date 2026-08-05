@echo off
setlocal
cd /d "%~dp0"
set "ROOT=%~dp0"
set "DIST=%ROOT%dist"
set "REL=%ROOT%release"
set "ISCC=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
set "SEVENZ=C:\Program Files\7-Zip\7z.exe"

for /f "delims=" %%V in ('type "%ROOT%VERSION"') do set "VER=%%V"
set "VER=%VER: =%"

echo === Build application ===
call "%ROOT%build.cmd"
if errorlevel 1 exit /b 1

if not exist "%REL%" mkdir "%REL%"

set "ZIP=%REL%\utorrentgui-%VER%-win64.zip"
set "ARCH7=%REL%\utorrentgui-%VER%-win64.7z"

echo === Create ZIP: %ZIP% ===
powershell -NoProfile -Command "if (Test-Path '%ZIP%') { Remove-Item '%ZIP%' -Force }; Compress-Archive -Path '%DIST%\*' -DestinationPath '%ZIP%' -Force"
if errorlevel 1 (
  echo ZIP failed
  exit /b 1
)

echo === Create 7z: %ARCH7% ===
if not exist "%SEVENZ%" (
  echo 7-Zip not found: %SEVENZ%
  exit /b 1
)
if exist "%ARCH7%" del /f /q "%ARCH7%"
pushd "%DIST%"
"%SEVENZ%" a -t7z -mx=9 "%ARCH7%" *
set "ZERR=%ERRORLEVEL%"
popd
if not "%ZERR%"=="0" exit /b 1

echo === Build installer (Inno Setup) ===
if not exist "%ISCC%" (
  echo Inno Setup not found: %ISCC%
  exit /b 1
)
REM Inno Setup: '#' in project path breaks the preprocessor — use drive alias.
subst T: /d >nul 2>&1
subst T: "%ROOT%"
if errorlevel 1 (
  echo subst T: failed — drive letter may be in use
  exit /b 1
)
"%ISCC%" "T:\utorrentgui.iss"
set "IERR=%ERRORLEVEL%"
subst T: /d >nul 2>&1
if not "%IERR%"=="0" exit /b 1

echo.
echo Release artifacts in %REL%:
dir /b "%REL%"
echo.
echo Done.
