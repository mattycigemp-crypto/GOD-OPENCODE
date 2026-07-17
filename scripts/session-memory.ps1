# ============================================
# GOD-OPENCODE SESSION MEMORY SYSTEM
# Version 2.0
# ============================================
# Cross-session persistent memory with:
# - Session context (last agents, skills, projects)
# - Usage analytics (frequency tracking)
# - Preference learning (auto-detected patterns)
# - Conversation continuity
#
# Usage:
#   .\scripts\session-memory.ps1                    # show session summary
#   .\scripts\session-memory.ps1 -Init              # initialize new session
#   .\scripts\session-memory.ps1 -Save              # save current session
#   .\scripts\session-memory.ps1 -Recall            # recall last session context
#   .\scripts\session-memory.ps1 -Track -Agent "backend-engineer"
#   .\scripts\session-memory.ps1 -Track -Skill "fastapi"
#   .\scripts\session-memory.ps1 -Track -Project "my-api"
#   .\scripts\session-memory.ps1 -Prefs              # show learned preferences

param(
    [switch]$Init,
    [switch]$Save,
    [switch]$Recall,
    [switch]$Prefs,
    [switch]$Stats,
    [switch]$Track,
    [string]$Agent = "",
    [string]$Skill = "",
    [string]$Project = "",
    [string]$Command = "",
    [string]$MemoryDir = ""
)

$ErrorActionPreference = "Stop"

if ($MemoryDir -eq "") {
    $Root = Split-Path $PSScriptRoot -Parent
    $MemoryDir = Join-Path $Root "memory"
}

$SessionFile = Join-Path $MemoryDir "session.json"
$PrefsFile   = Join-Path $MemoryDir "AGENT_PREFERENCES.md"
$AnalyticsFile = Join-Path $MemoryDir "analytics.json"

# ============================================
# Helper Functions
# ============================================

function Ensure-MemoryDir {
    if (!(Test-Path $MemoryDir)) {
        New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null
    }
}

function Get-SafeJson {
    param([string]$Path, $Default = $null)
    if (!(Test-Path $Path)) {
        # Always return a usable object, never null
        if ($null -ne $Default) { return $Default }
        return @{}
    }
    try {
        $result = Get-Content $Path -Raw | ConvertFrom-Json
        if ($null -ne $result) { return $result }
        return if ($null -ne $Default) { $Default } else { @{} }
    } catch {
        return if ($null -ne $Default) { $Default } else { @{} }
    }
}

