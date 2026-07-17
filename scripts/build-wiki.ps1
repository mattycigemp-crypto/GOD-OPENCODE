# ============================================
# GOD-OPENCODE WIKI AUTO-BUILDER
# Version 1.0
# ============================================
# Generates comprehensive wiki pages from skill, agent, and workflow content.
# Outputs to docs/wiki/ with proper mkdocs-material structure.
#
# Usage:
#   .\scripts\build-wiki.ps1                    # build all wiki pages
#   .\scripts\build-wiki.ps1 -SkillsOnly        # rebuild skills reference only
#   .\scripts\build-wiki.ps1 -AgentsOnly        # rebuild agents reference only
#   .\scripts\build-wiki.ps1 -WorkflowsOnly     # rebuild workflows reference only
#   .\scripts\build-wiki.ps1 -Quiet             # suppress output

param(
    [switch]$SkillsOnly,
    [switch]$AgentsOnly,
    [switch]$WorkflowsOnly,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent
$WikiDir = Join-Path $Root "docs/wiki"
$SkillsDir = Join-Path $Root "skills"
$AgentsDir = Join-Path $Root "agents"
$WorkflowsDir = Join-Path $Root "workflows"
$DataDir = Join-Path $WikiDir "_data"

function Log {
    param([string]$Msg)
    if (-not $Quiet) { Write-Host "[build-wiki] $Msg" }
}

function Ensure-Dir {
    param([string]$Dir)
    if (!(Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
}

function Get-SectionBody {
    param(
        [string]$Content,
        [string]$Header
    )
    $escaped = [regex]::Escape($Header)
    $pattern = "(?ms)^##\\s+$escaped\\s*$\r?\n(.+?)(?=^##\\s|\z)"
    $m = [regex]::Match($Content, $pattern)
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return ""
}

function Get-Frontmatter {
    param([string]$Content)
    $m = [regex]::Match($Content, '(?s)^---\r?\n(.*?)\r?\n---')
    if ($m.Success) {
        $fm = @{}
        foreach ($line in ($m.Groups[1].Value -split '\r?\n')) {
            if ($line -match '^(\w+):\s*(.+)') {
                $fm[$Matches[1]] = $Matches[2].Trim()
            }
        }
        return $fm
    }
    return @{}
}

# ============================================
# Skills Reference Page
# ============================================

function Build-SkillsPage {
    Log "Building skills reference..."

    $skills = @()
    Get-ChildItem -Path $SkillsDir -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return }

        $fm = Get-Frontmatter -Content $content
        $rel = $_.FullName.Substring($SkillsDir.Length).TrimStart('\', '/')
        $category = ($rel -split '/')[0]
        $name = if ($fm.name) { $fm.name } else { ($rel -split '/')[-2] }
        $desc = if ($fm.description) { $fm.description } else { "" }

        # Extract key sections
        $mission = Get-SectionBody -Content $content -Header "Mission"
        $responsibilities = Get-SectionBody -Content $content -Header "Core Responsibilities"

        $skills += [pscustomobject]@{
            Category = $category
            Name = $name
            Description = $desc
            Mission = $mission
            Responsibilities = $responsibilities
            Path = $rel
        }
    }

    $skills = $skills | Sort-Object Category, Name

    # Group by category
    $grouped = $skills | Group-Object Category

    $md = @"
# Skills Reference

_Auto-generated from skills/ by build-wiki.ps1. Do not edit manually._

## Overview

| Metric | Value |
|--------|-------|
| Total Skills | $($skills.Count) |
| Categories | $($grouped.Count) |
| Last Updated | $(Get-Date -Format 'yyyy-MM-dd HH:mm') |

---

## Categories

"@

    foreach ($cat in $grouped) {
        $md += "`n### $($cat.Name) ($($cat.Count))`n`n"
        $md += "| Skill | Description |`n"
        $md += "|-------|-------------|`n"

        foreach ($skill in ($cat.Group | Sort-Object Name)) {
            $shortDesc = if ($skill.Description.Length -gt 80) { $skill.Description.Substring(0, 77) + "..." } else { $skill.Description }
            $md += "| **$($skill.Name)** | $shortDesc |`n"
        }
    }

    $md += "`n---`n`n## Detailed Skill Pages`n`n"

    foreach ($skill in $skills) {
        $md += "### $($skill.Name)`n`n"
        $md += "- **Category:** $($skill.Category)`n"
        $md += "- **Path:** ``$($skill.Path)```n"
        if ($skill.Description) {
            $md += "- **Description:** $($skill.Description)`n"
        }
        $md += "`n"

        if ($skill.Mission) {
            $md += "**Mission:**`n`n$($skill.Mission)`n`n"
        }
        if ($skill.Responsibilities) {
            $md += "**Core Responsibilities:**`n`n$($skill.Responsibilities)`n`n"
        }

        $md += "---`n`n"
    }

    $outPath = Join-Path $WikiDir "skills-reference.md"
    [System.IO.File]::WriteAllText($outPath, $md)
    Log "Wrote $outPath ($($skills.Count) skills)"
}

# ============================================
# Agents Reference Page
# ============================================

function Build-AgentsPage {
    Log "Building agents reference..."

    $agents = @()
    Get-ChildItem -Path $AgentsDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $agentFile = Join-Path $_.FullName "AGENT.md"
        if (!(Test-Path $agentFile)) { return }

        $content = Get-Content $agentFile -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return }

        $name = $_.Name
        $role = Get-SectionBody -Content $content -Header "Role"
        $responsibilities = Get-SectionBody -Content $content -Header "Responsibilities"
        $standards = Get-SectionBody -Content $content -Header "Standards"
        $skillsSection = Get-SectionBody -Content $content -Header "Skills"

        $agents += [pscustomobject]@{
            Name = $name
            Role = $role
            Responsibilities = $responsibilities
            Standards = $standards
            Skills = $skillsSection
            Path = "agents/$name/AGENT.md"
        }
    }

    $agents = $agents | Sort-Object Name

    $md = @"
# Agents Reference

_Auto-generated from agents/ by build-wiki.ps1. Do not edit manually._

## Overview

| Metric | Value |
|--------|-------|
| Total Agents | $($agents.Count) |
| Last Updated | $(Get-Date -Format 'yyyy-MM-dd HH:mm') |

---

## Agent Profiles

"@

    foreach ($agent in $agents) {
        $md += "### $($agent.Name)`n`n"
        if ($agent.Role) {
            $md += "**Role:**`n`n$($agent.Role)`n`n"
        }
        if ($agent.Responsibilities) {
            $md += "**Responsibilities:**`n`n$($agent.Responsibilities)`n`n"
        }
        if ($agent.Standards) {
            $md += "**Standards:**`n`n$($agent.Standards)`n`n"
        }
        if ($agent.Skills) {
            $md += "**Skills:**`n`n$($agent.Skills)`n`n"
        }
        $md += "---`n`n"
    }

    $outPath = Join-Path $WikiDir "agents-reference.md"
    [System.IO.File]::WriteAllText($outPath, $md)
    Log "Wrote $outPath ($($agents.Count) agents)"
}

