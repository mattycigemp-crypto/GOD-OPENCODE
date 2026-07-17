# ============================================
# GOD-OPENCODE CLI
# Version 1.0
# ============================================
# Non-interactive command-line interface.
# Usage:
#   .\god-cli.ps1 install             # install globally
#   .\god-cli.ps1 health              # health check
#   .\god-cli.ps1 test                # run tests
#   .\god-cli.ps1 code-graph           # build code graph
#   .\god-cli.ps1 skill-fragment -Query "auth jwt"
#   .\god-cli.ps1 smart-load -Query "fastapi async" -Top 3
#   .\god-cli.ps1 session -Init
#   .\god-cli.ps1 session -Track -Agent "backend-engineer"
#   .\god-cli.ps1 wiki-build
#   .\god-cli.ps1 cursor-export
#   .\god-cli.ps1 skills-sync -TopN 5
#   .\god-cli.ps1 status
# ============================================

param(
    [Parameter(Position=0)]
    [string]$Command = "",

    [string]$Query = "",
    [string]$Context = "",
    [int]$Top = 5,
    [int]$TopN = 5,
    [string]$Agent = "",
    [string]$Skill = "",
    [string]$Project = "",
    [string]$Languages = "",
    [switch]$Init,
    [switch]$Recall,
    [switch]$Prefs,
    [switch]$Stats,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors
$C = @{
    Ok = "Green"; Warn = "Yellow"; Err = "Red"
    Info = "Cyan"; Accent = "Magenta"; Dim = "DarkGray"
}

function Write-Status($label, $value, $color = "Green") {
    Write-Host "  " -NoNewline
    Write-Host ($label.PadRight(22)) -ForegroundColor $C.Dim -NoNewline
    Write-Host $value -ForegroundColor $color
}

function Show-Help {
    Write-Host ""
    Write-Host "  GOD-OPENCODE CLI" -ForegroundColor $C.Accent
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor $C.Dim
    Write-Host ""
    Write-Host "  Usage: .\god-cli.ps1 <command> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "  Commands:" -ForegroundColor $C.Info
    Write-Host "    install          Install globally to ~/.config/opencode/" -ForegroundColor White
    Write-Host "    health           Run health check" -ForegroundColor White
    Write-Host "    test             Run Pester tests" -ForegroundColor White
    Write-Host "    code-graph       Build multi-language code graph" -ForegroundColor White
    Write-Host "    skill-fragment   Dynamic context lookup" -ForegroundColor White
    Write-Host "    smart-load       Smart skill loader with caching" -ForegroundColor White
    Write-Host "    session          Session memory management" -ForegroundColor White
    Write-Host "    wiki-build       Auto-generate wiki reference pages" -ForegroundColor White
    Write-Host "    cursor-export    Export .cursorrules for all agents" -ForegroundColor White
    Write-Host "    skills-sync      Sync skills from registry" -ForegroundColor White
    Write-Host "    security-scan    Pre-commit security scanning" -ForegroundColor White
    Write-Host "    agent-orch       Multi-agent task delegation" -ForegroundColor White
    Write-Host "    mcp-connect      Connect to external tools via MCP" -ForegroundColor White
    Write-Host "    smart-git        AI-powered git integration" -ForegroundColor White
    Write-Host "    status           Show install status" -ForegroundColor White
    Write-Host "    ui               Launch interactive TUI" -ForegroundColor White
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor $C.Info
    Write-Host "    -Query <text>     Query for skill-fragment/smart-load" -ForegroundColor $C.Dim
    Write-Host "    -Context <text>   Context for smart-load" -ForegroundColor $C.Dim
    Write-Host "    -Top <n>          Max results (default: 5)" -ForegroundColor $C.Dim
    Write-Host "    -TopN <n>         Skills to sync (default: 5)" -ForegroundColor $C.Dim
    Write-Host "    -Agent <name>     Agent name for session tracking" -ForegroundColor $C.Dim
    Write-Host "    -Skill <name>     Skill name for session tracking" -ForegroundColor $C.Dim
    Write-Host "    -Languages <list> Languages for code-graph (e.g. ps1,py,js)" -ForegroundColor $C.Dim
    Write-Host "    -Task <text>      Task description for agent-orch" -ForegroundColor $C.Dim
    Write-Host "    -Tool <name>      Tool name for mcp-connect (chrome/database/jira/monitoring)" -ForegroundColor $C.Dim
    Write-Host "    -Action <name>    Action for mcp-connect" -ForegroundColor $C.Dim
    Write-Host "    -Target <name>    Target for mcp-connect" -ForegroundColor $C.Dim
    Write-Host "    -Message <text>   Commit message for smart-git" -ForegroundColor $C.Dim
    Write-Host "    -Init             Initialize new session" -ForegroundColor $C.Dim
    Write-Host "    -Recall           Recall last session" -ForegroundColor $C.Dim
    Write-Host "    -Prefs            Show learned preferences" -ForegroundColor $C.Dim
    Write-Host "    -Stats            Show usage analytics" -ForegroundColor $C.Dim
    Write-Host "    -Help             Show this help" -ForegroundColor $C.Dim
    Write-Host ""
}

if ($Help -or $Command -eq "" -or $Command -eq "help") {
    Show-Help
    exit 0
}

switch ($Command.ToLower()) {
    "install" {
        Write-Host "`n  Installing GOD-OPENCODE globally...`n" -ForegroundColor $C.Info
        & (Join-Path $Root "install.ps1")
    }
    "health" {
        & (Join-Path $Root "god-health.ps1")
    }
    "test" {
        $config = New-PesterConfiguration
        $config.Run.Path = Join-Path $Root "tests"
        $config.Output.Verbosity = "Normal"
        $config.Run.PassThru = $true
        $r = Invoke-Pester -Configuration $config
        Write-Host "`n  Passed: $($r.PassedCount)  Failed: $($r.FailedCount)  Skipped: $($r.SkippedCount)`n" -ForegroundColor $(if ($r.FailedCount -eq 0) { "Green" } else { "Red" })
        exit $r.FailedCount
    }
    "code-graph" {
        $cliParams = @{}
        if ($Languages) { $cliParams["Languages"] = $Languages }
        & (Join-Path $Root "scripts/code-graph.ps1") @cliParams
    }
    "skill-fragment" {
        if ([string]::IsNullOrWhiteSpace($Query)) {
            Write-Host "  Error: -Query is required" -ForegroundColor $C.Err
            Write-Host "  Usage: .\god-cli.ps1 skill-fragment -Query 'authentication jwt'" -ForegroundColor $C.Dim
            exit 1
        }
        $cliParams = @{ Query = $Query }
        if ($Top -ne 5) { $cliParams["Top"] = $Top }
        & (Join-Path $Root "scripts/skill-fragment.ps1") @cliParams
    }
    "smart-load" {
        if ([string]::IsNullOrWhiteSpace($Query)) {
            Write-Host "  Error: -Query is required" -ForegroundColor $C.Err
            Write-Host "  Usage: .\god-cli.ps1 smart-load -Query 'fastapi async' -Context 'backend'" -ForegroundColor $C.Dim
            exit 1
        }
        $cliParams = @{ Query = $Query }
        if ($Context) { $cliParams["Context"] = $Context }
        if ($Top -ne 5) { $cliParams["Top"] = $Top }
        & (Join-Path $Root "scripts/smart-loader.ps1") @cliParams
    }
    "session" {
        $sessionParams = @{}
        if ($Init) { $sessionParams["Init"] = $true }
        if ($Recall) { $sessionParams["Recall"] = $true }
        if ($Prefs) { $sessionParams["Prefs"] = $true }
        if ($Stats) { $sessionParams["Stats"] = $true }
        if ($Agent) { $sessionParams["Track"] = $true; $sessionParams["Agent"] = $Agent }
        if ($Skill) { $sessionParams["Track"] = $true; $sessionParams["Skill"] = $Skill }
        if ($Project) { $sessionParams["Track"] = $true; $sessionParams["Project"] = $Project }
        if ($sessionParams.Count -eq 0) { $sessionParams["Stats"] = $true }
        & (Join-Path $Root "scripts/session-memory.ps1") @sessionParams
    }
    "wiki-build" {
        & (Join-Path $Root "scripts/build-wiki.ps1")
    }
    "cursor-export" {
        Write-Host "`n  Exporting .cursorrules for all agents...`n" -ForegroundColor $C.Info
        & (Join-Path $Root "scripts/install-skill.ps1") -Use cursorrules
    }
    "skills-sync" {
        Write-Host "`n  Syncing top $TopN skills from registry...`n" -ForegroundColor $C.Info
        & (Join-Path $Root "scripts/install-skill.ps1") -Sync -TopN $TopN
    }
    "security-scan" {
        $scanParams = @{}
        if ($Query) { $scanParams["Path"] = $Query }
        if ($Context -eq "staged") { $scanParams["Staged"] = $true }
        & (Join-Path $Root "scripts/security-scan.ps1") @scanParams
    }
    "agent-orch" {
        if ([string]::IsNullOrWhiteSpace($Query)) {
            Write-Host "  Error: -Query is required (task description)" -ForegroundColor $C.Err
            Write-Host "  Usage: .\god-cli.ps1 agent-orch -Query 'Build a REST API with auth'" -ForegroundColor $C.Dim
            exit 1
        }
        $orchParams = @{ Task = $Query }
        if ($Agent) { $orchParams["Agents"] = $Agent }
        & (Join-Path $Root "scripts/agent-orchestrator.ps1") @orchParams
    }
    "mcp-connect" {
        if ([string]::IsNullOrWhiteSpace($Query)) {
            Write-Host "  Error: -Query is required (tool name)" -ForegroundColor $C.Err
            Write-Host "  Usage: .\god-cli.ps1 mcp-connect -Query chrome -Context screenshot" -ForegroundColor $C.Dim
            exit 1
        }
        $mcpParams = @{ Tool = $Query; Action = $Context }
        if ($Skill) { $mcpParams["Target"] = $Skill }
        & (Join-Path $Root "scripts/mcp-connect.ps1") @mcpParams
    }
    "smart-git" {
        $gitCommand = if ($Query) { $Query } else { "status" }
        $gitParams = @{ Command = $gitCommand }
        if ($Agent) { $gitParams["Message"] = $Agent }
        & (Join-Path $Root "scripts/smart-git.ps1") @gitParams
    }
    "status" {
        Write-Host "`n  GOD-OPENCODE Status" -ForegroundColor $C.Accent
        Write-Host "  ═══════════════════════════════════════" -ForegroundColor $C.Dim
        Write-Host ""

        # Repo skills
        $repoSkills = (Get-ChildItem -Path (Join-Path $Root "skills") -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "Repo Skills" "$repoSkills SKILL.md files"

        # Global install
        $globalDir = Join-Path $HOME ".config/opencode"
        if (Test-Path "$globalDir/skills") {
            $globalSkills = (Get-ChildItem "$globalDir/skills" -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
            Write-Status "Global Skills" "$globalSkills installed" "Green"
        } else {
            Write-Status "Global Skills" "Not installed" "Yellow"
        }

        # Agents
        $agents = (Get-ChildItem (Join-Path $Root "agents") -Directory -ErrorAction SilentlyContinue).Count
        Write-Status "Agents" "$agents loaded"

        # Workflows
        $wfs = (Get-ChildItem (Join-Path $Root "workflows") -Filter "*.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "Workflows" "$wfs available"

        # Commands
        $cmds = (Get-ChildItem (Join-Path $Root "commands") -Filter "*.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "Commands" "$cmds slash"

        # Code graph
        $cgPath = Join-Path $Root "docs/wiki/_data/code-graph.json"
        if (Test-Path $cgPath) {
            $cg = Get-Content $cgPath -Raw | ConvertFrom-Json
            Write-Status "Code Graph" "$($cg.nodeCount) functions, $($cg.edgeCount) edges" "Green"
        } else {
            Write-Status "Code Graph" "Not built" "Yellow"
        }

        # Session memory
        $smPath = Join-Path $Root "memory/session.json"
        if (Test-Path $smPath) {
            $sm = Get-Content $smPath -Raw | ConvertFrom-Json
            Write-Status "Session" "$($sm.id) (saved $($sm.lastSaved))" "Green"
        } else {
            Write-Status "Session" "No active session" "Yellow"
        }

        Write-Host ""
    }
    "ui" {
        & (Join-Path $Root "god-ui.ps1")
    }
    default {
        Write-Host "  Unknown command: $Command" -ForegroundColor $C.Err
        Write-Host "  Run .\god-cli.ps1 -Help for available commands" -ForegroundColor $C.Dim
        exit 1
    }
}