function Set-SafeJson {
    param([string]$Path, $Data)
    $Dir = Split-Path $Path -Parent
    if ($Dir -and !(Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
    $Data | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding UTF8
}

function Get-ISOTimestamp {
    return (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
}

# ============================================
# Session Context
# ============================================

function Initialize-Session {
    Ensure-MemoryDir

    $session = @{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        lastSaved = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
        workingDir = (Get-Location).Path
        os = if ($IsLinux -or $IsMacOS) { "linux" } else { "windows" }
        shell = if ($IsLinux -or $IsMacOS) { "bash" } else { "powershell" }
    }

    Set-SafeJson -Path $SessionFile -Data $session
    Write-Host "[SESSION] Initialized session $($session.id)" -ForegroundColor Green
    return $session
}

function Save-Session {
    Ensure-MemoryDir

    $session = Get-SafeJson -Path $SessionFile -Default (@{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
    })

    $session.lastSaved = Get-ISOTimestamp
    Set-SafeJson -Path $SessionFile -Data $session

    # Update analytics
    Update-Analytics -Session $session

    Write-Host "[SESSION] Saved session $($session.id)" -ForegroundColor Green
}

function Get-LastSession {
    $session = Get-SafeJson -Path $SessionFile
    if (-not $session) {
        Write-Host "[SESSION] No previous session found" -ForegroundColor Yellow
        return $null
    }
    return $session
}

# ============================================
# Usage Analytics
# ============================================

function Update-Analytics {
    param($Session)

    $analytics = Get-SafeJson -Path $AnalyticsFile -Default (@{
        totalSessions = 0
        totalAgentUses = @{}
        totalSkillUses = @{}
        totalProjectVisits = @{}
        totalCommandUses = @{}
        firstSeen = Get-ISOTimestamp
        lastSeen = Get-ISOTimestamp
    })

    $analytics.totalSessions++
    $analytics.lastSeen = Get-ISOTimestamp

    # Convert to hashtable for reliable ContainsKey
    $agentHash = @{}
    foreach ($p in $analytics.totalAgentUses.PSObject.Properties) { $agentHash[$p.Name] = $p.Value }
    foreach ($agent in $Session.agents) {
        if (-not $agentHash.ContainsKey($agent)) { $agentHash[$agent] = 0 }
        $agentHash[$agent]++
    }
    $analytics.totalAgentUses = $agentHash

    $skillHash = @{}
    foreach ($p in $analytics.totalSkillUses.PSObject.Properties) { $skillHash[$p.Name] = $p.Value }
    foreach ($skill in $Session.skills) {
        if (-not $skillHash.ContainsKey($skill)) { $skillHash[$skill] = 0 }
        $skillHash[$skill]++
    }
    $analytics.totalSkillUses = $skillHash

    $projHash = @{}
    foreach ($p in $analytics.totalProjectVisits.PSObject.Properties) { $projHash[$p.Name] = $p.Value }
    foreach ($proj in $Session.projects) {
        if (-not $projHash.ContainsKey($proj)) { $projHash[$proj] = 0 }
        $projHash[$proj]++
    }
    $analytics.totalProjectVisits = $projHash

    $cmdHash = @{}
    foreach ($p in $analytics.totalCommandUses.PSObject.Properties) { $cmdHash[$p.Name] = $p.Value }
    foreach ($cmd in $Session.commands) {
        if (-not $cmdHash.ContainsKey($cmd)) { $cmdHash[$cmd] = 0 }
        $cmdHash[$cmd]++
    }
    $analytics.totalCommandUses = $cmdHash

    Set-SafeJson -Path $AnalyticsFile -Data $analytics
}

# ============================================
# Tracking Functions
# ============================================

function Add-AgentUsage {
    param([string]$AgentName)

    $session = Get-SafeJson -Path $SessionFile -Default (@{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
    })

    if ($session.agents -notcontains $AgentName) {
        $session.agents += $AgentName
    }

    $session.lastSaved = Get-ISOTimestamp
    Set-SafeJson -Path $SessionFile -Data $session
    Write-Host "[SESSION] Tracked agent: $AgentName" -ForegroundColor Cyan
}

function Add-SkillUsage {
    param([string]$SkillName)

    $session = Get-SafeJson -Path $SessionFile -Default (@{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
    })

    if ($session.skills -notcontains $SkillName) {
        $session.skills += $SkillName
    }

    $session.lastSaved = Get-ISOTimestamp
    Set-SafeJson -Path $SessionFile -Data $session
    Write-Host "[SESSION] Tracked skill: $SkillName" -ForegroundColor Cyan
}

function Add-ProjectVisit {
    param([string]$ProjectName)

    $session = Get-SafeJson -Path $SessionFile -Default (@{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
    })

    if ($session.projects -notcontains $ProjectName) {
        $session.projects += $ProjectName
    }

    $session.lastSaved = Get-ISOTimestamp
    Set-SafeJson -Path $SessionFile -Data $session
}

function Add-CommandUsage {
    param([string]$CommandName)

    $session = Get-SafeJson -Path $SessionFile -Default (@{
        id = [guid]::NewGuid().ToString().Substring(0, 8)
        started = Get-ISOTimestamp
        agents = @()
        skills = @()
        projects = @()
        commands = @()
    })

    if ($session.commands -notcontains $CommandName) {
        $session.commands += $CommandName
    }

    $session.lastSaved = Get-ISOTimestamp
    Set-SafeJson -Path $SessionFile -Data $session
}

# ============================================
# Preference Learning
# ============================================

function Get-LearnedPreferences {
    $analytics = Get-SafeJson -Path $AnalyticsFile -Default (@{
        totalSessions = 0
        totalAgentUses = @{}
        totalSkillUses = @{}
        totalProjectVisits = @{}
        totalCommandUses = @{}
    })

    $prefs = @{
        favoriteAgent = ""
        favoriteSkill = ""
        favoriteProject = ""
        mostUsedCommand = ""
        totalSessions = $analytics.totalSessions
    }

    # Find most used agent
    $agentProps = @()
    foreach ($p in $analytics.totalAgentUses.PSObject.Properties) { $agentProps += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($agentProps.Count -gt 0) {
        $topAgent = $agentProps | Sort-Object Value -Descending | Select-Object -First 1
        $prefs.favoriteAgent = $topAgent.Name
    }

    # Find most used skill
    $skillProps = @()
    foreach ($p in $analytics.totalSkillUses.PSObject.Properties) { $skillProps += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($skillProps.Count -gt 0) {
        $topSkill = $skillProps | Sort-Object Value -Descending | Select-Object -First 1
        $prefs.favoriteSkill = $topSkill.Name
    }

    # Find most visited project
    $projProps = @()
    foreach ($p in $analytics.totalProjectVisits.PSObject.Properties) { $projProps += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($projProps.Count -gt 0) {
        $topProject = $projProps | Sort-Object Value -Descending | Select-Object -First 1
        $prefs.favoriteProject = $topProject.Name
    }

    # Find most used command
    $cmdProps = @()
    foreach ($p in $analytics.totalCommandUses.PSObject.Properties) { $cmdProps += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($cmdProps.Count -gt 0) {
        $topCommand = $cmdProps | Sort-Object Value -Descending | Select-Object -First 1
        $prefs.mostUsedCommand = $topCommand.Name
    }

    return $prefs
}

function Update-AgentPreferencesFile {
    $prefs = Get-LearnedPreferences

    $content = @"
# Agent Preferences

_Auto-generated from session memory analytics._

## Most Used Components

| Component | Name | Usage Count |
|-----------|------|-------------|
| Favorite Agent | $($prefs.favoriteAgent) | - |
| Favorite Skill | $($prefs.favoriteSkill) | - |
| Favorite Project | $($prefs.favoriteProject) | - |
| Most Used Command | $($prefs.mostUsedCommand) | - |

## Session Stats

- Total Sessions: $($prefs.totalSessions)
- Last Updated: $(Get-ISOTimestamp)

---

_These preferences are learned automatically from your usage patterns._
_Adjust or delete this file to reset learned preferences._
"@

    [System.IO.File]::WriteAllText($PrefsFile, $content)
    Write-Host "[SESSION] Updated agent preferences" -ForegroundColor Green
}

# ============================================
# Display Functions
# ============================================

function Show-SessionSummary {
    $session = Get-SafeJson -Path $SessionFile
    if (-not $session) {
        Write-Host "[SESSION] No active session" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SESSION MEMORY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Session ID:    $($session.id)" -ForegroundColor White
    Write-Host "  Started:       $($session.started)" -ForegroundColor Gray
    Write-Host "  Last Saved:    $($session.lastSaved)" -ForegroundColor Gray
    Write-Host "  Working Dir:   $($session.workingDir)" -ForegroundColor Gray
    Write-Host "  OS:            $($session.os)" -ForegroundColor Gray
    Write-Host ""

    if ($session.agents.Count -gt 0) {
        Write-Host "  Agents Used:   $($session.agents -join ', ')" -ForegroundColor Magenta
    }
    if ($session.skills.Count -gt 0) {
        Write-Host "  Skills Used:   $($session.skills -join ', ')" -ForegroundColor Cyan
    }
    if ($session.projects.Count -gt 0) {
        Write-Host "  Projects:      $($session.projects -join ', ')" -ForegroundColor Yellow
    }
    if ($session.commands.Count -gt 0) {
        Write-Host "  Commands:      $($session.commands -join ', ')" -ForegroundColor Green
    }
    Write-Host ""
}

function Show-Analytics {
    $analytics = Get-SafeJson -Path $AnalyticsFile
    if (-not $analytics) {
        Write-Host "[SESSION] No analytics data yet" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  USAGE ANALYTICS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Total Sessions:    $($analytics.totalSessions)" -ForegroundColor White
    Write-Host "  First Seen:        $($analytics.firstSeen)" -ForegroundColor Gray
    Write-Host "  Last Seen:         $($analytics.lastSeen)" -ForegroundColor Gray
    Write-Host ""

    $agentProps2 = @()
    foreach ($p in $analytics.totalAgentUses.PSObject.Properties) { $agentProps2 += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($agentProps2.Count -gt 0) {
        Write-Host "  Agent Usage:" -ForegroundColor Magenta
        $agentProps2 | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value) times" -ForegroundColor Gray
        }
        Write-Host ""
    }

    $skillProps2 = @()
    foreach ($p in $analytics.totalSkillUses.PSObject.Properties) { $skillProps2 += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($skillProps2.Count -gt 0) {
        Write-Host "  Skill Usage:" -ForegroundColor Cyan
        $skillProps2 | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value) times" -ForegroundColor Gray
        }
        Write-Host ""
    }

    $projProps2 = @()
    foreach ($p in $analytics.totalProjectVisits.PSObject.Properties) { $projProps2 += [pscustomobject]@{ Name=$p.Name; Value=$p.Value } }
    if ($projProps2.Count -gt 0) {
        Write-Host "  Project Visits:" -ForegroundColor Yellow
        $projProps2 | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value) times" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

function Show-Preferences {
    $prefs = Get-LearnedPreferences

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LEARNED PREFERENCES" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($prefs.favoriteAgent) {
        Write-Host "  Favorite Agent:    $($prefs.favoriteAgent)" -ForegroundColor Magenta
    }
    if ($prefs.favoriteSkill) {
        Write-Host "  Favorite Skill:    $($prefs.favoriteSkill)" -ForegroundColor Cyan
    }
    if ($prefs.favoriteProject) {
        Write-Host "  Favorite Project:  $($prefs.favoriteProject)" -ForegroundColor Yellow
    }
    if ($prefs.mostUsedCommand) {
        Write-Host "  Most Used Command: $($prefs.mostUsedCommand)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "  Total Sessions:    $($prefs.totalSessions)" -ForegroundColor White
    Write-Host ""
}

function Show-Recall {
    $session = Get-LastSession
    if (-not $session) { return }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  LAST SESSION CONTEXT" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Previous session: $($session.id)" -ForegroundColor White
    Write-Host "  Started: $($session.started)" -ForegroundColor Gray
    Write-Host "  Working Dir: $($session.workingDir)" -ForegroundColor Gray
    Write-Host ""

    if ($session.agents.Count -gt 0) {
        Write-Host "  You were using these agents:" -ForegroundColor Magenta
        foreach ($a in $session.agents) {
            Write-Host "    - $a" -ForegroundColor Gray
        }
    }

    if ($session.skills.Count -gt 0) {
        Write-Host "  You were working with these skills:" -ForegroundColor Cyan
        foreach ($s in $session.skills) {
            Write-Host "    - $s" -ForegroundColor Gray
        }
    }

    if ($session.projects.Count -gt 0) {
        Write-Host "  You were in these projects:" -ForegroundColor Yellow
        foreach ($p in $session.projects) {
            Write-Host "    - $p" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "  Continue where you left off?" -ForegroundColor Green
    Write-Host ""
}

# ============================================
# Main Logic
# ============================================

if ($Init) {
    Initialize-Session
} elseif ($Save) {
    Save-Session
} elseif ($Recall) {
    Show-Recall
} elseif ($Prefs) {
    Show-Preferences
    Update-AgentPreferencesFile
} elseif ($Stats) {
    Show-Analytics
} elseif ($Track) {
    if ($Agent)    { Add-AgentUsage -AgentName $Agent }
    if ($Skill)    { Add-SkillUsage -SkillName $Skill }
    if ($Project)  { Add-ProjectVisit -ProjectName $Project }
    if ($Command)  { Add-CommandUsage -CommandName $Command }
} else {
    Show-SessionSummary
}
