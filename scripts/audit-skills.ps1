# ============================================
# GOD-OPENCODE SKILL SECURITY AUDITOR
# Supply-Chain Integrity Scanner
# ============================================
# Scans SKILL.md files for malicious patterns:
# - Command injection
# - Data exfiltration
# - Hardcoded secrets
# - Suspicious shell commands
# - Supply-chain attacks (slopsquatting)
#
# Usage:
#   .\scripts\audit-skills.ps1                        # audit all skills
#   .\scripts\audit-skills.ps1 -Skill backend/fastapi  # audit specific skill
#   .\scripts\audit-skills.ps1 -Severity High          # filter by severity
#   .\scripts\audit-skills.ps1 -Report report.json     # export JSON report

[CmdletBinding()]
param(
    [string]$Skill = "",
    [string]$Severity = "All",
    [string]$Report = "",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$SkillsRoot = Join-Path $Root "skills"

# ============================================
# Malicious Pattern Rules
# ============================================

$InjectionPatterns = @(
    @{ Pattern = '(?i)eval\s*\(';              Name = "eval() call";          Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)exec\s*\(';              Name = "exec() call";          Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)subprocess\.(call|run|Popen)\('; Name = "subprocess execution"; Severity = "High"; Category = "Injection" }
    @{ Pattern = '(?i)os\.system\s*\(';        Name = "os.system() call";     Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)os\.popen\s*\(';         Name = "os.popen() call";      Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)__import__\s*\(';        Name = "Dynamic import";       Severity = "High";     Category = "Injection" }
    @{ Pattern = '(?i)compile\s*\(.*exec';     Name = "compile+exec";         Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)child_process';          Name = "Node child_process";   Severity = "High";     Category = "Injection" }
    @{ Pattern = '(?i)spawn\s*\(';             Name = "Process spawn";        Severity = "High";     Category = "Injection" }
    @{ Pattern = '(?i)ShellExecute';           Name = "ShellExecute API";     Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)Invoke-Expression';      Name = "Invoke-Expression";    Severity = "Critical"; Category = "Injection" }
    @{ Pattern = '(?i)IEX\s*\(';               Name = "IEX shorthand";        Severity = "Critical"; Category = "Injection" }
)

$ExfiltrationPatterns = @(
    @{ Pattern = '(?i)curl\s+.*https?://';     Name = "curl to external URL";   Severity = "High";     Category = "Exfiltration" }
    @{ Pattern = '(?i)wget\s+.*https?://';     Name = "wget to external URL";   Severity = "High";     Category = "Exfiltration" }
    @{ Pattern = '(?i)requests\.(get|post|put)\s*\(\s*["\x27]https?://'; Name = "HTTP request"; Severity = "High"; Category = "Exfiltration" }
    @{ Pattern = '(?i)fetch\s*\(\s*["\x27]https?://'; Name = "fetch() call";   Severity = "Medium";   Category = "Exfiltration" }
    @{ Pattern = '(?i)axios\.(get|post)\s*\(\s*["\x27]https?://'; Name = "axios call"; Severity = "Medium"; Category = "Exfiltration" }
    @{ Pattern = '(?i)Invoke-WebRequest';      Name = "PowerShell web request"; Severity = "High";     Category = "Exfiltration" }
    @{ Pattern = '(?i)Invoke-RestMethod';      Name = "PowerShell REST call";   Severity = "High";     Category = "Exfiltration" }
    @{ Pattern = '(?i)base64.*encode.*http';   Name = "Base64 + HTTP";          Severity = "Critical"; Category = "Exfiltration" }
    @{ Pattern = '(?i)nc\s+-[el]';             Name = "Netcat listener";        Severity = "Critical"; Category = "Exfiltration" }
    @{ Pattern = '(?i)socket\.connect';        Name = "Raw socket connect";     Severity = "High";     Category = "Exfiltration" }
)

$SecretPatterns = @(
    @{ Pattern = '(?i)(api[_-]?key|apikey)\s*[=:]\s*["\x27]([A-Za-z0-9+/=_-]{20,})'; Name = "Hardcoded API Key"; Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)(secret|password|passwd|pwd)\s*[=:]\s*["\x27]([^"\x27]{8,})'; Name = "Hardcoded Password"; Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)(token|access[_-]?token|auth[_-]?token)\s*[=:]\s*["\x27]([A-Za-z0-9+/=_-]{20,})'; Name = "Hardcoded Token"; Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)ghp_[A-Za-z0-9]{36}';   Name = "GitHub PAT";             Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)sk-[A-Za-z0-9]{32,}';   Name = "OpenAI API Key";         Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)xox[baprs]-[A-Za-z0-9-]+'; Name = "Slack Token";          Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)AKIA[0-9A-Z]{16}';      Name = "AWS Access Key ID";      Severity = "High";     Category = "Secrets" }
    @{ Pattern = '(?i)-----BEGIN (RSA |EC )?PRIVATE KEY-----'; Name = "Private Key"; Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)mongodb(\+srv)?://[^\s]+:[^\s]+@'; Name = "MongoDB URI with creds"; Severity = "Critical"; Category = "Secrets" }
    @{ Pattern = '(?i)postgres(ql)?://[^\s]+:[^\s]+@'; Name = "PostgreSQL URI with creds"; Severity = "Critical"; Category = "Secrets" }
)

