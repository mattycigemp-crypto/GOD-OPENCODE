# ============================================
# GOD-OPENCODE CODE GRAPH BUILDER
# Version 1.0 (MVP)
# ============================================
# Walks the repo, extracts PowerShell function definitions + invocations,
# emits JSON graph to docs/wiki/_data/code-graph.json.
#
# Usage:
#   .\scripts\code-graph.ps1                    # default root
#   .\scripts\code-graph.ps1 -RepoRoot <path>
#   .\scripts\code-graph.ps1 -Quiet             # no console output

param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$OutFile  = "",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

if (-not $OutFile) {
    $OutFile = Join-Path $RepoRoot "docs/wiki/_data/code-graph.json"
}

# Excluded paths (relative to $RepoRoot, /-normalized)
$Exclude = @(
    "release", "node_modules", ".git", ".github", "tests", ".freebuff",
    "memory", "_data", "docs/wiki/_data"
)

function Log {
    param([string]$Msg)
    if (-not $Quiet) { Write-Host "[code-graph] $Msg" }
}

Log "Scanning $RepoRoot"

# Collect all PowerShell files
$Files = @()
Get-ChildItem -Path $RepoRoot -Recurse -Include "*.ps1", "*.psm1" -ErrorAction SilentlyContinue |
  ForEach-Object {
      $rel = $_.FullName.Substring($RepoRoot.Length).TrimStart('\', '/') -replace '\\', '/'
      $skip = $false
      foreach ($Ex in $Exclude) {
          if ($rel -eq $Ex -or $rel.StartsWith("$Ex/")) { $skip = $true ; break }
      }
      if (-not $skip) {
          $Files += @{ path = $rel; full = $_.FullName }
      }
  }

Log "Found $($Files.Count) PowerShell files"

# Function definitions (regex)
$DefRegex  = [regex]::new('(?m)^\s*function\s+(?<n>[A-Za-z][\w-]*)\b')
$CallRegex = [regex]::new('\b(?<n>[A-Za-z][\w-]*)\b')

# Reserved words that look like function calls but aren't
$Reserved = @(
    "if","else","elseif","for","foreach","while","do","until","switch","return","try",
    "catch","finally","throw","function","param","begin","process","end","in","where",
    "select","foreach","trap","data","filter","local","private","script","global","using",
    "class","enum","interface","module","namespace","assembly","command","type"
)

$Functions = @{}  # name -> @{ name; files = [] }
$Edges     = @()  # @{ from_path; to_name }

foreach ($F in $Files) {
    $content = Get-Content $F.full -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    # 1. Function defs in this file
    $DefinedHere = @()
    foreach ($m in $DefRegex.Matches($content)) {
        $n = $m.Groups['n'].Value
        $DefinedHere += $n
        if (-not $Functions.ContainsKey($n)) {
            $Functions[$n] = @{ name = $n ; files = @() }
        }
        if ($Functions[$n].files -notcontains $F.path) {
            $Functions[$n].files += $F.path
        }
    }

    # 2. Tokenize the file content (rough) for call lookups - strip comments and strings crudely
    $stripped = $content -replace '(?m)^\s*#.*$' , ''
    $stripped = $stripped -replace '<#[\s\S]*?#>', ''

    # 3. For each defined function, does this file reference it (call)?
    foreach ($n in $DefinedHere) {
        # Bare name call: not as the right side of "function $n" already accounted for, plus "function" word.
        $callPattern = [regex]::new("\b$n\b")
        if ($callPattern.Matches($stripped).Count -gt 0) {
            # Always add - this is at least a definition reference
            $Edges += @{ from = $F.path ; to = $n ; defined_here = $true }
        }
    }

    # 4. Outside-of-this-file calls: only add edges where the call refers to a known function
    foreach ($m in $CallRegex.Matches($stripped)) {
        $n = $m.Value
        if ($Reserved -contains $n) { continue }
        if ($Functions.ContainsKey($n) -and $n -notin $DefinedHere) {
            $Edges += @{ from = $F.path ; to = $n ; defined_here = $false }
        }
    }
}

$Out = [ordered]@{
    generated  = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssZ')
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
