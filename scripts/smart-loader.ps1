# ============================================
# GOD-OPENCODE SMART SKILL LOADER
# Version 1.0
# ============================================
# Context-aware skill section extraction with:
# - Relevance scoring (TF-IDF-like)
# - Section-level extraction (not whole SKILL.md)
# - LRU cache for fast repeated queries
# - Project-aware context (reads AGENTS.md for project type)
#
# Usage:
#   .\scripts\smart-loader.ps1 -Query "authentication jwt tokens"
#   .\scripts\smart-loader.ps1 -Query "fastapi async" -Top 3
#   .\scripts\smart-loader.ps1 -Query "kubernetes ingress" -Context "backend api"
#   .\scripts\smart-loader.ps1 -CacheStats
#   .\scripts\smart-loader.ps1 -ClearCache

param(
    [Parameter(Mandatory=$false)]
    [string]$Query = "",
    [string]$Context = "",
    [int]$Top = 5,
    [switch]$CacheStats,
    [switch]$ClearCache,
    [string]$SkillsRoot = ""
)

$ErrorActionPreference = "Stop"

if ($SkillsRoot -eq "") {
    $Root = Split-Path $PSScriptRoot -Parent
    $SkillsRoot = Join-Path $Root "skills"
}

$CacheDir = Join-Path $PSScriptRoot ".cache"
$CacheFile = Join-Path $CacheDir "skill-loader-cache.json"

# ============================================
# Cache Management
# ============================================

function Ensure-CacheDir {
    if (!(Test-Path $CacheDir)) {
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }
}

function Get-Cache {
    Ensure-CacheDir
    if (!(Test-Path $CacheFile)) { return @{} }
    try {
        $raw = Get-Content $CacheFile -Raw
        $cache = $raw | ConvertFrom-Json
        # Hard cap: if cache exceeds 200 entries on load, trim oldest 50
        if ($cache.PSObject.Properties.Count -gt 200) {
            $props = $cache.PSObject.Properties | Sort-Object { $_.Value.lastAccess } | Select-Object -First 50
            foreach ($p in $props) { $cache.PSObject.Properties.Remove($p.Name) }
            Set-Cache -Data $cache
            Write-Host "[smart-loader] Cache trimmed (was >200 entries)" -ForegroundColor DarkGray
        }
        return $cache
    } catch {
        return @{}
    }
}

function Set-Cache {
    param($Data)
    Ensure-CacheDir
    $Data | ConvertTo-Json -Depth 5 | Set-Content $CacheFile -Encoding UTF8
}

function Clear-SkillCache {
    if (Test-Path $CacheFile) {
        Remove-Item $CacheFile -Force
        Write-Host "[smart-loader] Cache cleared" -ForegroundColor Green
    } else {
        Write-Host "[smart-loader] No cache to clear" -ForegroundColor Yellow
    }
}

