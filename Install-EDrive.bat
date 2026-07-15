@echo off
setlocal
cd /d "%~dp0"

echo Installing E-drive isolated environment for Vibe-Trading...
where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\Install-EDriveIsolated.ps1" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\Install-EDriveIsolated.ps1" %*
)

echo.
echo Done. You can now run Start-VibeTrading.bat
pause
endlocal
