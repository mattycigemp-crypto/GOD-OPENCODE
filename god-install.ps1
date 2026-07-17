# ============================================
# GOD-OPENCODE MASTER INSTALLER
# Version 2.0
# ============================================

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "scripts\shared-utils.ps1")
$Root = Get-ProjectRoot
$Scripts = Join-Path $Root "scripts"

Clear-Host
Write-Banner "GOD-OPENCODE v2.0"

# =====================================================
# DIRECTORY STRUCTURE
# =====================================================

Write-Banner "Checking Folder Structure"

$Folders = @(
    "agents", "backups", "commands", "config", "logs",
    "mcps", "memory", "models", "prompts", "router",
    "scripts", "skills", "templates", "tools", "workflows"
)

foreach ($Folder in $Folders) {
    EnsureFolder (Join-Path $Root $Folder)
}

# =====================================================
# BUILD
# =====================================================

RunStep "Builder Engine" "god-builder.ps1"
RunStep "Expansion Engine" "god-expansion.ps1"

# =====================================================
# INSTALL SKILLS
# =====================================================

Write-Banner "Installing OpenCode Skills"

$Installer = Join-Path $Root "install.ps1"

if (Test-Path $Installer) {
    & $Installer
} else {
    Write-Host "install.ps1 missing." -ForegroundColor Yellow
}

# =====================================================
# HEALTH CHECK
# =====================================================

RunStep "Health Check" "god-health.ps1"

# =====================================================
# SUMMARY
# =====================================================

Write-Banner "Summary"

$Summary = @{}

$Summary["Skills"] =
    if (Test-Path "$HOME\.config\opencode\skills") {
        (Get-ChildItem "$HOME\.config\opencode\skills" -Directory).Count
    } else { 0 }

$Summary["Agents"] =
    if (Test-Path "$Root\agents") {
        (Get-ChildItem "$Root\agents" -Directory).Count
    } else { 0 }

$Summary["Workflows"] =
    if (Test-Path "$Root\workflows") {
        (Get-ChildItem "$Root\workflows" -File).Count
    } else { 0 }

$Summary["Templates"] =
    if (Test-Path "$Root\templates") {
        (Get-ChildItem "$Root\templates" -Directory).Count
    } else { 0 }

$Summary["Prompts"] =
    if (Test-Path "$Root\prompts") {
        (Get-ChildItem "$Root\prompts" -Directory).Count
    } else { 0 }

$Summary["MCP Registry"] =
    if (Test-Path "$Root\mcps\registry.json") {
        "Present"
    } else {
        "Missing"
    }

$Summary.GetEnumerator() | ForEach-Object {
    "{0,-15}: {1}" -f $_.Key, $_.Value
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "          GOD-OPENCODE READY" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
