#Requires -Version 5.1
<#
.SYNOPSIS
  一键启动 Vibe-Trading Web UI（默认 http://localhost:8899）。
#>
[CmdletBinding()]
param(
    [int]$Port = 8899,
    [string]$Proxy = 'http://127.0.0.1:7897',
    [string]$HostAddress = '127.0.0.1'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot 'Enter-IsolatedEnv.ps1') -Proxy $Proxy

$vt = Join-Path $RepoRoot '.venv\Scripts\vibe-trading.exe'
Write-Host "启动 Web UI: http://localhost:$Port" -ForegroundColor Green
Write-Host "（Ctrl+C 结束）" -ForegroundColor Yellow
# 默认仅本机；若需局域网访问请自行配置 API_AUTH_KEY
& $vt serve --port $Port