# ============================================
# Workflows Reference Page
# ============================================

function Build-WorkflowsPage {
    Log "Building workflows reference..."

    $workflows = @()
    Get-ChildItem -Path $WorkflowsDir -Filter "*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { return }

        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $purpose = Get-SectionBody -Content $content -Header "Purpose"
        $params = Get-SectionBody -Content $content -Header "Parameters"

        # Extract steps
        $stepPattern = [regex]::new('(?m)^### Step (\d+):?\s*(.+)')
        $steps = @()
        foreach ($m in $stepPattern.Matches($content)) {
            $steps += [pscustomobject]@{
                Number = [int]$m.Groups[1].Value
                Title = $m.Groups[2].Value.Trim()
            }
        }

        $workflows += [pscustomobject]@{
            Name = $name
            Purpose = $purpose
            Parameters = $params
            StepCount = $steps.Count
            Steps = $steps
            Path = "workflows/$($_.Name)"
        }
    }

    $workflows = $workflows | Sort-Object Name

    $md = @"
# Workflows Reference

_Auto-generated from workflows/ by build-wiki.ps1. Do not edit manually._

## Overview

| Metric | Value |
|--------|-------|
| Total Workflows | $($workflows.Count) |
| Last Updated | $((Get-Date).ToString('yyyy-MM-dd HH:mm')) |

---

## Workflow Catalog

| Workflow | Purpose | Steps |
|----------|---------|-------|
"@

    foreach ($wf in $workflows) {
        $shortPurpose = if ($wf.Purpose.Length -gt 60) { $wf.Purpose.Substring(0, 57) + "..." } else { $wf.Purpose }
        $md += "| **$($wf.Name)** | $shortPurpose | $($wf.StepCount) |`n"
    }

    $md += "`n---`n`n## Detailed Workflows`n`n"

    foreach ($wf in $workflows) {
        $md += "### $($wf.Name)`n`n"
        if ($wf.Purpose) {
            $md += "**Purpose:**`n`n$($wf.Purpose)`n`n"
        }
        if ($wf.Parameters) {
            $md += "**Parameters:**`n`n$($wf.Parameters)`n`n"
        }
        if ($wf.Steps.Count -gt 0) {
            $md += "**Steps ($($wf.StepCount)):**`n`n"
            foreach ($step in $wf.Steps) {
                $md += "$($step.Number). $($step.Title)`n"
            }
            $md += "`n"
        }
        $md += "---`n`n"
    }

    $outPath = Join-Path $WikiDir "workflows-reference.md"
    [System.IO.File]::WriteAllText($outPath, $md)
    Log "Wrote $outPath ($($workflows.Count) workflows)"
}

# ============================================
# Main
# ============================================

Ensure-Dir -Dir $WikiDir
Ensure-Dir -Dir $DataDir

$buildAll = -not ($SkillsOnly -or $AgentsOnly -or $WorkflowsOnly)

if ($buildAll -or $SkillsOnly) { Build-SkillsPage }
if ($buildAll -or $AgentsOnly) { Build-AgentsPage }
if ($buildAll -or $WorkflowsOnly) { Build-WorkflowsPage }

Log "Wiki build complete"
