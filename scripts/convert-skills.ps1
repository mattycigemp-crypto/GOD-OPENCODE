# ============================================
# GOD-OPENCODE SKILL CONVERTER
# Cross-Tool Portability Engine
# ============================================
# Converts SKILL.md files into agent-native config formats:
#   - .cursorrules   (Cursor / Windsurf / Aider)
#   - CLAUDE.md      (Claude Code)
#   - .clinerules    (Cline / Roo Code)
#   - .windsurfrules (Windsurf standalone)
#   - .github/copilot-instructions.md (GitHub Copilot)
#
# Usage:
#   .\scripts\convert-skills.ps1 -Skill backend/fastapi
#   .\scripts\convert-skills.ps1 -Skill backend/fastapi -Format cursorrules
#   .\scripts\convert-skills.ps1 -AllSkills -OutDir dist/converted
#   .\scripts\convert-skills.ps1 -AllSkills -Formats cursorrules,claude,cline
#   .\scripts\convert-skills.ps1 -AllSkills -OutDir dist/converted -Agent backend-engineer

[CmdletBinding()]
param(
    [string]$Skill,
    [string]$OutDir,
    [string]$Format = "",
    [string[]]$Formats = @(),
    [switch]$AllSkills,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
$SkillsRoot = Join-Path $Root "skills"

# ============================================
# Supported output formats
# ============================================
$SupportedFormats = @(
    "cursorrules",   # .cursorrules (Cursor / Windsurf / Aider)
    "claude",        # CLAUDE.md (Claude Code)
    "cline",         # .clinerules (Cline / Roo Code)
    "windsurf",      # .windsurfrules (Windsurf standalone)
    "copilot"        # .github/copilot-instructions.md (GitHub Copilot)
)

function Parse-SkillMd {
    param([string]$Path)

    $raw = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw) { return $null }

    $result = [pscustomobject]@{
        Name        = ""
        Description = ""
        Body        = ""
        FullContent = $raw
    }

    # Parse YAML frontmatter
    $fmPattern = '(?s)^---\r?\n(.+?)\r?\n---'
    $fmMatch = [regex]::Match($raw, $fmPattern)
    if ($fmMatch.Success) {
        $fmBody = $fmMatch.Groups[1].Value
        $nameMatch = [regex]::Match($fmBody, '(?m)^name:\s*(.+)$')
        $descMatch = [regex]::Match($fmBody, '(?m)^description:\s*(.+)$')
        if ($nameMatch.Success)   { $result.Name = $nameMatch.Groups[1].Value.Trim() }
        if ($descMatch.Success)   { $result.Description = $descMatch.Groups[1].Value.Trim() }
        $result.Body = $raw.Substring($fmMatch.Index + $fmMatch.Length).Trim()
    } else {
        $result.Body = $raw
        $h1Match = [regex]::Match($raw, '(?m)^#\s+(.+)$')
        if ($h1Match.Success) { $result.Name = $h1Match.Groups[1].Value.Trim() }
    }

    return $result
}

# ============================================
# Format generators
# ============================================

function ConvertTo-CursorRules {
    param([pscustomobject]$Skill, [string]$SkillPath)

    $lines = @()
    $lines += "---"
    $lines += "description: $($Skill.Description)"
    $lines += "globs: *"
    $lines += "alwaysApply: false"
    $lines += "source: god-opencode/skills/$SkillPath"
    $lines += "format: cursorrules"
    $lines += "---"
    $lines += ""
    $lines += "# $($Skill.Name) (GOD-OPENCODE Skill)"
    $lines += ""
    $lines += $Skill.Body

    return ($lines -join "`n")
}

function ConvertTo-ClaudeMd {
    param([pscustomobject]$Skill, [string]$SkillPath)

    $lines = @()
    $lines += "# $($Skill.Name) - GOD-OPENCODE Skill"
    $lines += ""
    if ($Skill.Description) {
        $lines += "> $($Skill.Description)"
        $lines += ""
    }
    $lines += "Source: god-opencode/skills/$SkillPath"
    $lines += ""
    $lines += "---"
    $lines += ""
    $lines += $Skill.Body

    return ($lines -join "`n")
}

function ConvertTo-ClineRules {
    param([pscustomobject]$Skill, [string]$SkillPath)

    $lines = @()
    $lines += "# $($Skill.Name)"
    $lines += "# GOD-OPENCODE Skill for Cline / Roo Code"
    $lines += "# Source: god-opencode/skills/$SkillPath"
    $lines += ""
    if ($Skill.Description) {
        $lines += "# Description: $($Skill.Description)"
        $lines += ""
    }
    $lines += $Skill.Body

    return ($lines -join "`n")
}

