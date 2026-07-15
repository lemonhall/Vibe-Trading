#Requires -Version 5.1
<#
.SYNOPSIS
  在 E:\development\Vibe-Trading 上安装 / 修复 E 盘隔离的 Python 环境与 vibe-trading CLI。

.DESCRIPTION
  - 使用 isolating-python-projects-on-e-drive skill（若存在）创建 managed Python + .venv
  - 因上游 pyproject 的 optional extra [channels] 在部分 Python 标记下会解析失败，
    默认采用「基础包可编辑安装」：uv pip install -e .
  - 不安装 IM channels 全家桶；需要时再手动加 extras

.EXAMPLE
  .\scripts\windows\Install-EDriveIsolated.ps1
  .\scripts\windows\Install-EDriveIsolated.ps1 -PythonVersion 3.12 -Proxy http://127.0.0.1:7897
#>
[CmdletBinding()]
param(
    [string]$PythonVersion = '3.12',
    [string]$Proxy = 'http://127.0.0.1:7897',
    [switch]$WithAshare,
    [switch]$WithDeepseek,
    [switch]$WithLongbridge
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if ([System.IO.Path]::GetPathRoot($RepoRoot) -ne 'E:\') {
    throw "仓库必须位于 E: 盘。当前: $RepoRoot"
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw '未找到 uv。请先安装 uv 并确保在 PATH 中。'
}

$skillInit = Join-Path $env:USERPROFILE '.agents\skills\isolating-python-projects-on-e-drive\scripts\Initialize-EDrivePythonProject.ps1'
$skillEnter = Join-Path $env:USERPROFILE '.agents\skills\isolating-python-projects-on-e-drive\scripts\Enter-EDrivePythonProject.ps1'

Write-Host "==> Repo: $RepoRoot" -ForegroundColor Cyan
Write-Host "==> Proxy: $Proxy"
Write-Host "==> Python: $PythonVersion"

if (Test-Path -LiteralPath $skillInit) {
    Write-Host '==> 使用 E 盘隔离 skill 初始化（SkipSync，避免 channels extra 解析失败）' -ForegroundColor Cyan
    & $skillInit -ProjectPath $RepoRoot -PythonVersion $PythonVersion -Proxy $Proxy -SkipSync
}
else {
    Write-Warning '未找到 skill，使用最小初始化回退。'
    . (Join-Path $PSScriptRoot 'Enter-IsolatedEnv.ps1') -Proxy $Proxy
    Set-Location $RepoRoot
    uv python install $PythonVersion --no-bin --no-registry
    if (-not (Test-Path (Join-Path $RepoRoot '.venv\Scripts\python.exe'))) {
        uv venv --python $PythonVersion --managed-python --allow-existing .venv
    }
}

# 重新进入隔离会话变量
if (Test-Path -LiteralPath $skillEnter) {
    . $skillEnter -ProjectPath $RepoRoot -Proxy $Proxy | Out-Null
}
else {
    . (Join-Path $PSScriptRoot 'Enter-IsolatedEnv.ps1') -Proxy $Proxy
}

Set-Location $RepoRoot

Write-Host '==> 可编辑安装基础包: uv pip install -e .' -ForegroundColor Cyan
uv pip install -e .
if ($LASTEXITCODE -ne 0) { throw 'uv pip install -e . 失败' }

$extras = @()
if ($WithAshare) { $extras += 'ashare' }
if ($WithDeepseek) { $extras += 'deepseek' }
if ($WithLongbridge) { $extras += 'longbridge' }
if ($extras.Count -gt 0) {
    $spec = '.[ {0} ]' -f ($extras -join ',')
    # uv/pip editable extras syntax
    $spec = ".[{0}]" -f ($extras -join ',')
    Write-Host "==> 安装 extras: $spec" -ForegroundColor Cyan
    uv pip install -e $spec
    if ($LASTEXITCODE -ne 0) { throw "extras 安装失败: $spec" }
}

$py = Join-Path $RepoRoot '.venv\Scripts\python.exe'
$vt = Join-Path $RepoRoot '.venv\Scripts\vibe-trading.exe'
if (-not (Test-Path $py)) { throw "缺少 $py" }
if (-not (Test-Path $vt)) { throw "缺少 $vt" }

Write-Host '==> 验证隔离路径' -ForegroundColor Cyan
& $py -c "import sys; print('exe=', sys.executable); print('base=', sys.base_prefix)"
& $vt --version

$cache = (& uv cache dir).Trim()
$pydir = (& uv python dir).Trim()
Write-Host "uv cache : $cache"
Write-Host "uv python: $pydir"
if (-not $cache.StartsWith('E:\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "uv cache 不在 E 盘: $cache"
}
if (-not $pydir.StartsWith('E:\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "uv python 不在 E 盘: $pydir"
}

Write-Host ''
Write-Host '安装完成。下一步:' -ForegroundColor Green
Write-Host '  1) 双击/运行  Start-VibeTrading.bat   （Web UI）'
Write-Host '  2) 或 PowerShell:  . .\scripts\windows\Enter-IsolatedEnv.ps1'
Write-Host '  3) 首次配置:      vibe-trading init'
Write-Host '  4) 使用说明:      README.zh-cn.md  与  docs/WINDOWS-E-DRIVE-USAGE.zh-cn.md'
Write-Host ''
