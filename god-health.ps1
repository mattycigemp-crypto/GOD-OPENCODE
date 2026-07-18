# ============================================
# CogniVect HEALTH CHECK
# Version 2.0
# ============================================

param(
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$Root = $PSScriptRoot
$SkillsTarget = Join-Path $HOME ".config\opencode\skills"

$Passed  = 0
$Failed  = 0
$Results = @()

function Check-Pass($Component, $Detail = "") {
    $script:Passed++
    $msg = "[OK]   $Component"
    if ($Detail) { $msg += " - $Detail" }
    $script:Results += $msg
    if (-not $Quiet) { Write-Host $msg -ForegroundColor Green }
}

function Check-Fail($Component, $Expected, $Actual) {
    $script:Failed++
    $msg = "[FAIL] ${Component}: expected $Expected, found $Actual"
    $script:Results += $msg
    Write-Host $msg -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================================"
Write-Host "          CogniVect HEALTH CHECK v2.0"
Write-Host "======================================================"
Write-Host ""

# ============================================
# CHECK 1 - Required directories exist
# ============================================
$RequiredDirs = @(
    "agents","backups","commands","config","logs","mcps",
    "memory","models","prompts","router","scripts","skills",
    "templates","tools","workflows"
)

foreach ($Dir in $RequiredDirs) {
    $Path = Join-Path $Root $Dir
    if (Test-Path $Path) {
        Check-Pass "Directory: $Dir"
    } else {
        Check-Fail "Directory: $Dir" "exists" "missing"
    }
}

# ============================================
# CHECK 2 - Skills installed in OpenCode
# ============================================
$SkillsRepo = Get-ChildItem (Join-Path $Root "skills") -Recurse -File -Filter "SKILL.md" -ErrorAction SilentlyContinue
$SkillCount = $SkillsRepo.Count

if ($SkillCount -eq 0) {
    Check-Fail "Skills (repo)" "at least 1 SKILL.md" "0 SKILL.md files found"
} else {
    Check-Pass "Skills (repo)" "$SkillCount SKILL.md files"
}

if (Test-Path $SkillsTarget) {
    $InstalledSkills = (Get-ChildItem $SkillsTarget -Directory -ErrorAction SilentlyContinue).Count
    Check-Pass "Skills (OpenCode)" "$InstalledSkills skills installed at $SkillsTarget"
} else {
    Check-Fail "Skills (OpenCode)" "directory at $SkillsTarget" "not found - run .\install.ps1"
}

# ============================================
# CHECK 3 - MCPs registry valid and enabled MCPs listed
# ============================================
$RegistryPath = Join-Path $Root "mcps\registry.json"
if (!(Test-Path $RegistryPath)) {
    Check-Fail "MCP Registry" "mcps/registry.json exists" "file missing"
} else {
    try {
        $Registry = Get-Content $RegistryPath -Raw | ConvertFrom-Json
        $EnabledMCPs = $Registry.servers.PSObject.Properties | Where-Object { $_.Value.enabled -eq $true }
        $EnabledCount = ($EnabledMCPs | Measure-Object).Count
        Check-Pass "MCP Registry" "valid JSON, $EnabledCount enabled MCPs"

        foreach ($MCP in $EnabledMCPs) {
            Check-Pass "MCP: $($MCP.Name)" "enabled in registry"
        }
    } catch {
        Check-Fail "MCP Registry" "valid JSON" "parse error: $_"
    }
}

# ============================================
# CHECK 4 - Router config valid with ≥1 routing rule
# ============================================
$RouterPath = Join-Path $Root "router\agent-router.json"
if (!(Test-Path $RouterPath)) {
    Check-Fail "Router Config" "router/agent-router.json exists" "file missing"
} else {
    try {
        $RouterConfig = Get-Content $RouterPath -Raw | ConvertFrom-Json
        $RuleCount = ($RouterConfig.routing.PSObject.Properties | Measure-Object).Count
        if ($RuleCount -ge 1) {
            Check-Pass "Router Config" "valid JSON, $RuleCount routing rules"
        } else {
            Check-Fail "Router Config" "at least 1 routing rule" "0 rules found"
        }
    } catch {
        Check-Fail "Router Config" "valid JSON" "parse error: $_"
    }
}

# ============================================
# CHECK 5 - Key scripts exist
# ============================================
$RequiredScripts = @(
    "god-install.ps1",
    "install.ps1",
    "god-backup.ps1",
    "scripts\god-builder.ps1",
    "scripts\god-expansion.ps1",
    "scripts\god-intelligence.ps1",
    "scripts\upgrade-all-skills.ps1",
    "scripts\install-mcps.ps1",
    "scripts\router.ps1",
    "scripts\memory.ps1",
    "scripts\workflow-engine.ps1",
    "tools\project-scan.ps1"
)

foreach ($Script in $RequiredScripts) {
    $Path = Join-Path $Root $Script
    if (Test-Path $Path) {
        Check-Pass "Script: $Script"
    } else {
        Check-Fail "Script: $Script" "file exists" "not found"
    }
}

# ============================================
# CHECK 6 - Agents all present with required sections
# ============================================
$RequiredAgents = @(
    "principal-engineer","backend-engineer","frontend-engineer",
    "ai-engineer","security-engineer","database-architect",
    "devops-engineer","debugger","researcher","technical-writer"
)

foreach ($Agent in $RequiredAgents) {
    $AgentFile = Join-Path $Root "agents\$Agent\AGENT.md"
    if (!(Test-Path $AgentFile)) {
        Check-Fail "Agent: $Agent" "AGENT.md exists" "file missing"
    } else {
        $Content = Get-Content $AgentFile -Raw
        $Missing = @()
        if ($Content -notmatch '## Role')             { $Missing += "## Role" }
        if ($Content -notmatch '## Responsibilities') { $Missing += "## Responsibilities" }
        if ($Content -notmatch '## Standards')        { $Missing += "## Standards" }
        if ($Content -notmatch '## Skills')           { $Missing += "## Skills" }

        if ($Missing.Count -eq 0) {
            Check-Pass "Agent: $Agent"
        } else {
            Check-Fail "Agent: $Agent" "all required sections" "missing: $($Missing -join ', ')"
        }
    }
}

# ============================================
# CHECK 7 - Required workflows present
# ============================================
$RequiredWorkflows = @("build-application","api-development","security-audit","bug-investigation")

foreach ($Wf in $RequiredWorkflows) {
    $Path = Join-Path $Root "workflows\$Wf.md"
    if (Test-Path $Path) {
        Check-Pass "Workflow: $Wf"
    } else {
        Check-Fail "Workflow: $Wf" "file exists" "not found"
    }
}

# ============================================
# CHECK 8 - Required commands present
# ============================================
$RequiredCommands = @("build","architect","debug","review","secure","optimize")

foreach ($Cmd in $RequiredCommands) {
    $Path = Join-Path $Root "commands\$Cmd.md"
    if (Test-Path $Path) {
        Check-Pass "Command: /$Cmd"
    } else {
        Check-Fail "Command: /$Cmd" "commands/$Cmd.md exists" "not found"
    }
}

# ============================================
# SUMMARY
# ============================================
$Total = $Passed + $Failed

Write-Host ""
Write-Host "======================================================"

if ($Failed -eq 0) {
    Write-Host "All checks passed. $Total components verified." -ForegroundColor Green
} else {
    Write-Host "$Passed passed, $Failed failed. $Total components checked." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Failed checks:"
    $Results | Where-Object { $_ -match '^\[FAIL\]' } | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Red
    }
}

Write-Host "======================================================"
Write-Host ""

# Exit code for CI integration
if ($Failed -gt 0) { exit 1 } else { exit 0 }

