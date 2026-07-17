# ============================================
# BUILD-SKILL-GRAPH
# GOD-OPENCODE Feature (v1.3.0)
# ============================================
# Scans agents/<name>/AGENT.md, skills/<cat>/<name>/SKILL.md, workflows/<name>.md
# and emits a single Mermaid `graph LR` file at docs/wiki/_data/architecture.mmd.
# Wired into .github/workflows/wiki-pages.yml so the wiki renders an up-to-date
# graph on every push. Also runnable locally:
#
#   .\scripts\build-skill-graph.ps1
#   .\scripts\build-skill-graph.ps1 -OutFile docs/site/graph/local.mmd
#
# The parser is intentionally simple - just text scanning of well-known Markdown
# sections. No AST or YAML frontmatter parsing - keeps the script PS 5.1
# compatible and side-effect free.
#
# Output vocabulary:
#   node: <agent-name>, <skill-name>, <workflow-name>, <skill-category>
#   edge: agent -> skill         (from agents/<name>/AGENT.md ## Skills)
#         workflow -> agent      (from workflows/<wf>.md ### Step N: Agent)
#         workflow -> skill      (from workflows/<wf>.md ### Step N: Skills)
#         category -> skill      (from skills/<cat>/<name>/, structural)

[CmdletBinding()]
param(
    [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")

$Root = Get-ProjectRoot
if (-not $OutFile) {
    $OutFile = Join-Path $Root "docs\wiki\_data\architecture.mmd"
}

# 1. Discover nodes.
$Agents = @()
if (Test-Path (Join-Path $Root "agents")) {
    $Agents = Get-ChildItem -Path (Join-Path $Root "agents") -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "AGENT.md") } |
        Select-Object -ExpandProperty Name | Sort-Object
}

$SkillCategories = @()   # e.g. "backend", "security", "ai"
$SkillNames      = @()   # e.g. "fastapi", "secure-coding"
if (Test-Path (Join-Path $Root "skills")) {
    $SkillCategories = Get-ChildItem -Path (Join-Path $Root "skills") -Directory |
        Select-Object -ExpandProperty Name | Sort-Object
    $SkillNames = Get-ChildItem -Path (Join-Path $Root "skills") -Directory -Recurse |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
        Select-Object -ExpandProperty Name | Sort-Object -Unique
}

$Workflows = @()
if (Test-Path (Join-Path $Root "workflows")) {
    $Workflows = Get-ChildItem -Path (Join-Path $Root "workflows") -Filter "*.md" -File |
        Select-Object -ExpandProperty BaseName | Sort-Object
}

# 2. Discover edges via simple text scanning.
$AgentToSkills     = @{}   # agent -> list of skills
$WorkflowToAgents = @{}   # workflow -> list of agents
$WorkflowToSkills = @{}   # workflow -> list of skills
$SkillToCategory  = @{}   # skill -> category

# Map skills to categories by structural path
foreach ($cat in $SkillCategories) {
    $catRoot = Join-Path (Join-Path $Root "skills") $cat
    if (Test-Path $catRoot) {
        Get-ChildItem -Path $catRoot -Directory -Recurse |
            Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } |
            ForEach-Object { $SkillToCategory[$_.Name] = $cat }
    }
}

function Get-SectionBody {
    # Pull body of a Markdown section headed by `$Header`. Multi-line friendly.
    # Equivalent to export-cursorrules.ps1's Get-Section but kept inline so
    # build-skill-graph.ps1 has zero cross-script deps beyond shared-utils.
    param([string]$SrcBody, [string]$Header)
    $Pattern = "(?ms)^##\s+" + ([regex]::Escape($Header)) + "\s*$" + "(.+?)(?=^##\s|\z)"
    $m = [regex]::Match($SrcBody, $Pattern)
    if ($m.Success) { return $m.Groups[1].Value }
    return ""
}

# 2a. Parse each agent's AGENT.md to find its ## Skills list.
foreach ($a in $Agents) {
    $agentFile = Join-Path (Join-Path $Root "agents") "$a\AGENT.md"
    if (!(Test-Path $agentFile)) { continue }
    $body = Get-Content $agentFile -Raw
    $section = Get-SectionBody -SrcBody $body -Header "Skills"
    if (-not $section) { continue }
    $names = ($section -split "[,\n\r]+") | ForEach-Object { $_.Trim() } | Where-Object { $_ -and ($_ -match "^[a-z][a-z0-9-]*$") }
    $AgentToSkills[$a] = @($names | Sort-Object -Unique)
}

