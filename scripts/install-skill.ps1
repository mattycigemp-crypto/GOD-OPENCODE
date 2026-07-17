# ============================================
# INSTALL-SKILL
# GOD-OPENCODE Feature 3 (Registry CLI)
# ============================================
# Pull-installs a single skill from a registry source into
# ~/.config/opencode/skills/<category>/<skill-name>/. Idempotent: hash-compares
# the source and destination SKILL.md and only writes on change.
#
# Usage:
#   .\scripts\install-skill.ps1 -Path backend/fastapi
#   .\scripts\install-skill.ps1 -Path backend/fastapi -Source mattycigemp-crypto/god-opencode
#   .\scripts\install-skill.ps1 -Path backend/fastapi -Source owner/repo -Version v1.2.0
#   .\scripts\install-skill.ps1 -Path backend/fastapi -DryRun
#
# Resolves to a tag/branch (defaults: registry row or 'latest'). Falls back to
# master if a git tag is unavailable. Requires `git` on PATH.

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Path,
    [string]$Source = "",
    [string]$Version = "",
    [switch]$DryRun,
    [string]$RegistryListPath = ""   # defaults to <repo-root>/registry-sources.txt
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$DefaultRegistry = if ($RegistryListPath) { $RegistryListPath } else { Join-Path $Root "registry-sources.txt" }

# 1. Resolve source + version.
$Registry = @{}
if (Test-Path $DefaultRegistry) {
    Get-Content $DefaultRegistry | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith("#")) { return }
        $parts = $line -split "\|", 4
        if ($parts.Count -lt 3) { return }
        $Registry[$parts[0]] = @{
            Label       = $parts[1].Trim()
            DefaultVer  = $parts[2].Trim()
            Description = if ($parts.Count -ge 4) { $parts[3].Trim() } else { "" }
        }
    }
}

if (-not $Source) {
    if ($Registry.Keys.Count -gt 0) {
        # Pick the first (canonical) entry as default
        $Source = ($Registry.Keys | Select-Object -First 1)
        if (-not $Version) { $Version = $Registry[$Source].DefaultVer }
    } else {
        Write-Host "[ERR] No -Source supplied and $DefaultRegistry has no entries." -ForegroundColor Red
        exit 1
    }
} else {
    # -Source supplied; use registry row's default version if any
    if (-not $Version -and $Registry.ContainsKey($Source)) {
        $Version = $Registry[$Source].DefaultVer
    }
}

if (-not $Version) { $Version = "latest" }

# 2. Map <category>/<skill-name> on the remote to the destination layout.
$RemotePath = $Path   # e.g. backend/fastapi
$RemoteName = Split-Path $RemotePath -Leaf
$DestRoot = Join-Path $HOME ".config\opencode\skills"
$Dest = Join-Path $DestRoot $RemoteName

# 3. Build a temp shallow clone of the source repository.
$TmpRoot = Join-Path $env:TEMP "god-install-skill-$(Get-Random)"
if ($DryRun) {
    Write-Host "[DRY-RUN] would shallow-clone $Source @ $Version"
    Write-Host "[DRY-RUN] would copy $RemotePath/SKILL.md -> $Dest/SKILL.md"
    exit 0
}

try {
    New-Item -ItemType Directory -Path $TmpRoot -Force | Out-Null

    $Clone = $Source
    if ($Version -ne "latest" -and $Version -notin @("master", "main")) {
        $Clone = "${Source}@${Version}"
    }
    Write-Host "[CLONE] $Source @ $Version (depth=1)"

    git clone --depth 1 --quiet $Clone $TmpRoot 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERR] git clone failed. Check network + credentials and try again." -ForegroundColor Red
        exit 1
    }

    $RemoteSkill = Join-Path $TmpRoot $RemotePath
    $RemoteFile  = Join-Path $RemoteSkill "SKILL.md"
    if (!(Test-Path $RemoteFile)) {
        Write-Host "[ERR] $RemotePath/SKILL.md not found in $Source @ $Version" -ForegroundColor Red
        exit 1
    }

    if (!(Test-Path $Dest)) {
        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    }

    $DestFile = Join-Path $Dest "SKILL.md"
    $SourceHash = (Get-FileHash $RemoteFile).Hash
    $DestHash   = if (Test-Path $DestFile) { (Get-FileHash $DestFile).Hash } else { "" }

    if ($SourceHash -eq $DestHash) {
        Write-Host "[UNCHANGED] $DestFile (matches $Source @ $Version)"
    } else {
        Copy-Item -Force $RemoteFile $DestFile
        Write-Host "[INSTALLED] $DestFile (from $Source @ $Version)"
    }
}
finally {
    if (Test-Path $TmpRoot) {
        Remove-Item -Recurse -Force $TmpRoot -ErrorAction SilentlyContinue
    }
}
