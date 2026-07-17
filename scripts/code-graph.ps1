# ============================================
# GOD-OPENCODE CODE GRAPH BUILDER
# Version 2.0 (Enhanced)
# ============================================
# Walks the repo, extracts function definitions + invocations across
# multiple languages (PowerShell, Python, JavaScript/TypeScript, Go, Rust),
# emits JSON graph to docs/wiki/_data/code-graph.json.
#
# Usage:
#   .\scripts\code-graph.ps1                    # default root
#   .\scripts\code-graph.ps1 -RepoRoot <path>
#   .\scripts\code-graph.ps1 -Quiet             # no console output
#   .\scripts\code-graph.ps1 -Languages ps1,py  # specific languages only

param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$OutFile  = "",
    [string]$Languages = "ps1,py,js,ts,go,rs",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

if (-not $OutFile) {
    $OutFile = Join-Path $RepoRoot "docs/wiki/_data/code-graph.json"
}

# Excluded paths (relative to $RepoRoot)
$Exclude = @(
    "release", "node_modules", ".git", ".github", "tests", ".freebuff",
    "memory", "_data", "docs/wiki/_data", "skills-mirror", "dist",
    "venv", "__pycache__", ".next", ".nuxt"
)

$LangMap = @{
    "ps1" = @{ ext = @("*.ps1","*.psm1"); def = '^\s*function\s+(\S+)' }
    "py"  = @{ ext = @("*.py");           def = '^\s*(?:def|class)\s+(\w+)' }
    "js"  = @{ ext = @("*.js","*.mjs");   def = '(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*=\s*(?:function|\(.*?\)\s*=>))' }
    "ts"  = @{ ext = @("*.ts","*.tsx");    def = '(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*(?::\s*\S+)?\s*=\s*(?:async\s+)?(?:function|\(.*?\)\s*=>))' }
    "go"  = @{ ext = @("*.go");           def = '^func\s+(?:\(\w+\s+\*?\w+\)\s+)?(\w+)' }
    "rs"  = @{ ext = @("*.rs");           def = '^\s*(?:pub\s+)?(?:async\s+)?fn\s+(\w+)' }
}

$SelectedLangs = $Languages -split ',' | ForEach-Object { $_.Trim().ToLower() }

function Log {
    param([string]$Msg)
    if (-not $Quiet) { Write-Host "[code-graph] $Msg" }
}

Log "Scanning $RepoRoot (languages: $($SelectedLangs -join ', '))"

# Collect files
$Files = @()
foreach ($lang in $SelectedLangs) {
    if (-not $LangMap.ContainsKey($lang)) { continue }
    $exts = $LangMap[$lang].ext
    foreach ($ext in $exts) {
        Get-ChildItem -Path $RepoRoot -Recurse -Include $ext -ErrorAction SilentlyContinue | ForEach-Object {
            $rel = $_.FullName.Substring($RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/'
            $skip = $false
            foreach ($Ex in $Exclude) {
                if ($rel -eq $Ex -or $rel.StartsWith("$Ex/")) { $skip = $true; break }
            }
            if (-not $skip) {
                $Files += @{ path = $rel; full = $_.FullName; lang = $lang }
            }
        }
    }
}

Log "Found $($Files.Count) files across $($SelectedLangs.Count) languages"

# Reserved words (combined)
$Reserved = @(
    "if","else","elseif","for","foreach","while","do","until","switch","return","try",
    "catch","finally","throw","function","param","begin","process","end","in","where",
    "select","trap","data","filter","local","private","script","global","using","class",
    "enum","interface","module","namespace","assembly","command","type","def","self",
    "true","false","nil","none","null","undefined","var","let","const","new","this",
    "import","from","export","default","async","await","yield","lambda","fn","pub",
    "struct","impl","trait","use","mod","match","loop","break","continue"
)

$Functions = @{}
$Edges = @()

foreach ($F in $Files) {
    $content = Get-Content $F.full -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $defPattern = $LangMap[$F.lang].def
    $DefinedHere = @()

    # Find function definitions
    foreach ($m in [regex]::Matches($content, "(?m)$defPattern")) {
        $name = ""
        for ($g = 1; $g -lt $m.Groups.Count; $g++) {
            if ($m.Groups[$g].Success -and $m.Groups[$g].Value -match '^\w+$') {
                $name = $m.Groups[$g].Value
                break
            }
        }
        if (-not $name) { continue }

        $DefinedHere += $name
        if (-not $Functions.ContainsKey($name)) {
            $Functions[$name] = @{ name = $name; files = @(); lang = $F.lang }
        }
        if ($Functions[$name].files -notcontains $F.path) {
            $Functions[$name].files += $F.path
        }
    }

    # Strip comments for call detection
    $stripped = $content
    if ($F.lang -in @("ps1")) {
        $stripped = $stripped -replace '(?m)^\s*#.*$', ''
        $stripped = $stripped -replace '<#[\s\S]*?#>', ''
    } elseif ($F.lang -in @("py")) {
        $stripped = $stripped -replace '(?m)^\s*#.*$', ''
        $stripped = $stripped -replace '(?s)"""[\s\S]*?"""', ''
        $stripped = $stripped -replace "(?s)'''[\s\S]*?'''", ''
    } elseif ($F.lang -in @("js","ts")) {
        $stripped = $stripped -replace '(?m)^\s*//.*$', ''
        $stripped = $stripped -replace '/\*[\s\S]*?\*/', ''
    } elseif ($F.lang -in @("go","rs")) {
        $stripped = $stripped -replace '(?m)^\s*//.*$', ''
        $stripped = $stripped -replace '/\*[\s\S]*?\*/', ''
    }

    # Detect calls
    $callRegex = [regex]::new('\b(\w+)\b')
    foreach ($m in $callRegex.Matches($stripped)) {
        $name = $m.Groups[1].Value
        if ($Reserved -contains $name) { continue }
        if ($Functions.ContainsKey($name) -and $name -notin $DefinedHere) {
            $Edges += @{ from = $F.path; to = $name; defined_here = $false }
        }
    }

    # Self-references
    foreach ($name in $DefinedHere) {
        $Edges += @{ from = $F.path; to = $name; defined_here = $true }
    }
}

# Build output
$langStats = @{}
foreach ($f in $Files) {
    if (-not $langStats.ContainsKey($f.lang)) { $langStats[$f.lang] = 0 }
    $langStats[$f.lang]++
}

$Out = [ordered]@{
    generated  = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
    languages  = $SelectedLangs
    langStats  = $langStats
    files      = $Files.Count
    nodeCount  = $Functions.Count
    edgeCount  = $Edges.Count
    functions  = $Functions.Values | Sort-Object name
    edges      = $Edges
}

# Ensure output dir
$dir = Split-Path $OutFile -Parent
if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

$Out | ConvertTo-Json -Depth 8 | Set-Content $OutFile -Encoding UTF8

Log "Wrote $OutFile"
Log "Nodes: $($Functions.Count)  Edges: $($Edges.Count)"
Log "Languages: $($langStats.Keys -join ', ')"
