# ============================================
# INSTALL-SKILL
# GOD-OPENCODE Feature 3 (Registry CLI) + v1.3.0 dispatcher
# ============================================
# Pull-installs a single skill from a registry source into
# ~/.config/opencode/skills/<category>/<skill-name>/. Idempotent: hash-compares
# the source and destination SKILL.md and only writes on change.
#
# Usage (single skill, original behaviour):
#   .\scripts\install-skill.ps1 -Path backend/fastapi
#   .\scripts\install-skill.ps1 -Path backend/fastapi -Source mattycigemp-crypto/god-opencode
#   .\scripts\install-skill.ps1 -Path backend/fastapi -Source owner/repo -Version v1.2.0
#   .\scripts\install-skill.ps1 -Path backend/fastapi -DryRun
#
# Usage (v1.3.0 dispatchers):
#   .\scripts\install-skill.ps1 -Sync                       # fetch top 20 from registry-sources.txt
#   .\scripts\install-skill.ps1 -Sync -TopN 5                # fetch top 5
#   .\scripts\install-skill.ps1 -Use cursorrules             # generate .cursorrules for every agent
#
# Resolves to a tag/branch (defaults: registry row or 'latest'). Falls back to
# master if a git tag is unavailable. Requires `git` on PATH.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][string]$Path,
    [string]$Source = "",
    [string]$Version = "",
    [switch]$DryRun,
    [string]$RegistryListPath = "",

    # v1.3.0 dispatchers
    [switch]$Sync,
    [int]$TopN = 20,
    [string]$Use = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$DefaultRegistry = if ($RegistryListPath) { $RegistryListPath } else { Join-Path $Root "registry-sources.txt" }

# ---------------------------------------------------------------
# Dispatcher: -Use <subcommand>
# ---------------------------------------------------------------
if ($Use) {
    switch ($Use.ToLower()) {
        "cursorrules" {
            Write-Host ""
            Write-Host "==> god-opencode use cursorrules" -ForegroundColor Cyan
            Write-Host "    Generating .cursorrules for every agent into dist/cursorrules/" -ForegroundColor DarkGray
            Write-Host ""

            $cursorrulesScript = Join-Path $PSScriptRoot "export-cursorrules.ps1"
            if (!(Test-Path $cursorrulesScript)) {
                Write-Host "[ERR] scripts/export-cursorrules.ps1 not found in repo." -ForegroundColor Red
                exit 1
            }

            $distDir = Join-Path $Root "dist\cursorrules"
            if (!(Test-Path $distDir)) {
                New-Item -ItemType Directory -Path $distDir -Force | Out-Null
            }
            & $cursorrulesScript -AllAgents -OutDir $distDir

            Write-Host ""
            Write-Host "[OK] Wrote $( (Get-ChildItem -Path $distDir -Filter '*.cursorrules' -File | Measure-Object).Count ) .cursorrules files to $distDir" -ForegroundColor Green
            Write-Host ""
            Write-Host "Drop-in for /Cursor/Windsurf/Aider/" -ForegroundColor Magenta
            Write-Host "    cp $distDir\backend-engineer.cursorrules <your-project>/.cursorrules" -ForegroundColor Cyan
            Write-Host "  (one file per agent; pick the one closest to your work)" -ForegroundColor DarkGray
            Write-Host ""
            exit 0
        }
        default {
            Write-Host "[ERR] Unknown 'use' subcommand: $Use" -ForegroundColor Red
            Write-Host "  Known: cursorrules" -ForegroundColor DarkGray
            exit 1
        }
    }
}

# ---------------------------------------------------------------
# Dispatcher: -Sync
# ---------------------------------------------------------------
if ($Sync) {
    Write-Host ""
    Write-Host "==> god-opencode sync" -ForegroundColor Cyan
    Write-Host "    Shallow-cloning top $TopN registries from $DefaultRegistry" -ForegroundColor DarkGray
    Write-Host ""

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

    if ($Registry.Count -eq 0) {
        Write-Host "[ERR] $DefaultRegistry has no parseable entries." -ForegroundColor Red
        exit 1
    }

    $Mirror = Join-Path $Root "skills-mirror"
    if (!(Test-Path $Mirror)) {
        New-Item -ItemType Directory -Path $Mirror -Force | Out-Null
    }

    $i = 0
    $Fetched = 0
    $Skipped = 0
    $Failed = 0
    foreach ($entry in ($Registry.Keys | Select-Object -First $TopN)) {
        $i++
        $ver = $Registry[$entry].DefaultVer
        Write-Host "[$i/$TopN] $entry @ $ver"

        $safe = ($entry -replace "[^a-zA-Z0-9_.-]", "_")
        $Target = Join-Path $Mirror $safe

        if (Test-Path $Target) {
            Write-Host "    [SKIP] already in skills-mirror/ (delete to re-fetch)" -ForegroundColor Yellow
            $Skipped++
            continue
        }

        if ($DryRun) {
            Write-Host "    [DRY-RUN] would clone to $Target" -ForegroundColor Yellow
            continue
        }

        try {
            $CloneSpec = $entry
            if ($ver -notin @("latest", "master", "main")) {
                $CloneSpec = "$entry@$ver"
            }
            git clone --depth 1 --quiet $CloneSpec $Target 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "    [ERR] clone failed (network/auth?)" -ForegroundColor Red
                $Failed++
                continue
            }

            # Count skills inside if the clone is a skill bundle
            $skillCount = 0
            $checkSkills = Join-Path $Target "skills"
            if (Test-Path $checkSkills) {
                $skillCount = (Get-ChildItem -Path $checkSkills -Directory -Recurse |
                    Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }).Count
            }
            if ($skillCount -gt 0) {
                Write-Host "    [OK]   $skillCount skills" -ForegroundColor Green
            } else {
                Write-Host "    [OK]   cloned (no skills/ subfolder in source)" -ForegroundColor Green
            }
            $Fetched++
        } catch {
            Write-Host "    [ERR] $($_.Exception.Message)" -ForegroundColor Red
            $Failed++
        }
    }

    Write-Host ""
    Write-Host "Sync summary: $Fetched fetched, $Skipped skipped, $Failed failed, target $Mirror" -ForegroundColor Cyan
    if ($Failed -gt 0) {
        Write-Host "  (Run with -DryRun to preview; check network + git auth for failures.)" -ForegroundColor DarkGray
    }
    if (($Fetched + $Skipped) -gt 0) {
        Write-Host "  Next: copy or symlink skills from skills-mirror/*/skills/<category>/<name> into your own skills/." -ForegroundColor DarkGray
    }
    exit 0
}

# ---------------------------------------------------------------
# Original single-skill install path
# ---------------------------------------------------------------

if (-not $Path) {
    Write-Host "[ERR] Provide -Path <category>/<skill>, or -Sync, or -Use <subcommand>." -ForegroundColor Red
    Write-Host "  Use -Sync for bulk fetch, -Use cursorrules for Cursor rule export." -ForegroundColor DarkGray
    exit 1
}

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
        $Source = ($Registry.Keys | Select-Object -First 1)
        if (-not $Version) { $Version = $Registry[$Source].DefaultVer }
    } else {
        Write-Host "[ERR] No -Source supplied and $DefaultRegistry has no entries." -ForegroundColor Red
        exit 1
    }
} else {
    if (-not $Version -and $Registry.ContainsKey($Source)) {
        $Version = $Registry[$Source].DefaultVer
    }
}

if (-not $Version) { $Version = "latest" }

# 2. Map <category>/<skill-name> on the remote to the destination layout.
$RemotePath = $Path
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