function ConvertTo-WindsurfRules {
    param([pscustomobject]$Skill, [string]$SkillPath)

    $lines = @()
    $lines += "# Windsurf Rule: $($Skill.Name)"
    $lines += "# GOD-OPENCODE Skill"
    $lines += "# Source: god-opencode/skills/$SkillPath"
    $lines += ""
    if ($Skill.Description) {
        $lines += "description: $($Skill.Description)"
        $lines += ""
    }
    $lines += $Skill.Body

    return ($lines -join "`n")
}

function ConvertTo-CopilotInstructions {
    param([pscustomobject]$Skill, [string]$SkillPath)

    $lines = @()
    $lines += "# $($Skill.Name) - GitHub Copilot Instructions"
    $lines += ""
    $lines += "These instructions are provided by the GOD-OPENCODE skill: $SkillPath"
    $lines += ""
    if ($Skill.Description) {
        $lines += "**Purpose:** $($Skill.Description)"
        $lines += ""
    }
    $lines += "---"
    $lines += ""
    $lines += $Skill.Body

    return ($lines -join "`n")
}

function Get-OutputFileName {
    param(
        [string]$SkillName,
        [string]$Format
    )
    # Sanitize skill name for filesystem safety
    $safe = $SkillName -replace '[/\\:*?"<>|]', '-' -replace '--+', '-'
    switch ($Format) {
        "cursorrules" { return "$safe.cursorrules" }
        "claude"      { return "CLAUDE.$safe.md" }
        "cline"       { return ".clinerules.$safe" }
        "windsurf"    { return ".windsurfrules.$safe" }
        "copilot"     { return "copilot-instructions.$safe.md" }
        default       { return "$safe.$Format" }
    }
}

function Convert-OneSkill {
    param(
        [string]$SkillMdPath,
        [string]$SkillPath,
        [string[]]$Formats,
        [string]$TargetDir
    )

    $parsed = Parse-SkillMd -Path $SkillMdPath
    if (-not $parsed) {
        Write-Host "  [SKIP] Could not parse $SkillMdPath" -ForegroundColor Yellow
        return
    }

    $skillName = if ($parsed.Name) { $parsed.Name } else { Split-Path $SkillPath -Leaf }

    foreach ($fmt in $Formats) {
        $content = switch ($fmt) {
            "cursorrules" { ConvertTo-CursorRules -Skill $parsed -SkillPath $SkillPath }
            "claude"      { ConvertTo-ClaudeMd -Skill $parsed -SkillPath $SkillPath }
            "cline"       { ConvertTo-ClineRules -Skill $parsed -SkillPath $SkillPath }
            "windsurf"    { ConvertTo-WindsurfRules -Skill $parsed -SkillPath $SkillPath }
            "copilot"     { ConvertTo-CopilotInstructions -Skill $parsed -SkillPath $SkillPath }
        }

        $outFile = Get-OutputFileName -SkillName $skillName -Format $fmt
        $outPath = Join-Path $TargetDir $outFile

        if ($DryRun) {
            Write-Host "  [DRY-RUN] Would write: $outPath" -ForegroundColor Yellow
        } else {
            Write-IfChanged -Path $outPath -Content $content
        }
    }
}

# ============================================
# Resolve formats
# ============================================
$targetFormats = @()
if ($Formats -and $Formats.Count -gt 0) {
    foreach ($f in $Formats) {
        $targetFormats += $f.Trim().ToLower()
    }
    $targetFormats = $targetFormats | Where-Object { $_ }
} elseif ($Format) {
    $targetFormats = @($Format.ToLower())
} else {
    $targetFormats = $SupportedFormats
}

# Validate formats
foreach ($f in $targetFormats) {
    if ($f -notin $SupportedFormats) {
        Write-Host "[ERR] Unknown format: $f" -ForegroundColor Red
        Write-Host "  Supported: $($SupportedFormats -join ', ')" -ForegroundColor DarkGray
        exit 1
    }
}

# ============================================
# Main logic
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GOD-OPENCODE SKILL CONVERTER" -ForegroundColor Cyan
Write-Host "  Cross-Tool Portability Engine" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Formats: $($targetFormats -join ', ')" -ForegroundColor Gray
Write-Host ""

