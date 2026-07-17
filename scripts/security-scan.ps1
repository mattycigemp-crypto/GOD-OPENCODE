# ============================================
# GOD-OPENCODE SECURITY SCANNER
# Version 1.0
# ============================================
# Pre-commit security scanning for:
# - Hardcoded secrets (API keys, passwords, tokens)
# - Known vulnerability patterns
# - License compatibility
#
# Usage:
#   .\scripts\security-scan.ps1                    # scan all staged files
#   .\scripts\security-scan.ps1 -Path "file.py"   # scan specific file
#   .\scripts\security-scan.ps1 -Staged            # scan git staged files only
#   .\scripts\security-scan.ps1 -Severity "High"   # filter by severity

param(
    [string]$Path = "",
    [switch]$Staged,
    [string]$Severity = "All",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent

# Secret patterns to detect
$SecretPatterns = @(
    @{ Pattern = '(?i)(api[_-]?key|apikey)\s*[=:]\s*["\x27]([A-Za-z0-9+/=_-]{20,})'; Name = "API Key"; Severity = "Critical" }
    @{ Pattern = '(?i)(secret|password|passwd|pwd)\s*[=:]\s*["\x27]([^"\x27]{8,})'; Name = "Hardcoded Password"; Severity = "Critical" }
    @{ Pattern = '(?i)(token|access[_-]?token|auth[_-]?token)\s*[=:]\s*["\x27]([A-Za-z0-9+/=_-]{20,})'; Name = "Auth Token"; Severity = "Critical" }
    @{ Pattern = '(?i)aws[_-]?(secret[_-]?access[_-]?key|access[_-]?key[_-]?id)\s*[=:]\s*["\x27]([A-Za-z0-9+/=]{20,})'; Name = "AWS Key"; Severity = "Critical" }
    @{ Pattern = '(?i)ghp_[A-Za-z0-9]{36}'; Name = "GitHub PAT"; Severity = "Critical" }
    @{ Pattern = '(?i)sk-[A-Za-z0-9]{32,}'; Name = "OpenAI Key"; Severity = "Critical" }
    @{ Pattern = '(?i)xox[baprs]-[A-Za-z0-9-]+'; Name = "Slack Token"; Severity = "Critical" }
    @{ Pattern = '(?i)AKIA[0-9A-Z]{16}'; Name = "AWS Access Key ID"; Severity = "High" }
    @{ Pattern = '(?i)-----BEGIN (RSA |EC )?PRIVATE KEY-----'; Name = "Private Key"; Severity = "Critical" }
)

# Vulnerability patterns
$VulnPatterns = @(
    @{ Pattern = '(?i)(eval|exec)\s*\('; Name = "Code Injection"; Severity = "High" }
    @{ Pattern = '(?i)subprocess\.call\(.*shell\s*=\s*True'; Name = "Shell Injection"; Severity = "High" }
    @{ Pattern = '(?i)os\.system\('; Name = "Shell Injection"; Severity = "High" }
    @{ Pattern = '(?i)SELECT.*FROM.*WHERE.*\+\s*\$'; Name = "SQL Injection"; Severity = "Critical" }
    @{ Pattern = '(?i)innerHTML\s*='; Name = "XSS Risk"; Severity = "Medium" }
    @{ Pattern = '(?i)document\.write\('; Name = "XSS Risk"; Severity = "Medium" }
    @{ Pattern = '(?i)dangerouslySetInnerHTML'; Name = "XSS Risk"; Severity = "Medium" }
    @{ Pattern = '(?i)\.\./\.\./'; Name = "Path Traversal"; Severity = "High" }
)

# License patterns
$LicensePatterns = @(
    @{ Pattern = '(?i)GPL-3\.0'; Name = "GPL-3.0"; Risk = "Copyleft" }
    @{ Pattern = '(?i)AGPL-3\.0'; Name = "AGPL-3.0"; Risk = "Network Copyleft" }
    @{ Pattern = '(?i)SSPL'; Name = "SSPL"; Risk = "Copyleft" }
    @{ Pattern = '(?i)EUPL'; Name = "EUPL"; Risk = "Copyleft" }
)

function Get-StagedFiles {
    $output = & git diff --cached --name-only --diff-filter=ACM 2>&1
    if ($LASTEXITCODE -ne 0) { return @() }
    return $output | Where-Object { $_.Trim() -ne "" }
}

function Scan-File {
    param(
        [string]$FilePath,
        [string]$FullRoot
    )
    
    $findings = @()
    $fullPath = Join-Path $FullRoot $FilePath
    
    if (!(Test-Path $fullPath)) { return @() }
    
    $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return @() }
    
    $lines = $content -split "`n"
    
    # Scan for secrets
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        foreach ($rule in $SecretPatterns) {
            if ($line -match $rule.Pattern) {
                $findings += [pscustomobject]@{
                    File = $FilePath
                    Line = ($i + 1)
                    Rule = $rule.Name
                    Severity = $rule.Severity
                    Message = "Found $($rule.Name)"
                }
            }
        }
    }
    
    # Scan for vulnerabilities
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        foreach ($rule in $VulnPatterns) {
            if ($line -match $rule.Pattern) {
                $findings += [pscustomobject]@{
                    File = $FilePath
                    Line = ($i + 1)
                    Rule = $rule.Name
                    Severity = $rule.Severity
                    Message = "Found $($rule.Name)"
                }
            }
        }
    }
    
    return $findings
}

# Main
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GOD-OPENCODE SECURITY SCANNER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$files = @()
if ($Staged) {
    $files = Get-StagedFiles
    Write-Host "  Scanning staged files..." -ForegroundColor Gray
} elseif ($Path) {
    $files = @($Path)
    Write-Host "  Scanning: $Path" -ForegroundColor Gray
} else {
    $files = Get-StagedFiles
    if ($files.Count -eq 0) {
        Write-Host "  No staged files. Use -Path to scan specific files." -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }
    Write-Host "  Scanning $($files.Count) staged files..." -ForegroundColor Gray
}

$allFindings = @()
foreach ($file in $files) {
    $findings = Scan-File -FilePath $file -FullRoot $Root
    $allFindings += $findings
}

# Filter by severity
if ($Severity -ne "All") {
    $allFindings = $allFindings | Where-Object { $_.Severity -eq $Severity }
}

# Report
if ($allFindings.Count -eq 0) {
    Write-Host "  [OK] No security issues found" -ForegroundColor Green
    Write-Host ""
    $Script:ScanExitCode = 0
    return
}

Write-Host "  Found $($allFindings.Count) security issues:" -ForegroundColor Red
Write-Host ""

$grouped = $allFindings | Group-Object Severity
foreach ($group in $grouped) {
    $color = switch ($group.Name) {
        "Critical" { "Red" }
        "High" { "Yellow" }
        "Medium" { "DarkYellow" }
        default { "Gray" }
    }
    Write-Host "  [$($group.Name)] ($($group.Count) issues)" -ForegroundColor $color
    foreach ($finding in $group.Group) {
        Write-Host "    $($finding.File):$($finding.Line) - $($finding.Rule)" -ForegroundColor $color
    }
    Write-Host ""
}

$critical = ($allFindings | Where-Object { $_.Severity -eq "Critical" }).Count
if ($critical -gt 0) {
    Write-Host "  BLOCKED: $critical critical issues must be fixed" -ForegroundColor Red
    $Script:ScanExitCode = 1
} else {
    Write-Host "  WARNING: Issues found but none critical" -ForegroundColor Yellow
    $Script:ScanExitCode = 0
}