$FileSystemPatterns = @(
    @{ Pattern = '(?i)rm\s+-rf\s+/';           Name = "Recursive delete root";  Severity = "Critical"; Category = "FileSystem" }
    @{ Pattern = '(?i)Remove-Item.*-Recurse.*-Force'; Name = "PowerShell force delete"; Severity = "High"; Category = "FileSystem" }
    @{ Pattern = '(?i)chmod\s+777';            Name = "chmod 777";              Severity = "Medium";   Category = "FileSystem" }
    @{ Pattern = '(?i)chown\s+root';           Name = "chown root";             Severity = "Medium";   Category = "FileSystem" }
    @{ Pattern = '(?i)\/etc\/passwd';           Name = "Access /etc/passwd";     Severity = "High";     Category = "FileSystem" }
    @{ Pattern = '(?i)\/etc\/shadow';           Name = "Access /etc/shadow";     Severity = "Critical"; Category = "FileSystem" }
    @{ Pattern = '(?i)\.\.\/\.\.\/';           Name = "Path traversal";         Severity = "High";     Category = "FileSystem" }
    @{ Pattern = '(?i)format\s+[a-z]:';        Name = "Disk format";            Severity = "Critical"; Category = "FileSystem" }
)

$NetworkPatterns = @(
    @{ Pattern = '(?i)0\.0\.0\.0';             Name = "Bind to all interfaces";  Severity = "Medium";   Category = "Network" }
    @{ Pattern = '(?i)iptables\s+-F';          Name = "Flush iptables";          Severity = "High";     Category = "Network" }
    @{ Pattern = '(?i)netsh\s+advfirewall';    Name = "Modify Windows firewall"; Severity = "High";     Category = "Network" }
    @{ Pattern = '(?i)Set-NetFirewallRule';    Name = "Modify firewall rules";   Severity = "High";     Category = "Network" }
)

$AllPatterns = $InjectionPatterns + $ExfiltrationPatterns + $SecretPatterns + $FileSystemPatterns + $NetworkPatterns

# ============================================
# Auditor
# ============================================