if (-not $Skill -and -not $AllSkills) {
    Write-Host "[ERR] Provide -Skill <category/name> or -AllSkills." -ForegroundColor Red
    Write-Host "  Example: .\convert-skills.ps1 -Skill backend/fastapi" -ForegroundColor DarkGray
    Write-Host "  Example: .\convert-skills.ps1 -AllSkills -OutDir dist/converted" -ForegroundColor DarkGray
    Write-Host "  Example: .\convert-skills.ps1 -AllSkills -Formats cursorrules,claude" -ForegroundColor DarkGray
    exit 1
}

if ($AllSkills) {
    $targetDir = if ($OutDir) { $OutDir } else { Join-Path $Root "dist\converted" }

    if (-not $DryRun -and !(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    $skillFiles = Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -File
    $count = 0
    $converted = 0

    foreach ($sf in $skillFiles) {
        $count++
        $rel = $sf.FullName.Substring($SkillsRoot.Length).TrimStart('\', '/').Replace('\', '/').Replace('/SKILL.md', '')
        Write-Host "[$count] Converting: $rel" -ForegroundColor White
        Convert-OneSkill -SkillMdPath $sf.FullName -SkillPath $rel -Formats $targetFormats -TargetDir $targetDir
        $converted++
    }

    Write-Host ""
    Write-Host "[OK] Converted $converted skills into $targetDir" -ForegroundColor Green
    Write-Host "  Formats: $($targetFormats -join ', ')" -ForegroundColor DarkGray

    # Generate an AGENTS.md universal file
    if (-not $DryRun) {
        $agentsMd = @()
        $agentsMd += "# GOD-OPENCODE Skills - Universal Agent Instructions"
        $agentsMd += ""
        $agentsMd += "These skills are auto-converted from the GOD-OPENCODE skill library."
        $agentsMd += "Source: https://github.com/mattycigemp-crypto/GOD-OPENCODE"
        $agentsMd += ""
        $agentsMd += "## Available Skills"
        $agentsMd += ""

        foreach ($sf in $skillFiles) {
            $rel = $sf.FullName.Substring($SkillsRoot.Length).TrimStart('\', '/').Replace('\', '/').Replace('/SKILL.md', '')
            $parsed = Parse-SkillMd -Path $sf.FullName
            $desc = if ($parsed -and $parsed.Description) { $parsed.Description } else { "GOD-OPENCODE skill" }
            $agentsMd += "- **$rel** - $desc"
        }

        $agentsMd += ""
        $agentsMd += "---"
        $agentsMd += "*Auto-generated by scripts/convert-skills.ps1. Do not hand-edit.*"
        $agentsMdPath = Join-Path $targetDir "AGENTS.md"
        Write-IfChanged -Path $agentsMdPath -Content ($agentsMd -join "`n")
    }

    Write-Host ""
    Write-Host "  Drop-in usage:" -ForegroundColor Magenta
    Write-Host "    Cursor:     cp dist/converted/<skill>.cursorrules <project>/.cursorrules" -ForegroundColor Cyan
    Write-Host "    Claude:     cp dist/converted/CLAUDE.<skill>.md <project>/CLAUDE.md" -ForegroundColor Cyan
    Write-Host "    Cline:      cp dist/converted/.clinerules.<skill> <project>/.clinerules" -ForegroundColor Cyan
    Write-Host "    Windsurf:   cp dist/converted/.windsurfrules.<skill> <project>/.windsurfrules" -ForegroundColor Cyan
    Write-Host "    Copilot:    cp dist/converted/copilot-instructions.<skill>.md <project>/.github/copilot-instructions.md" -ForegroundColor Cyan
    Write-Host "    Universal:  cp dist/converted/AGENTS.md <project>/AGENTS.md" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# Single skill conversion
$skillMd = Join-Path $SkillsRoot "$Skill\SKILL.md"
if (!(Test-Path $skillMd)) {
    Write-Host "[ERR] SKILL.md not found at: $skillMd" -ForegroundColor Red
    exit 1
}

$targetDir = if ($OutDir) { $OutDir } else { Join-Path $Root "dist\converted" }
if (-not $DryRun -and !(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Write-Host "Converting: $Skill" -ForegroundColor White
Convert-OneSkill -SkillMdPath $skillMd -SkillPath $Skill -Formats $targetFormats -TargetDir $targetDir

Write-Host ""
Write-Host "[OK] Skill converted to $($targetFormats.Count) format(s) in $targetDir" -ForegroundColor Green
Write-Host ""
