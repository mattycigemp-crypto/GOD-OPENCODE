# ============================================
# GOD-OPENCODE RELEASE PACKAGER
# Version 1.0
# ============================================

param(
    [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
$ReleaseDir = Join-Path $Root "release"
$PackageName = "god-opencode-v$Version.zip"
$PackagePath = Join-Path $ReleaseDir $PackageName

$Include = @(
    "skills",
    "workflows",
    "agents",
    "commands",
    "scripts",
    "docs",
    "install.ps1",
    "opencode.json",
    "AGENTS.md",
    "README.md",
    "CHANGELOG.md",
    "LICENSE"
)

# Explicit exclusions - never include in package (defense-in-depth even though $Include is allowlist-based)
$Exclude = @(
    ".git",
    ".github",
    ".freebuff",
    "release",
    "*.zip",
    "*.log",
    "*.tmp"
)

Write-Host ""
Write-Host "============================================"
Write-Host "     GOD-OPENCODE RELEASE PACKAGER"
Write-Host "============================================"
Write-Host ""
Write-Host "Version: $Version"
Write-Host "Output:  $PackagePath"
Write-Host ""

# Ensure release directory exists
if (!(Test-Path $ReleaseDir)) {
    New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
}

# Remove any existing package for this version
if (Test-Path $PackagePath) {
    Remove-Item $PackagePath -Force
    Write-Host "Removed existing package."
}

# Create staging directory
$Staging = Join-Path $ReleaseDir "staging"
if (Test-Path $Staging) {
    Remove-Item $Staging -Recurse -Force
}
New-Item -ItemType Directory -Path $Staging -Force | Out-Null

# Copy included items into staging, pruning excluded directories
foreach ($Item in $Include) {
    $Source = Join-Path $Root $Item
    $Target = Join-Path $Staging $Item

    if (!(Test-Path $Source)) {
        Write-Host "[WARN]  $Item not found, skipping" -ForegroundColor Yellow
        continue
    }

    $IsDir = (Get-Item $Source).PSIsContainer

    if ($IsDir) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null

        # Walk source and copy everything except excluded paths
        Get-ChildItem -Path $Source -Recurse -Force | ForEach-Object {
            $Rel = $_.FullName.Substring($Source.Length).TrimStart('\', '/')
            $Skip = $false
            foreach ($Ex in $Exclude) {
                if ($Rel -like $Ex -or $Rel -like "$Ex\*" -or $Rel -like "*/$Ex") {
                    $Skip = $true
                    break
                }
            }
            if (-not $Skip) {
                $DestPath = Join-Path $Target $Rel
                if ($_.PSIsContainer) {
                    if (!(Test-Path $DestPath)) {
                        New-Item -ItemType Directory -Path $DestPath -Force | Out-Null
                    }
                } else {
                    Copy-Item $_.FullName $DestPath -Force
                }
            }
        }
        Write-Host "[ADDED] $Item (filtered)"
    } else {
        Copy-Item $Source $Target -Force
        Write-Host "[ADDED] $Item"
    }
}

# Create the zip package
Compress-Archive -Path "$Staging\*" -DestinationPath $PackagePath -Force

# Clean up staging
Remove-Item $Staging -Recurse -Force

Write-Host ""
Write-Host "Release package created: $PackagePath" -ForegroundColor Green
Write-Host ""
