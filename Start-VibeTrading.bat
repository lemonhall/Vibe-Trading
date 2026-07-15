@echo off
setlocal
cd /d "%~dp0"

REM 一键启动 Web UI（默认 http://localhost:8899）
REM 需要已安装: uv + PowerShell 5.1/7 + 本仓库 E 盘隔离环境

where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\Start-WebUI.ps1" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\windows\Start-WebUI.ps1" %*
)

endlocal
