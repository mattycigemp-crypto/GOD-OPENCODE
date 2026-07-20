# ============================================
# GOD-OPENCODE SKILL SYNC
# Cross-Agent Distribution Engine
# ============================================
# Symlinks/copies installed skills into agent config
# directories so they work across 46+ AI tools.
#
# Inspired by qufei1993/skills-hub but as a native
# PowerShell CLI command.
#
# Usage:
#   .\scripts\sync-skills.ps1                          # sync all skills
#   .\scripts\sync-skills.ps1 -Tool cursor             # sync to Cursor only
#   .\scripts\sync-skills.ps1 -Tool all                # sync to all detected tools
#   .\scripts\sync-skills.ps1 -Skill backend/fastapi   # sync specific skill
#   .\scripts\sync-skills.ps1 -List                    # list supported tools
#   .\scripts\sync-skills.ps1 -DryRun                  # preview without changes
#   .\scripts\sync-skills.ps1 -Unsync                  # remove all synced skills

[CmdletBinding()]
param(
    [string]$Tool = "",
    [string]$Skill = "",
    [switch]$All,
    [switch]$List,
    [switch]$DryRun,
    [switch]$Unsync,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$SkillsRoot = Join-Path $Root "skills"

# ============================================
# Agent tool config directory registry
# Maps tool name -> config path pattern
# Uses $HOME as base; resolved at runtime
# ============================================
$ToolRegistry = [ordered]@{
    # --- Tier 1: Primary Coding Agents ---
    "claude"      = @{ Name = "Claude Code";            Path = "~/.claude/skills";                  Global = $true }
    "cursor"      = @{ Name = "Cursor";                 Path = "~/.cursor/skills";                  Global = $true }
    "windsurf"    = @{ Name = "Windsurf";               Path = "~/.windsurf/skills";                Global = $true }
    "cline"       = @{ Name = "Cline / Roo Code";       Path = "~/.cline/skills";                   Global = $true }
    "copilot"     = @{ Name = "GitHub Copilot";         Path = "~/.copilot/skills";                 Global = $true }
    "aider"       = @{ Name = "Aider";                  Path = "~/.aider/skills";                   Global = $true }

    # --- Tier 2: Additional Agents ---
    "openhands"   = @{ Name = "OpenHands";              Path = "~/.openhands/skills";               Global = $true }
    "continue"    = @{ Name = "Continue.dev";           Path = "~/.continue/skills";                Global = $true }
    "zed"         = @{ Name = "Zed AI";                 Path = "~/.zed/skills";                     Global = $true }
    "gemini"      = @{ Name = "Gemini CLI";             Path = "~/.gemini/skills";                  Global = $true }
    "codex"       = @{ Name = "OpenAI Codex";           Path = "~/.codex/skills";                   Global = $true }
    "hermes"      = @{ Name = "Hermes Agent";           Path = "~/.hermes/skills";                  Global = $true }

    # --- Tier 3: IDE Extensions ---
    "vscode"      = @{ Name = "VS Code (Copilot)";     Path = "~/.vscode/skills";                  Global = $true }
    "jetbrains"   = @{ Name = "JetBrains AI";           Path = "~/.jetbrains/skills";               Global = $true }
    "neovim"      = @{ Name = "Neovim AI";              Path = "~/.config/nvim/skills";             Global = $true }

    # --- Tier 4: OpenCode Native ---
    "opencode"    = @{ Name = "OpenCode (native)";      Path = "~/.config/opencode/skills";         Global = $true }
}

function Get-SyncTargetPath {
    param(
        [string]$ToolName,
        [string]$SkillRelPath
    )
    $tool = $ToolRegistry[$ToolName]
    if (-not $tool) { return $null }

    $userProfile = [System.Environment]::GetFolderPath('UserProfile')
    $basePath = $tool.Path -replace '~', $userProfile
    return Join-Path $basePath $SkillRelPath
}

function Sync-OneSkill {
    param(
        [string]$SkillMdPath,
        [string]$ToolName,
        [bool]$DoDryRun,
        [bool]$DoUnsync
    )

    $normSkillsRoot = $SkillsRoot.TrimEnd('\', '/')
    $normPath = $SkillMdPath.TrimEnd('\', '/')
    if ($normPath.StartsWith($normSkillsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $normPath.Substring($normSkillsRoot.Length).TrimStart('\', '/').Replace('\', '/')
    } else {
        $rel = Split-Path $SkillMdPath -Leaf
    }
    $rel = $rel -replace '/SKILL\.md$', ''

    $target = Get-SyncTargetPath -ToolName $ToolName -SkillRelPath $rel
    if (-not $target) { return }

    if ($DoUnsync) {
        if (Test-Path $target) {
            if ($DoDryRun) {
                Write-Host "  [DRY-RUN] Would remove: $target" -ForegroundColor Yellow
            } else {
                Remove-Item -Recurse -Force $target -ErrorAction SilentlyContinue
                Write-Host "  [REMOVED] $target" -ForegroundColor Red
            }
        }
        return
    }

    $targetDir = Split-Path $target -Parent

    if ($DoDryRun) {
        if (!(Test-Path $target)) {
            Write-Host "  [DRY-RUN] Would create: $target" -ForegroundColor Yellow
        } else {
            Write-Host "  [DRY-RUN] Exists: $target" -ForegroundColor DarkGray
        }
        return
    }

    # Create target directory
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    # Try symlink first, fall back to copy
    if (Test-Path $target) {
        # Already exists — check if it's a symlink
        $item = Get-Item $target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # Symlink exists — update if source changed
            $srcHash = if (Test-Path $SkillMdPath) { (Get-FileHash $SkillMdPath).Hash } else { "" }
            $tgtHash = if (Test-Path $target) { (Get-FileHash $target).Hash } else { "" }
            if ($srcHash -ne $tgtHash) {
                Remove-Item $target -Force
                New-Item -ItemType SymbolicLink -Path $target -Target $SkillMdPath -Force | Out-Null
                Write-Host "  [UPDATED] $target -> $rel" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [EXISTS]  $target (not a symlink, use -Force to overwrite)" -ForegroundColor DarkGray
        }
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path $target -Target $SkillMdPath -Force | Out-Null
            Write-Host "  [LINKED]  $target -> $rel" -ForegroundColor Green
        } catch {
            # Fallback to copy if symlinks not supported
            Copy-Item -Path $SkillMdPath -Destination $target -Force
            Write-Host "  [COPIED]  $target (symlink unavailable)" -ForegroundColor DarkYellow
        }
    }
}

function Show-SupportedTools {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SUPPORTED AI TOOLS" -ForegroundColor Cyan
    Write-Host "  ($($ToolRegistry.Count) tools)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $i = 0
    foreach ($key in $ToolRegistry.Keys) {
        $i++
        $t = $ToolRegistry[$key]
        $exists = Test-Path ($t.Path -replace '~', $HOME)
        $status = if ($exists) { "[INSTALLED]" } else { "[NOT FOUND]" }
        $color = if ($exists) { "Green" } else { "DarkGray" }
        Write-Host ("  {0,-3} {1,-28} {2,-30} {3}" -f $i, $key, $t.Name, $status) -ForegroundColor $color
    }
    Write-Host ""
    Write-Host "  Total: $($ToolRegistry.Count) tools supported" -ForegroundColor Gray
    Write-Host ""
}

# ============================================
# Main
# ============================================

if ($List) {
    Show-SupportedTools
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GOD-OPENCODE SKILL SYNC" -ForegroundColor Cyan
Write-Host "  Cross-Agent Distribution Engine" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Determine which tools to sync to
$targetTools = @()
if ($Tool) {
    if ($Tool -eq "all") {
        $targetTools = @()
        foreach ($key in $ToolRegistry.Keys) { $targetTools += $key }
    } elseif ($ToolRegistry.Contains($Tool)) {
        $targetTools = @($Tool)
    } else {
        Write-Host "[ERR] Unknown tool: $Tool" -ForegroundColor Red
        Write-Host "  Use -List to see supported tools" -ForegroundColor DarkGray
        exit 1
    }
} else {
    # Default: sync to OpenCode (our native target)
    $targetTools = @("opencode")
}

# Determine which skills to sync
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

Write-Host "  Tools:   $($targetTools -join ', ')" -ForegroundColor Gray
Write-Host "  Skills:  $($skillFiles.Count) skill(s)" -ForegroundColor Gray
if ($DryRun) { Write-Host "  Mode:    DRY RUN (no changes)" -ForegroundColor Yellow }
if ($Unsync) { Write-Host "  Mode:    UNSYNC (remove symlinks)" -ForegroundColor Red }
Write-Host ""

$linked = 0
$failed = 0

foreach ($sf in $skillFiles) {
    foreach ($t in $targetTools) {
        try {
            Sync-OneSkill -SkillMdPath $sf.FullName -ToolName $t -DoDryRun $DryRun -DoUnsync $Unsync
            $linked++
        } catch {
            Write-Host "  [ERR] $($_.Exception.Message)" -ForegroundColor Red
            $failed++
        }
    }
}

Write-Host ""
Write-Host "[OK] Sync complete: $linked operations, $failed failures" -ForegroundColor Green

if (-not $DryRun -and -not $Unsync) {
    Write-Host ""
    Write-Host "  Skills are now available in:" -ForegroundColor Magenta
    foreach ($t in $targetTools) {
        $tool = $ToolRegistry[$t]
        $p = $tool.Path -replace '~', $HOME
        Write-Host "    $($tool.Name): $p" -ForegroundColor Cyan
    }
}
Write-Host ""