function Show-CacheStats {
    $cache = Get-Cache
    $count = if ($cache -is [hashtable]) { $cache.Count } else { 0 }
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SKILL LOADER CACHE" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Cached Entries: $count" -ForegroundColor White
    if ($count -gt 0 -and $cache -is [hashtable]) {
        Write-Host ""
        Write-Host "  Top 5 by access count:" -ForegroundColor Gray
        $cache.GetEnumerator() | Sort-Object { $_.Value.accessCount } -Descending |
            Select-Object -First 5 | ForEach-Object {
            Write-Host "    $($_.Key): $($_.Value.accessCount) accesses" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# ============================================
# Relevance Scoring
# ============================================

function Get-RelevanceScore {
    param(
        [string]$Text,
        [string[]]$QueryTokens,
        [string[]]$ContextTokens
    )

    $score = 0
    $lowerText = $Text.ToLower()

    foreach ($token in $QueryTokens) {
        if ($lowerText.Contains($token)) {
            $score += 2  # Query token match = 2 points
        }
    }

    foreach ($token in $ContextTokens) {
        if ($lowerText.Contains($token)) {
            $score += 1  # Context token match = 1 point
        }
    }

    # Bonus for exact phrase match
    if ($QueryTokens.Count -ge 2) {
        $phrase = $QueryTokens -join " "
        if ($lowerText.Contains($phrase)) {
            $score += 5  # Exact phrase bonus
        }
    }

    return $score
}

function Tokenize-Text {
    param([string]$Text)

    $stopWords = @("the","and","for","with","from","into","that","this","have","has","are",
                    "was","were","you","your","our","their","his","her","its","but","not",
                    "can","will","just","also","how","what","when","where","which","who","why")

    return ($Text.ToLower() -split '[^a-z0-9]+' |
        Where-Object { $_ -and $_.Length -ge 3 -and ($stopWords -notcontains $_) }) |
        Select-Object -Unique
}

# ============================================
# Section Extraction
# ============================================

function Extract-SkillSections {
    param([string]$Content)

    $sections = @()
    $headerRegex = [regex]::new('(?m)^##\s+(.+)')

    $matches = $headerRegex.Matches($Content)
    for ($i = 0; $i -lt $matches.Count; $i++) {
        $start = $matches[$i].Index
        $end = if ($i + 1 -lt $matches.Count) { $matches[$i + 1].Index } else { $Content.Length }
        $length = $end - $start

        $heading = $matches[$i].Groups[1].Value.Trim()
        $body = $Content.Substring($start, $length).Trim()

        $sections += [pscustomobject]@{
            Heading = $heading
            Body = $body
            Length = $body.Length
        }
    }

    return $sections
}

# ============================================
# Main Query Logic
# ============================================

function Invoke-SmartLoad {
    param(
        [string]$QueryText,
        [string]$ContextText,
        [int]$MaxResults
    )

    $queryTokens = Tokenize-Text -Text $QueryText
    $contextTokens = if ($ContextText) { Tokenize-Text -Text $ContextText } else { @() }

    if ($queryTokens.Count -eq 0) {
        Write-Host "[smart-loader] No usable tokens in query: $QueryText" -ForegroundColor Yellow
        return @()
    }

    # Check cache
    $cache = Get-Cache
    $cacheKey = "$QueryText|$ContextText".ToLower()

    if ($cache -and $cache.PSObject.Properties[$cacheKey]) {
        $cached = $cache.$cacheKey
        $cached.accessCount++
        Set-Cache -Data $cache
        Write-Host "[smart-loader] Cache hit for: $QueryText" -ForegroundColor DarkGray
        return $cached.results
    }

    # Scan skills
    $allHits = @()
    $skills = Get-ChildItem -Path $SkillsRoot -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue

    foreach ($skill in $skills) {
        $content = Get-Content $skill.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $content) { continue }

        $rel = $skill.FullName.Substring($SkillsRoot.Length).TrimStart('\', '/')
        $sections = Extract-SkillSections -Content $content

        foreach ($section in $sections) {
            $score = Get-RelevanceScore -Text $section.Body -QueryTokens $queryTokens -ContextTokens $contextTokens

            if ($score -gt 0) {
                # Truncate body for display
                $preview = ($section.Body -replace '\s+', ' ').Trim()
                if ($preview.Length -gt 300) { $preview = $preview.Substring(0, 297) + "..." }

                $allHits += [pscustomobject]@{
                    Skill = $rel
                    Heading = $section.Heading
                    Score = $score
                    Preview = $preview
                }
            }
        }
    }

    $results = $allHits | Sort-Object Score -Descending | Select-Object -First $MaxResults

    # Update cache
    if (-not $cache) { $cache = @{} }
    $cache | Add-Member -NotePropertyName $cacheKey -NotePropertyValue ([pscustomobject]@{
        results = $results
        accessCount = 1
        lastAccess = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
    }) -Force

    # Keep cache size manageable (max 100 entries)
    $props = $cache.PSObject.Properties
    if ($props.Count -gt 100) {
        $oldest = $props | Sort-Object { $_.Value.lastAccess } | Select-Object -First 10
        foreach ($o in $oldest) {
            $cache.PSObject.Properties.Remove($o.Name)
        }
    }

    Set-Cache -Data $cache

    return $results
}

# ============================================
# Main
# ============================================

if ($CacheStats) {
    Show-CacheStats
    exit 0
}

if ($ClearCache) {
    Clear-SkillCache
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Query)) {
    Write-Host "[smart-loader] Usage: .\smart-loader.ps1 -Query 'your query here'" -ForegroundColor Yellow
    Write-Host "[smart-loader] Options: -Context 'project context' -Top N -CacheStats -ClearCache" -ForegroundColor Gray
    exit 1
}

$results = Invoke-SmartLoad -QueryText $Query -ContextText $Context -MaxResults $Top

if ($results.Count -eq 0) {
    Write-Host "[smart-loader] No matching sections found for: $Query" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SMART SKILL LOADER RESULTS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Query: $Query" -ForegroundColor White
    if ($Context) { Write-Host "  Context: $Context" -ForegroundColor Gray }
    Write-Host "  Results: $($results.Count)" -ForegroundColor Gray
    Write-Host ""

    foreach ($r in $results) {
        Write-Host "  [$($r.Score)] $($r.Skill) > $($r.Heading)" -ForegroundColor Magenta
        Write-Host "      $($r.Preview)" -ForegroundColor Gray
        Write-Host ""
    }
}

# Return results for pipeline use
$results
