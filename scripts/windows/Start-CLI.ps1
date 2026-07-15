#Requires -Version 5.1
<#
.SYNOPSIS
  一键进入隔离环境并启动交互式 vibe-trading CLI。
#>
[CmdletBinding()]
param(
    [string]$Proxy = 'http://127.0.0.1:7897'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot 'Enter-IsolatedEnv.ps1') -Proxy $Proxy

$vt = Join-Path $RepoRoot '.venv\Scripts\vibe-trading.exe'
Write-Host '启动交互式 CLI（输入 exit / Ctrl+C 退出）' -ForegroundColor Green
& $vt