# 2b. Parse each workflow to find ### Step N: Agent and Skills lines.
foreach ($wf in $Workflows) {
    $wfFile = Join-Path (Join-Path $Root "workflows") "$wf.md"
    if (!(Test-Path $wfFile)) { continue }
    $body = Get-Content $wfFile -Raw
    $stepBodies = @()
    $matches = [regex]::Matches($body, "(?ms)^### Step \d+:.+?(?=^### Step|\z)")
    foreach ($m in $matches) { $stepBodies += $m.Value }

    $agents = New-Object System.Collections.Generic.List[string]
    $skills = New-Object System.Collections.Generic.List[string]
    foreach ($step in $stepBodies) {
        $aMatch = [regex]::Match($step, "(?m)^- Agent:\s*([a-z][a-z0-9-]*)")
        if ($aMatch.Success) { $agents.Add($aMatch.Groups[1].Value) | Out-Null }
        $sMatch = [regex]::Match($step, "(?m)^- Skills:\s*(.+)$")
        if ($sMatch.Success) {
            ($sMatch.Groups[1].Value -split "[,\s]+") | ForEach-Object { $_.Trim() } | Where-Object { $_ -and ($_ -match "^[a-z][a-z0-9-]*$") } | ForEach-Object {
                $skills.Add($_) | Out-Null
            }
        }
    }
    $WorkflowToAgents[$wf] = @($agents | Sort-Object -Unique)
    $WorkflowToSkills[$wf] = @($skills | Sort-Object -Unique)
}

# 3. Emit Mermaid. Use stable node IDs (sanitized names) and friendly labels.
function Sanitize-Id {
    param([string]$Name)
    return ($Name -replace "[^a-zA-Z0-9_]", "_")
}

function Quote-Label {
    # Mermaid labels cannot contain certain punctuation. Wrap in quotes and
    # escape internal double-quotes.
    param([string]$Label)
    $clean = $Label -replace '"', '#quot;'
    return '"' + $clean + '"'
}

$lines = New-Object System.Collections.Generic.List[string]

$lines.Add("graph LR")
$lines.Add("  %% Auto-generated by scripts/build-skill-graph.ps1 - do not hand-edit.")
$lines.Add("  %% Generated: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"))

# Group declarations for cleaner Mermaid rendering.
$lines.Add("  subgraph Agents")
foreach ($a in $Agents) {
    $lines.Add("    " + (Sanitize-Id $a) + "[" + (Quote-Label $a) + "]:::agent")
}
$lines.Add("  end")
$lines.Add("")
$lines.Add("  subgraph Workflows")
foreach ($wf in $Workflows) {
    $lines.Add("    wf_" + (Sanitize-Id $wf) + "[" + (Quote-Label $wf) + "]:::workflow")
}
$lines.Add("  end")
$lines.Add("")
$lines.Add("  subgraph Skills")
# Group skills under their category subgraphs.
foreach ($cat in $SkillCategories) {
    $catSkills = @($SkillToCategory.Keys | Where-Object { $SkillToCategory[$_] -eq $cat } | Sort-Object)
    if ($catSkills.Count -eq 0) { continue }
    $lines.Add("    subgraph " + (Sanitize-Id "cat_$cat") + "[" + (Quote-Label "category: $cat") + "]")
    foreach ($s in $catSkills) {
        $lines.Add("      " + (Sanitize-Id $s) + "[" + (Quote-Label $s) + "]:::skill")
    }
    $lines.Add("    end")
}
$lines.Add("  end")
$lines.Add("")

# Edges: agent -> skill
foreach ($a in $Agents) {
    foreach ($s in ($AgentToSkills[$a] | Where-Object { $_ -in $SkillNames })) {
        $lines.Add("  " + (Sanitize-Id $a) + " --> " + (Sanitize-Id $s))
    }
}

# Edges: workflow -> agent
foreach ($wf in $Workflows) {
    foreach ($a in ($WorkflowToAgents[$wf] | Where-Object { $_ -in $Agents })) {
        $lines.Add("  wf_" + (Sanitize-Id $wf) + " --> " + (Sanitize-Id $a))
    }
}

# Edges: workflow -> skill
foreach ($wf in $Workflows) {
    foreach ($s in ($WorkflowToSkills[$wf] | Where-Object { $_ -in $SkillNames })) {
        $lines.Add("  wf_" + (Sanitize-Id $wf) + " --> " + (Sanitize-Id $s))
    }
}

$lines.Add("")
$lines.Add("  classDef agent    fill:#27272a,stroke:#8b5cf6,color:#fafafa")
$lines.Add("  classDef workflow fill:#27272a,stroke:#06b6d4,color:#fafafa")
$lines.Add("  classDef skill    fill:#1e1e22,stroke:#71717a,color:#a1a1aa")

# 4. Write file. Idempotent: skip write if content unchanged.
$OutDir2 = Split-Path $OutFile -Parent
if ($OutDir2 -and !(Test-Path $OutDir2)) {
    New-Item -ItemType Directory -Path $OutDir2 -Force | Out-Null
}

$content = ($lines -join "`n")
if ((Test-Path $OutFile) -and ((Get-FileHash $OutFile).Hash -eq (Get-FileHash ([System.Text.Encoding]::UTF8.GetBytes($content))).Hash)) {
    Write-Host "[UNCHANGED] $OutFile" -ForegroundColor Yellow
} else {
    Set-Content -Path $OutFile -Value $content -Encoding UTF8 -NoNewline
    Write-Host "[GENERATED] $OutFile" -ForegroundColor Green
    Write-Host "  Agents:    $($Agents.Count)"
    Write-Host "  Skills:    $($SkillNames.Count)"
    Write-Host "  Workflows: $($Workflows.Count)"
}
