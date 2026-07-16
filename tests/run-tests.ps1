# Run all non-integration tests
# Usage: .\tests\run-tests.ps1
# Integration only: .\tests\run-tests.ps1 -Integration

param([switch]$Integration, [switch]$All)

$ErrorActionPreference = "Stop"

try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
} catch {
    Write-Host "Installing Pester 5..." -ForegroundColor Yellow
    Install-Module Pester -Force -Scope CurrentUser -SkipPublisherCheck
    Import-Module Pester -MinimumVersion 5.0
}

$cfg = New-PesterConfiguration
$cfg.Output.Verbosity = 'Detailed'
$cfg.Run.PassThru      = $true

if ($Integration) {
    $cfg.Run.Path = Join-Path $PSScriptRoot "integration"
    Write-Host "Running integration tests..." -ForegroundColor Cyan
} elseif ($All) {
    $cfg.Run.Path = $PSScriptRoot
    Write-Host "Running ALL tests..." -ForegroundColor Cyan
} else {
    $cfg.Run.Path = $PSScriptRoot
    $cfg.Run.ExcludePath = Join-Path $PSScriptRoot "integration"
    Write-Host "Running unit/property/smoke tests (excluding integration)..." -ForegroundColor Cyan
}

$Result = Invoke-Pester -Configuration $cfg

Write-Host ""
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "  TEST SUMMARY" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "Passed : $($Result.PassedCount)"  -ForegroundColor Green
Write-Host "Failed : $($Result.FailedCount)"  -ForegroundColor $(if ($Result.FailedCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "Skipped: $($Result.SkippedCount)" -ForegroundColor Yellow
Write-Host ""

if ($Result.FailedCount -gt 0) { exit 1 } else { exit 0 }
