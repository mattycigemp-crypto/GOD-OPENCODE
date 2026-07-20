# ============================================
# GOD-OPENCODE UNIVERSAL SKILLS PUBLISHER
# One-Command Skill Distribution Pipeline
# ============================================
# Orchestrates the full skill distribution workflow:
#   1. Security audit (audit-skills.ps1)
#   2. Cross-tool conversion (convert-skills.ps1)
#   3. Agent directory sync (sync-skills.ps1)
#   4. Optional: package release zip
#
# Usage:
#   .\scripts\publish-skills.ps1                          # full pipeline
#   .\scripts\publish-skills.ps1 -SkipAudit               # skip security audit
#   .\scripts\publish-skills.ps1 -SkipSync                # skip agent sync
#   .\scripts\publish-skills.ps1 -Package                 # also create release zip
#   .\scripts\publish-skills.ps1 -Package -Version 1.7.0  # set zip version
#   .\scripts\publish-skills.ps1 -DryRun                  # preview all steps
#   .\scripts\publish-skills.ps1 -Tools cursor,claude     # sync to specific tools only

[CmdletBinding()]
param(
    [switch]$SkipAudit,
    [switch]$SkipConvert,
    [switch]$SkipSync,
    [switch]$Package,
    [switch]$DryRun,
    [string]$Version = "",
    [string[]]$Tools = @(),
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$ScriptsDir = Join-Path $Root "scripts"
$SkillsRoot = Join-Path $Root "skills"

$timestamp = Get-ISOTimestamp
$totalStart = Get-Date

# ============================================
# Banner
# ============================================
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  GOD-OPENCODE UNIVERSAL SKILLS PUBLISHER" -ForegroundColor Cyan
Write-Host "  One-Command Skill Distribution Pipeline" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Timestamp:  $timestamp" -ForegroundColor Gray
Write-Host "  Skills dir: $SkillsRoot" -ForegroundColor Gray

$skillCount = (Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -File).Count
Write-Host "  Skills:     $skillCount" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "  Mode:       DRY RUN (no changes)" -ForegroundColor Yellow
}
Write-Host ""

# Track results
$results = [ordered]@{
    Audit    = @{ Status = "SKIPPED"; Duration = 0 }
    Convert  = @{ Status = "SKIPPED"; Duration = 0 }
    Sync     = @{ Status = "SKIPPED"; Duration = 0 }
    Package  = @{ Status = "SKIPPED"; Duration = 0 }
}

# ============================================
# Step 1: Security Audit
# ============================================
if (-not $SkipAudit) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host "  STEP 1/4: SECURITY AUDIT" -ForegroundColor DarkCyan
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $stepStart = Get-Date
    try {
        $auditScript = Join-Path $ScriptsDir "audit-skills.ps1"
        & $auditScript -Quiet
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Audit.Status = "PASSED"
        $results.Audit.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [OK] Security audit passed ($($results.Audit.Duration)s)" -ForegroundColor Green
    } catch {
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Audit.Status = "FAILED"
        $results.Audit.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [FAIL] Security audit failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Pipeline halted. Fix security issues before publishing." -ForegroundColor Red
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "  [SKIP] Security audit (skipped by flag)" -ForegroundColor Yellow
}

# ============================================
# Step 2: Cross-Tool Conversion
# ============================================
if (-not $SkipConvert) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host "  STEP 2/4: CROSS-TOOL CONVERSION" -ForegroundColor DarkCyan
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $stepStart = Get-Date
    try {
        $convertScript = Join-Path $ScriptsDir "convert-skills.ps1"
        $convertParams = @{ AllSkills = $true }
        if ($OutDir) { $convertParams['OutDir'] = $OutDir }
        if ($DryRun) { $convertParams['DryRun'] = $true }
        & $convertScript @convertParams
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Convert.Status = "DONE"
        $results.Convert.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [OK] Conversion complete ($($results.Convert.Duration)s)" -ForegroundColor Green
    } catch {
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Convert.Status = "FAILED"
        $results.Convert.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [FAIL] Conversion failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  [SKIP] Conversion (skipped by flag)" -ForegroundColor Yellow
}

