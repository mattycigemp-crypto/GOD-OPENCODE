# ============================================
# GOD-OPENCODE SKILL FRAGMENT LOADER
# Version 1.0 (MVP)
# ============================================
# Dynamic context pruning for SKILL.md: given a query, returns the
# top matching SKILL.md files plus their matching ## section
# headers, ranked by token overlap.
#
# Usage:
#   .\scripts\skill-fragment.ps1 -Query "authentication jwt"
#   .\scripts\skill-fragment.ps1 -Query "kubernetes ingress" -Top 10
#   .\scripts\skill-fragment.ps1 -Query "fastapi async" -SkillsRoot <path>
#
# Pipeline (suggested for agents):
#   $hits = .\scripts\skill-fragment.ps1 -Query "user request"
#   For each hit, load only the headings the user actually needs.

param(
    [Parameter(Mandatory=$true)][string]$Query,
    [string]$SkillsRoot = (Join-Path (Split-Path $PSScriptRoot -Parent) "skills"),
    [int]$Top = 5
)

$ErrorActionPreference = "Stop"

if (!(Test-Path $SkillsRoot)) {
    Write-Host "[skill-fragment] skills root not found: $SkillsRoot" -ForegroundColor Red
    exit 1
}

# Tokenize: lowercase, split on non-word, drop short tokens (>=3) and common english stop words
$Stop = @("the","and","for","with","from","into","that","this","have","has","are","was","were","you","your","our","their","his","her","its","but","not")
$TQ = @(
    ($Query.ToLower() -split '[^\w]+') |
    Where-Object { $_ -and $_.Length -ge 3 -and ($Stop -notcontains $_) }
)
# De-dup
$TQ = $TQ | Select-Object -Unique

if ($TQ.Count -eq 0) {
    Write-Host "[skill-fragment] no usable tokens in query: $Query"
    exit 1
}

$HeaderRegex = [regex]::new('(?m)^##\s+(.+)')
$BodyRegex   = [regex]::new('(?m)^###\s+(.+)')
$Hits = @()

$Skills = Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue

foreach ($Skill in $Skills) {
    $rel = $Skill.FullName.Substring($SkillsRoot.Length).TrimStart('\', '/')
    $content = Get-Content $Skill.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $SkillHits = @()
    foreach ($m in $HeaderRegex.Matches($content)) {
        $heading = $m.Groups[1].Value.Trim()
        # Score = number of query tokens appearing in heading OR within first 200 chars after it
        $slice   = $content.Substring($m.Index, [Math]::Min(400, $content.Length - $m.Index))
        $score = ($TQ | Where-Object { $slice.ToLower().Contains("$_") }).Count
        if ($score -gt 0) {
            $SkillHits += [pscustomobject]@{ heading = $heading ; score = $score }
        }
    }

    if ($SkillHits.Count -gt 0) {
        $Hits += [pscustomobject]@{
            skill  = $rel
            score  = ($SkillHits | Measure-Object -Property score -Sum).Sum
            topics = $SkillHits | Sort-Object score -Descending
        }
    }
}

$Hits |
  Sort-Object score -Descending |
  Select-Object -First $Top