function Audit-OneSkill {
    param([string]$SkillMdPath)

    $rel = $SkillMdPath
    if ($SkillMdPath.StartsWith($SkillsRoot)) {
        $rel = $SkillMdPath.Substring($SkillsRoot.Length).TrimStart('\', '/').Replace('\', '/')
    }
    $content = Get-Content $SkillMdPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return @() }

    # Allowlist: skills that are security/audit tools themselves
    # These legitimately contain patterns like eval(), exec(), etc. as detection rules
    $allowlist = @(
        'security/security-scanner',
        'security/security-audit',
        'core/security'
    )
    $isAllowlisted = $false
    foreach ($allowed in $allowlist) {
        if ($rel -like "*$allowed*") { $isAllowlisted = $true; break }
    }

    $findings = @()
    $lines = $content -split "`r?`n"

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # Skip comment lines and markdown headers
        if ($line -match '^\s*#' -or $line -match '^\s*>') { continue }
        # Skip code fences (``` blocks) - patterns inside code examples are expected
        if ($line -match '^\s*```') { continue }

        foreach ($rule in $AllPatterns) {
            if ($line -match $rule.Pattern) {
                # For allowlisted skills, only flag Critical+High secrets, not injection/exfil patterns
                # (security skills legitimately contain these as detection rules)
                if ($isAllowlisted -and $rule.Category -in @('Injection', 'Exfiltration', 'FileSystem', 'Network')) {
                    continue
                }
                $findings += [pscustomobject]@{
                    Skill    = $rel
                    File     = $SkillMdPath
                    Line     = $i + 1
                    Rule     = $rule.Name
                    Category = $rule.Category
                    Severity = $rule.Severity
                    Content  = $line.Trim().Substring(0, [Math]::Min(100, $line.Trim().Length))
                }
            }
        }
    }

    return $findings
}

function Get-SecurityScore {
    param([array]$Findings)

    if ($Findings.Count -eq 0) { return "A+" }

    $critical = ($Findings | Where-Object { $_.Severity -eq "Critical" }).Count
    $high     = ($Findings | Where-Object { $_.Severity -eq "High" }).Count
    $medium   = ($Findings | Where-Object { $_.Severity -eq "Medium" }).Count

    if ($critical -gt 0) { return "F" }
    if ($high -gt 3)     { return "D" }
    if ($high -gt 0)     { return "C" }
    if ($medium -gt 3)   { return "C" }
    if ($medium -gt 0)   { return "B" }
    return "A"
}

# ============================================
# Main
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GOD-OPENCODE SKILL SECURITY AUDITOR" -ForegroundColor Cyan
Write-Host "  Supply-Chain Integrity Scanner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$skillFiles = @()
if ($Skill) {
    $skillMd = Join-Path $SkillsRoot "$Skill\SKILL.md"
    if (!(Test-Path $skillMd)) {
        Write-Host "[ERR] SKILL.md not found: $skillMd" -ForegroundColor Red
        exit 1
    }
    $skillFiles = @($skillMd)
} else {
    $skillFiles = Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -File
}

Write-Host "  Scanning $($skillFiles.Count) skill(s)..." -ForegroundColor Gray
Write-Host "  Rules: $($AllPatterns.Count) patterns across 5 categories" -ForegroundColor Gray
Write-Host ""

$allFindings = @()
$scoredSkills = @()