# ============================================
# Step 3: Agent Directory Sync
# ============================================
if (-not $SkipSync) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host "  STEP 3/4: AGENT DIRECTORY SYNC" -ForegroundColor DarkCyan
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $stepStart = Get-Date
    try {
        $syncScript = Join-Path $ScriptsDir "sync-skills.ps1"
        $syncParams = @{}
        if ($Tools -and $Tools.Count -gt 0) {
            $syncParams['Tool'] = ($Tools -join ',')
        } else {
            $syncParams['Tool'] = 'all'
        }
        if ($DryRun) { $syncParams['DryRun'] = $true }
        & $syncScript @syncParams
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Sync.Status = "DONE"
        $results.Sync.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [OK] Sync complete ($($results.Sync.Duration)s)" -ForegroundColor Green
    } catch {
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Sync.Status = "FAILED"
        $results.Sync.Duration = [math]::Round($elapsed, 1)
        Write-Host ""
        Write-Host "  [WARN] Sync failed (non-fatal): $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [SKIP] Agent sync (skipped by flag)" -ForegroundColor Yellow
}

# ============================================
# Step 4: Package Release Zip
# ============================================
if ($Package) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host "  STEP 4/4: PACKAGE RELEASE ZIP" -ForegroundColor DarkCyan
    Write-Host "=========================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $stepStart = Get-Date
    try {
        $releaseDir = Join-Path $Root "release"
        EnsureFolder $releaseDir

        $zipName = if ($Version) { "cognivect-skills-$Version.zip" } else { "cognivect-skills-latest.zip" }
        $zipPath = Join-Path $releaseDir $zipName

        $convertDir = if ($OutDir) { $OutDir } else { Join-Path $Root "dist\converted" }

        if (Test-Path $zipPath) {
            Remove-Item $zipPath -Force
        }

        if (Test-Path $convertDir) {
            if ($DryRun) {
                Write-Host "  [DRY-RUN] Would create: $zipPath" -ForegroundColor Yellow
                Write-Host "  [DRY-RUN] From: $convertDir" -ForegroundColor Yellow
            } else {
                Compress-Archive -Path "$convertDir\*" -DestinationPath $zipPath -Force
                $size = (Get-Item $zipPath).Length / 1MB
                Write-Host "  [CREATED] $zipPath ($([math]::Round($size, 1)) MB)" -ForegroundColor Green
            }
            $elapsed = ((Get-Date) - $stepStart).TotalSeconds
            $results.Package.Status = "DONE"
            $results.Package.Duration = [math]::Round($elapsed, 1)
        } else {
            Write-Host "  [SKIP] No converted files at $convertDir" -ForegroundColor Yellow
            $elapsed = ((Get-Date) - $stepStart).TotalSeconds
            $results.Package.Status = "SKIPPED"
            $results.Package.Duration = [math]::Round($elapsed, 1)
        }
    } catch {
        $elapsed = ((Get-Date) - $stepStart).TotalSeconds
        $results.Package.Status = "FAILED"
        $results.Package.Duration = [math]::Round($elapsed, 1)
        Write-Host "  [FAIL] Packaging failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  [SKIP] Packaging (use -Package to enable)" -ForegroundColor Yellow
}

# ============================================
# Final Summary
# ============================================
$totalElapsed = ((Get-Date) - $totalStart).TotalSeconds

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  PUBLISH SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Step          Status      Duration" -ForegroundColor Gray
Write-Host "  ----          ------      --------" -ForegroundColor Gray

foreach ($key in $results.Keys) {
    $r = $results[$key]
    $statusColor = switch ($r.Status) {
        "PASSED"  { "Green" }
        "DONE"    { "Green" }
        "FAILED"  { "Red" }
        "SKIPPED" { "DarkGray" }
        default   { "Gray" }
    }
    Write-Host ("  {0,-13} {1,-12} {2}s" -f $key, $r.Status, $r.Duration) -ForegroundColor $statusColor
}

Write-Host ""
Write-Host "  Total: $([math]::Round($totalElapsed, 1))s" -ForegroundColor White
Write-Host ""

# Final status
$anyFailed = $results.Values | Where-Object { $_.Status -eq "FAILED" }
if ($anyFailed) {
    Write-Host "  RESULT: Completed with errors" -ForegroundColor Yellow
} else {
    Write-Host "  RESULT: All steps completed successfully" -ForegroundColor Green
}
Write-Host ""
