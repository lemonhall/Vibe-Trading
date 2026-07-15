#Requires -Version 5.1
<#
.SYNOPSIS
  进入 Vibe-Trading 的 E 盘隔离 Python 环境（当前 PowerShell 会话）。

.DESCRIPTION
  优先使用本机 skill: isolating-python-projects-on-e-drive。
  若 skill 不存在，则回退为项目内最小隔离环境变量 + 激活 .venv。

.EXAMPLE
  . .\scripts\windows\Enter-IsolatedEnv.ps1
  vibe-trading --version
#>
[CmdletBinding()]
param(
    [string]$Proxy = 'http://127.0.0.1:7897'
)

$ErrorActionPreference = 'Stop'

# 本脚本位于 <repo>\scripts\windows\
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if ([System.IO.Path]::GetPathRoot($RepoRoot) -ne 'E:\') {
    throw "为遵循 E 盘隔离约定，仓库路径必须在 E: 下。当前: $RepoRoot"
}

$skillEnter = Join-Path $env:USERPROFILE '.agents\skills\isolating-python-projects-on-e-drive\scripts\Enter-EDrivePythonProject.ps1'
if (Test-Path -LiteralPath $skillEnter) {
    . $skillEnter -ProjectPath $RepoRoot -Proxy $Proxy | Out-Null
}
else {
    Write-Warning "未找到 isolating-python-projects-on-e-drive skill，使用项目内最小隔离回退。"
    $env:HOME = Join-Path $RepoRoot '.home'
    $env:USERPROFILE = $env:HOME
    $env:APPDATA = Join-Path $env:HOME 'AppData\Roaming'
    $env:LOCALAPPDATA = Join-Path $env:HOME 'AppData\Local'
    $env:TEMP = Join-Path $RepoRoot '.tmp'
    $env:TMP = $env:TEMP
    $env:TMPDIR = $env:TEMP
    $env:UV_CACHE_DIR = Join-Path $RepoRoot '.uv-cache'
    $env:UV_PYTHON_INSTALL_DIR = Join-Path $RepoRoot '.uv-python'
    $env:UV_PROJECT_ENVIRONMENT = Join-Path $RepoRoot '.venv'
    $env:UV_MANAGED_PYTHON = '1'
    $env:UV_PYTHON_INSTALL_REGISTRY = '0'
    $env:UV_LINK_MODE = 'copy'
    $env:PYTHONUSERBASE = Join-Path $RepoRoot '.python-user'
    $env:PYTHONPYCACHEPREFIX = Join-Path $RepoRoot '.pycache'
    if ($Proxy) {
        $env:HTTP_PROXY = $Proxy
        $env:HTTPS_PROXY = $Proxy
        $env:ALL_PROXY = $Proxy
        $env:http_proxy = $Proxy
        $env:https_proxy = $Proxy
    }
    foreach ($d in @(
            $env:HOME, $env:APPDATA, $env:LOCALAPPDATA, $env:TEMP,
            $env:UV_CACHE_DIR, $env:UV_PYTHON_INSTALL_DIR,
            $env:PYTHONUSERBASE, $env:PYTHONPYCACHEPREFIX
        )) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
    }
}

Set-Location $RepoRoot

$activate = Join-Path $RepoRoot '.venv\Scripts\Activate.ps1'
if (-not (Test-Path -LiteralPath $activate)) {
    throw "未找到虚拟环境: $activate`n请先运行: .\scripts\windows\Install-EDriveIsolated.ps1"
}
. $activate

$vt = Join-Path $RepoRoot '.venv\Scripts\vibe-trading.exe'
if (-not (Test-Path -LiteralPath $vt)) {
    throw "未找到 CLI: $vt`n请先运行安装脚本。"
}

# 方便直接敲 vibe-trading
if (-not (Get-Command vibe-trading -ErrorAction SilentlyContinue)) {
    $env:Path = "$(Join-Path $RepoRoot '.venv\Scripts');$env:Path"
}

Write-Host ""
Write-Host "已进入隔离环境:" -ForegroundColor Green
Write-Host "  Repo   : $RepoRoot"
Write-Host "  Python : $((Get-Command python).Source)"
Write-Host "  HOME   : $env:HOME"
Write-Host "  Cache  : $env:UV_CACHE_DIR"
Write-Host "  Temp   : $env:TEMP"
Write-Host "  Proxy  : $Proxy"
Write-Host ""
Write-Host "可用命令示例:" -ForegroundColor Cyan
Write-Host "  vibe-trading --version"
Write-Host "  vibe-trading init"
Write-Host "  vibe-trading"
Write-Host "  vibe-trading serve --port 8899"
Write-Host ""