foreach ($sf in $skillFiles) {
    $skillPath = if ($sf -is [System.IO.FileInfo]) { $sf.FullName } else { $sf }
    $findings = Audit-OneSkill -SkillMdPath $skillPath

    if ($Severity -ne "All") {
        $findings = $findings | Where-Object { $_.Severity -eq $Severity }
    }

    $allFindings += $findings

    $normSkillsRoot = $SkillsRoot.TrimEnd('\', '/')
    $normPath = $skillPath.TrimEnd('\', '/')
    if ($normPath.StartsWith($normSkillsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $normPath.Substring($normSkillsRoot.Length).TrimStart('\', '/').Replace('\', '/').Replace('/SKILL.md', '')
    } else {
        $rel = [System.IO.Path]::GetFileNameWithoutExtension($skillPath)
    }
    $score = Get-SecurityScore -Findings $findings

    $scoredSkills += [pscustomobject]@{
        Skill   = $rel
        Score   = $score
        Issues  = $findings.Count
        Critical = ($findings | Where-Object { $_.Severity -eq "Critical" }).Count
        High     = ($findings | Where-Object { $_.Severity -eq "High" }).Count
        Medium   = ($findings | Where-Object { $_.Severity -eq "Medium" }).Count
    }
}

# Report
if ($allFindings.Count -eq 0) {
    Write-Host "  [OK] All skills passed security audit" -ForegroundColor Green
    Write-Host ""
    foreach ($s in $scoredSkills) {
        Write-Host "  [$($s.Score)] $($s.Skill)" -ForegroundColor Green
    }
} else {
    # Group by skill
    $grouped = $allFindings | Group-Object Skill
    foreach ($group in $grouped) {
        $grade = ($scoredSkills | Where-Object { $_.Skill -eq $group.Name }).Score
        $color = switch ($grade) {
            "A+" { "Green" }
            "A"  { "Green" }
            "B"  { "Yellow" }
            "C"  { "DarkYellow" }
            "D"  { "Red" }
            "F"  { "Red" }
            default { "Gray" }
        }
        Write-Host "  [$grade] $($group.Name) - $($group.Count) issue(s)" -ForegroundColor $color

        if (-not $Quiet) {
            foreach ($f in $group.Group) {
                $sevColor = switch ($f.Severity) {
                    "Critical" { "Red" }
                    "High"     { "Yellow" }
                    "Medium"   { "DarkYellow" }
                    default    { "Gray" }
                }
                Write-Host "      [$($f.Severity)] $($f.Rule) (line $($f.Line))" -ForegroundColor $sevColor
                Write-Host "        $($f.Content)" -ForegroundColor DarkGray
            }
        }
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalCritical = ($allFindings | Where-Object { $_.Severity -eq "Critical" }).Count
$totalHigh     = ($allFindings | Where-Object { $_.Severity -eq "High" }).Count
$totalMedium   = ($allFindings | Where-Object { $_.Severity -eq "Medium" }).Count

Write-Host "  Skills scanned:   $($skillFiles.Count)" -ForegroundColor White
Write-Host "  Total issues:     $($allFindings.Count)" -ForegroundColor White
Write-Host "  Critical:         $totalCritical" -ForegroundColor $(if ($totalCritical -gt 0) { "Red" } else { "Green" })
Write-Host "  High:             $totalHigh" -ForegroundColor $(if ($totalHigh -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Medium:           $totalMedium" -ForegroundColor $(if ($totalMedium -gt 0) { "DarkYellow" } else { "Green" })
Write-Host ""

# Score distribution
$aPlus = ($scoredSkills | Where-Object { $_.Score -eq "A+" }).Count
$aGrade = ($scoredSkills | Where-Object { $_.Score -eq "A" }).Count
$bGrade = ($scoredSkills | Where-Object { $_.Score -eq "B" }).Count
$cGrade = ($scoredSkills | Where-Object { $_.Score -eq "C" }).Count
$dGrade = ($scoredSkills | Where-Object { $_.Score -eq "D" }).Count
$fGrade = ($scoredSkills | Where-Object { $_.Score -eq "F" }).Count

Write-Host "  Grade Distribution:" -ForegroundColor White
Write-Host "    A+: $aPlus  |  A: $aGrade  |  B: $bGrade  |  C: $cGrade  |  D: $dGrade  |  F: $fGrade" -ForegroundColor Gray
Write-Host ""

# JSON report
if ($Report) {
    $reportObj = [pscustomobject]@{
        Timestamp = Get-ISOTimestamp
        SkillsScanned = $skillFiles.Count
        TotalIssues = $allFindings.Count
        Critical = $totalCritical
        High = $totalHigh
        Medium = $totalMedium
        Scores = $scoredSkills
        Findings = $allFindings
    }
    $reportObj | ConvertTo-Json -Depth 5 | Set-Content $Report -Encoding UTF8
    Write-Host "  Report exported: $Report" -ForegroundColor Green
    Write-Host ""
}

if ($totalCritical -gt 0) {
    Write-Host "  BLOCKED: $totalCritical critical issues found" -ForegroundColor Red
    exit 1
} elseif ($totalHigh -gt 0) {
    Write-Host "  WARNING: $totalHigh high-severity issues found" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "  PASSED: No high or critical issues" -ForegroundColor Green
    exit 0
}
