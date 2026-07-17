# ============================================
# GOD-OPENCODE TERMINAL INTERFACE
# Version 6.0 - v1.6.0 with security scanner, agent orchestrator, MCP connectors, smart git
# ============================================
# Usage: .\god-ui.ps1
# Default action: Install globally to ~/.config/opencode/
# ============================================

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$Script:Colors = @{
    Primary   = "Magenta"
    Accent    = "Cyan"
    Success   = "Green"
    Warning   = "Yellow"
    Error     = "Red"
    Muted     = "DarkGray"
    Text      = "White"
    Header    = "DarkMagenta"
    Border    = "DarkCyan"
}

# Define Unicode box-drawing characters as variables to avoid parser issues
$Script:BoxTopLeft = [char]0x256D      # ╭
$Script:BoxTopRight = [char]0x256E     # ╮
$Script:BoxBottomLeft = [char]0x2570   # ╰
$Script:BoxBottomRight = [char]0x256F  # ╯
$Script:BoxHorizontal = [char]0x2500   # ─
$Script:BoxVertical = [char]0x2502     # │
$Script:BoxTeeDown = [char]0x252C      # ┬
$Script:BoxTeeUp = [char]0x2534        # ┴
$Script:BoxTeeRight = [char]0x251C     # ├
$Script:BoxTeeLeft = [char]0x2524      # ┤
$Script:BoxCross = [char]0x253C        # ┼

$Script:BoxChars = @{
    TopLeft=$Script:BoxTopLeft; TopRight=$Script:BoxTopRight
    BottomLeft=$Script:BoxBottomLeft; BottomRight=$Script:BoxBottomRight
    Horizontal=$Script:BoxHorizontal; Vertical=$Script:BoxVertical
    TeeDown=$Script:BoxTeeDown; TeeUp=$Script:BoxTeeUp
    TeeRight=$Script:BoxTeeRight; TeeLeft=$Script:BoxTeeLeft
    Cross=$Script:BoxCross
}

function Clear-Screen { Clear-Host }

function Write-Logo {
    $logo = @"

      ___  ___  ________  _______   ________
     |\  \\|\  \\|\   __  \\|\  ___ \ |\   __  \
     \ \  \\  \ \  \|\  \ \   __/|\ \  \|\  \
     \ \   __  \ \  \\  \ \  \_|/_\ \  \\  \
      \ \  \ \  \ \  \\  \ \  \_|\ \ \  \\  \
       \ \__\ \__\ \_______\ \_______\ \_______\
        \|__|\|__|\|_______|\|_______|\|_______|

           AI Engineering Operating System

"@
    Write-Host $logo -ForegroundColor $Colors.Primary
}

function Write-Header {
    param([string]$Title)
    $width = 60
    $line = [string]::new($BoxChars.Horizontal, $width)
    Write-Host ""
    Write-Host "  $($BoxChars.TopLeft)$line$($BoxChars.TopRight)" -ForegroundColor $Colors.Border
    Write-Host "  $($BoxChars.Vertical) " -ForegroundColor $Colors.Border -NoNewline
    Write-Host $Title.PadRight($width - 2) -ForegroundColor $Colors.Primary -NoNewline
    Write-Host " $($BoxChars.Vertical)" -ForegroundColor $Colors.Border
    Write-Host "  $($BoxChars.BottomLeft)$line$($BoxChars.BottomRight)" -ForegroundColor $Colors.Border
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor $Colors.Accent
    Write-Host "  $([string]::new([char]0x2500, 50))" -ForegroundColor $Colors.Muted
}

function Write-MenuItem {
    param(
        [string]$Key,
        [string]$Label,
        [string]$Description,
        [string]$Color = "White",
        [string]$Badge = ""
    )
    Write-Host "  " -NoNewline
    Write-Host "[$Key]" -ForegroundColor $Colors.Primary -NoNewline
    Write-Host " $Label" -ForegroundColor $Color -NoNewline
    if ($Badge) {
        Write-Host " ($Badge)" -ForegroundColor $Colors.Warning -NoNewline
    }
    Write-Host "  $Description" -ForegroundColor $Colors.Muted
}

function Write-Status {
    param([string]$Label, [string]$Value, [string]$Color = "Green")
    Write-Host "  " -NoNewline
    Write-Host ($Label.PadRight(20)) -ForegroundColor $Colors.Muted -NoNewline
    Write-Host " $Value" -ForegroundColor $Color
}

function Write-Divider { Write-Host "" ; Write-Host "  $([string]::new([char]0x2500, 56))" -ForegroundColor $Colors.Border }

function Get-Input {
    param([string]$Prompt = "Select")
    Write-Host ""
    Write-Host "  $Prompt" -ForegroundColor $Colors.Accent -NoNewline
    Write-Host ": " -ForegroundColor $Colors.Muted -NoNewline
    return (Read-Host)
}

function Invoke-Action {
    param([string]$Title, [scriptblock]$Action)
    Clear-Screen
    Write-Header $Title
    Write-Host ""
    try { & $Action } catch { Write-Host "" ; Write-Host "  Error: $_" -ForegroundColor $Colors.Error }
    Write-Host "" ; Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Wait-Key {
    Write-Host ""
    Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================
# DASHBOARD (with architectural features)
# ============================================

function Get-GlobalInstallStatus {
    $root = $HOME + "/.config/opencode/"
    $result = @{
        HasSkills     = $false
        HasAgents     = $false
        HasWorkflows  = $false
        HasConfig     = $false
        SkillCount    = 0
        AgentCount    = 0
        WorkflowCount = 0
    }
    if (Test-Path "$root/skills") {
        $result.HasSkills  = $true
        $result.SkillCount = (Get-ChildItem "$root/skills" -Directory -ErrorAction SilentlyContinue).Count
    }
    if (Test-Path "$root/god-opencode/agents") {
        $result.HasAgents  = $true
        $result.AgentCount = (Get-ChildItem "$root/god-opencode/agents" -Directory -ErrorAction SilentlyContinue).Count
    }
    if (Test-Path "$root/god-opencode/workflows") {
        $result.HasWorkflows  = $true
        $result.WorkflowCount = (Get-ChildItem "$root/god-opencode/workflows" -File -ErrorAction SilentlyContinue).Count
    }
    if (Test-Path "$root/opencode.jsonc") {
        $cfg = Get-Content "$root/opencode.jsonc" -Raw -ErrorAction SilentlyContinue
        $result.HasConfig = $cfg -match '"security-engineer"'
    }
    return $result
}

function Get-MemoryStatus {
    $dir = Join-Path $Root "memory"
    if (!(Test-Path $dir)) { return @{ Active = $false; Count = 0 } }
    $files = Get-ChildItem -Path $dir -Filter "*.md" -File -ErrorAction SilentlyContinue
    return @{ Active = ($files.Count -gt 0); Count = $files.Count }
}

function Get-CodeGraphStatus {
    $f = Join-Path $Root "docs/wiki/_data/code-graph.json"
    if (!(Test-Path $f)) { return @{ Active = $false; Functions = 0; Edges = 0; Updated = "never" } }
    try {
        $g = Get-Content $f -Raw | ConvertFrom-Json
        return @{ Active = $true; Functions = $g.nodeCount; Edges = $g.edgeCount; Updated = $g.generated }
    } catch { return @{ Active = $false; Functions = 0; Edges = 0; Updated = "error" } }
}

function Show-Dashboard {
    Clear-Screen
    Write-Logo
    Write-Header "AI Engineering Operating System"
    Write-Host ""

    # -- System Overview --
    Write-Section "System Overview"
    if (Test-Path "$Root/agents") { $agentCount = (Get-ChildItem "$Root/agents" -Directory).Count } else { $agentCount = 0 }
    if (Test-Path "$Root/skills") { $skillCount = (Get-ChildItem "$Root/skills" -Directory -Recurse | Where-Object { Test-Path "$($_.FullName)/SKILL.md" }).Count } else { $skillCount = 0 }
    if (Test-Path "$Root/workflows") { $wfCount = (Get-ChildItem "$Root/workflows" -File).Count } else { $wfCount = 0 }
    if (Test-Path "$Root/commands") { $cmdCount = (Get-ChildItem "$Root/commands" -File).Count } else { $cmdCount = 0 }

    Write-Status "Agents"    "$agentCount loaded"  "Cyan"
    Write-Status "Skills"    "$skillCount total"   "Magenta"
    Write-Status "Workflows" "$wfCount available"  "Yellow"
    Write-Status "Commands"  "$cmdCount slash"     "Green"

    # -- Global Install Status (HEADLINE) --
    Write-Section "Global Install (~/ .config/opencode/)"
    $g = Get-GlobalInstallStatus
    if ($g.SkillCount -gt 0 -and $g.HasConfig) {
        Write-Status "Global Skills"    "$($g.SkillCount) installed"   "Green"
        Write-Status "Global Agents"    "$($g.AgentCount) merged"      "Green"
        Write-Status "Global Workflows" "$($g.WorkflowCount) merged"   "Green"
        Write-Status "opencode.jsonc"   "Agents merged"               "Green"
        Write-Host ""
        Write-Host "  [OK] Globally installed - skills available from any directory" -ForegroundColor Green
    } else {
        Write-Host "  [!] NOT INSTALLED GLOBALLY" -ForegroundColor Yellow
        Write-Host "      Press [Enter] to install to ~/.config/opencode/" -ForegroundColor DarkGray
    }

    # -- Architectural Features --
    Write-Section "Architectural Features"
    $cg = Get-CodeGraphStatus
    $ms = Get-MemoryStatus
    Write-Status "Code Graph"        (if ($cg.Active) { "$($cg.Functions) functions, $($cg.Edges) edges" } else { "not built (use [3])" }) (if ($cg.Active) { "Green" } else { "Yellow" })
    Write-Status "  last updated"     $cg.Updated "DarkGray"
    Write-Status "Dynamic Skills"    "skill-fragment.ps1 ready" "Cyan"
    Write-Status "Cross-Platform"    "install.sh + install.cmd shims" "Cyan"
    Write-Status "Long-term Memory"   (if ($ms.Active) { "$($ms.Count) artifacts in memory/" } else { "empty (use [5])" }) (if ($ms.Active) { "Green" } else { "Yellow" })

    # -- Quick Actions --
    Write-Section "Quick Actions"
    Write-MenuItem "Enter" "Install Globally"      "Default action - skills/agents/workflows -> ~/.config/opencode" "Magenta" "DEFAULT"
    Write-MenuItem "1"     "Install Globally"      "(same as Enter) .\install.ps1" "Magenta"
    Write-MenuItem "2"     "Health Check"          "Verify system integrity"
    Write-MenuItem "3"     "Code Graph"            "Build/refresh call-graph index"
    Write-MenuItem "4"     "Skill Fragment"        "Dynamic context lookup for a topic"
    Write-MenuItem "5"     "Memory"                "Recall / append session memory"
    Write-MenuItem "6"     "Cross-Platform"        "Show bash/cmd/PowerShell install paths"
    Write-MenuItem "7"     "Tests"                 "Run Pester suite"
    Write-MenuItem "8"     "Wiki"                  "Open local wiki in browser"
    Write-MenuItem "9"     "Dashboard"             "Open browser dashboard"
    Write-MenuItem "S"     "Session Memory"        "Init / track / recall cross-session context"
    Write-MenuItem "W"     "Wiki Builder"          "Auto-generate reference pages from content"
    Write-MenuItem "L"     "Live Architecture"     "Regenerate wiki skill/agent/workflow graph"
    Write-MenuItem "R"     "Skills Registry"       "Bulk-fetch top-N from registry-sources.txt"
    Write-MenuItem "C"     "Cursor Export"         "Generate .cursorrules for every agent"
    Write-MenuItem "T"     "Security Scanner"      "Pre-commit secret/vulnerability/license scan"
    Write-MenuItem "A"     "Agent Orchestrator"    "Multi-agent task delegation"
    Write-MenuItem "M"     "MCP Connectors"        "Connect to Chrome/DB/Jira/Monitoring"
    Write-MenuItem "G"     "Smart Git"             "Atomic commits, save points, rollback"
    Write-MenuItem "N"     "What's new in v1.6.0"  "Current release notes from CHANGELOG.md"
    Write-MenuItem "Q"     "Exit"                  "Close the interface"

    Write-Divider
    Write-Host "  Tip: Enter = default action (Install Globally)" -ForegroundColor $Colors.Muted
    Write-Divider
}

# ============================================
# PAGES
# ============================================

function Show-InstallGlobally {
    Clear-Screen
    Write-Header "Install Globally -> ~/.config/opencode/"
    Write-Host ""
    Write-Host "  This will:" -ForegroundColor $Colors.Accent
    Write-Host "    - Copy 88 SKILL.md files into ~/.config/opencode/skills/"
    Write-Host "    - Merge 10 agent configs into ~/.config/opencode/opencode.jsonc"
    Write-Host "    - Copy workflows/agents/commands into ~/.config/opencode/god-opencode/"
    Write-Host "    - Update opencode.jsonc instructions glob (idempotent)"
    Write-Host ""
    Write-Host "  Source: .\install.ps1" -ForegroundColor $Colors.Muted
    Write-Host ""
    & (Join-Path $Root "install.ps1")
    Write-Host ""
    Write-Host "  Done. Skills now work from any directory." -ForegroundColor $Colors.Success
}

function Show-HealthCheck {
    Clear-Screen
    Write-Header "System Health Check"
    Write-Host ""
    $hs = Join-Path $Root "god-health.ps1"
    if (Test-Path $hs) { & $hs } else { Write-Host "  Health script missing." -ForegroundColor $Colors.Error }
}

function Show-CodeGraph {
    Clear-Screen
    Write-Header "Code Graph - build call-graph index"
    Write-Host ""
    $cg = Join-Path $Root "scripts/code-graph.ps1"
    if (!(Test-Path $cg)) {
        Write-Host "  scripts/code-graph.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Scanning PowerShell files..." -ForegroundColor $Colors.Accent
    Write-Host ""
    & $cg
    Write-Host ""
    Write-Host "  Output: docs/wiki/_data/code-graph.json" -ForegroundColor $Colors.Muted
    Write-Host "  Render: open docs/wiki/graph.md in your browser / markdown viewer" -ForegroundColor $Colors.Muted
}

function Show-SkillFragment {
    Clear-Screen
    Write-Header "Skill Fragment - dynamic context lookup"
    Write-Host ""
    $sf = Join-Path $Root "scripts/skill-fragment.ps1"
    if (!(Test-Path $sf)) {
        Write-Host "  scripts/skill-fragment.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    $q = Get-Input "Topic (e.g. 'authentication jwt', 'fastapi async', 'kubernetes ingress')"
    if ([string]::IsNullOrWhiteSpace($q)) { return }
    Write-Host ""
    Write-Host "  Matching skills (top 5):" -ForegroundColor $Colors.Accent
    Write-Host ""
    & $sf -Query $q | ForEach-Object {
        Write-Host "  $($_.skill)" -ForegroundColor $Colors.Magenta
        foreach ($t in $_.topics) {
            Write-Host "    -- $($t.heading) (score $($t.score))" -ForegroundColor $Colors.Cyan
        }
        Write-Host ""
    }
}

function Show-Memory {
    Clear-Screen
    Write-Header "Memory - Architectural Decisions + Session Notes"
    Write-Host ""
    $ms = Join-Path $Root "scripts/memory.ps1"
    if (Test-Path $ms) { & $ms }
    Write-Host ""
    Write-Section "Append a memory artifact"
    Write-Host "  Type: [A]rchitecture-decision  [C]oding-convention  [T]odo  [L]og  [S]upposition" -ForegroundColor $Colors.Muted
    $t = Get-Input "  Type (A/C/T/L/S) or Enter to skip"
    $map = @{ "A"="architecture-decision" ; "C"="coding-convention" ; "T"="todo" ; "L"="changelog" ; "S"="assumption" }
    if ($map.ContainsKey($t.ToUpper())) {
        $title = Get-Input "  Title"
        $body  = Get-Input "  Content (one line)"
        if ($title -and $body) {
            . $ms
            New-MemoryArtifact -Type $map[$t.ToUpper()] -Title $title -Author "god-ui" -Content $body | Out-Null
            Write-Host "  [MEMORY] Saved." -ForegroundColor $Colors.Success
        }
    }
}

function Show-CrossPlatform {
    Clear-Screen
    Write-Header "Cross-Platform Install"
    Write-Host ""
    Write-Section "Windows (PowerShell)"
    Write-Host "    .\install.ps1" -ForegroundColor $Colors.Magenta
    Write-Host ""
    Write-Section "Windows (cmd.exe)"
    Write-Host "    install.cmd" -ForegroundColor $Colors.Magenta
    Write-Host ""
    Write-Section "Linux / macOS / WSL (requires pwsh)"
    Write-Host "    bash install.sh" -ForegroundColor $Colors.Magenta
    Write-Host ""
    Write-Host "  install.sh delegates to ./install.ps1 via PowerShell 7 (pwsh)." -ForegroundColor $Colors.Muted
    Write-Host "  Get pwsh: https://aka.ms/powershell" -ForegroundColor $Colors.Muted
    Write-Host ""
    Write-Section "Container (any platform with Docker)"
    Write-Host "    docker pull ghcr.io/mattycigemp-crypto/god-opencode:latest" -ForegroundColor $Colors.Magenta
}

function Show-TestRunner {
    Clear-Screen
    Write-Header "Pester Test Suite"
    Write-Host ""
    Write-Host "  1 - Unit" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Property" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Smoke"  -ForegroundColor $Colors.Muted
    Write-Host "  4 - All (excl. integration)" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "Test suite"
    $config = New-PesterConfiguration
    $config.Run.Path = (Join-Path $Root "tests")
    $config.Output.Verbosity = "Detailed"
    switch ($choice.ToUpper()) {
        "1" { $config.Filter.Tag = "Unit"        ; Invoke-Pester -Configuration $config }
        "2" { $config.Filter.Tag = "Property"     ; Invoke-Pester -Configuration $config }
        "3" { $config.Filter.Tag = "Smoke"        ; Invoke-Pester -Configuration $config }
        "4" { $config.Filter.ExcludeTagFilter = "Integration"; Invoke-Pester -Configuration $config }
        "B" { return }
    }
}

function Show-WikiPage {
    $wiki = Join-Path $Root "docs/wiki/index.md"
    $html = Join-Path $Root "docs/wiki/index.html"
    if (Test-Path $html) { Start-Process $html ; return }
    if (Test-Path $wiki) {
        Write-Host ""
        Write-Host "  Wiki source: $wiki" -ForegroundColor $Colors.Muted
        Write-Host "  Open in your editor / markdown viewer." -ForegroundColor $Colors.Muted
    } else {
        Write-Host "  Wiki missing at $wiki" -ForegroundColor $Colors.Error
    }
}

function Show-BrowserDashboard {
    $p = Join-Path $Root "ui/index.html"
    if (Test-Path $p) {
        Start-Process $p
        Write-Host "" ; Write-Host "  Dashboard opened." -ForegroundColor $Colors.Success
    } else {
        Write-Host "" ; Write-Host "  Dashboard missing at $p" -ForegroundColor $Colors.Error
    }
    Start-Sleep -Seconds 1
}

# ============================================
# v1.3.0 PAGES — Live Graph, Skills Sync, Cursor Export, What's New
# ============================================

function Show-LiveGraph {
    Clear-Screen
    Write-Header "Live Architecture Graph  (v1.3.0)"
    Write-Host ""
    $script = Join-Path $Root "scripts/build-skill-graph.ps1"
    if (!(Test-Path $script)) {
        Write-Host "  scripts/build-skill-graph.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Scanning agents/, skills/, workflows/..." -ForegroundColor $Colors.Accent
    Write-Host ""
    & $script
    Write-Host ""
    Write-Host "  Output: docs\wiki\_data\architecture.mmd  (Mermaid graph)" -ForegroundColor $Colors.Muted
    Write-Host "  Rendered in the wiki at: docs\wiki\architecture.md" -ForegroundColor $Colors.Muted
}

function Show-SkillsSync {
    Clear-Screen
    Write-Header "Skills Registry Mirror Sync  (v1.3.0)"
    Write-Host ""
    Write-Host "  Shallow-clones top 5 entries from registry-sources.txt" -ForegroundColor $Colors.Muted
    Write-Host "  into skills-mirror/. Use .\scripts\install-skill.ps1 -Sync -TopN N" -ForegroundColor $Colors.Muted
    Write-Host "  for any N. Ctrl+C here aborts before any network call." -ForegroundColor $Colors.Muted
    Write-Host ""
    $ans = Get-Input "Proceed with sync? (Y/N)"
    if ($ans.ToUpper() -ne "Y") { Write-Host "  Cancelled." -ForegroundColor $Colors.Warning ; return }
    & (Join-Path $Root "scripts\install-skill.ps1") -Sync -TopN 5
}

function Show-CursorExport {
    Clear-Screen
    Write-Header "Cursor / Windsurf Drop-in Export  (v1.3.0)"
    Write-Host ""
    Write-Host "  Generates a .cursorrules per agent into dist\cursorrules\" -ForegroundColor $Colors.Muted
    Write-Host "  using the cursor rule schema (YAML frontmatter + sections)." -ForegroundColor $Colors.Muted
    Write-Host ""
    $ans = Get-Input "Generate now? (Y/N)"
    if ($ans.ToUpper() -ne "Y") { Write-Host "  Cancelled." -ForegroundColor $Colors.Warning ; return }
    & (Join-Path $Root "scripts\install-skill.ps1") -Use cursorrules
}

function Show-SessionMemory {
    Clear-Screen
    Write-Header "Session Memory  (v1.4.0)"
    Write-Host ""
    $sm = Join-Path $Root "scripts/session-memory.ps1"
    if (!(Test-Path $sm)) {
        Write-Host "  scripts/session-memory.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  1 - Show Session Summary" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Initialize New Session" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Recall Last Session" -ForegroundColor $Colors.Muted
    Write-Host "  4 - Track Usage (Agent/Skill/Project)" -ForegroundColor $Colors.Muted
    Write-Host "  5 - Show Learned Preferences" -ForegroundColor $Colors.Muted
    Write-Host "  6 - Show Usage Analytics" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "Session Memory"
    switch ($choice.ToUpper()) {
        "1" { & $sm }
        "2" { & $sm -Init }
        "3" { & $sm -Recall }
        "4" {
            $a = Get-Input "  Agent name (or empty)"
            $s = Get-Input "  Skill name (or empty)"
            $p = Get-Input "  Project name (or empty)"
            $hasTrack = $false
            if ($a) { & $sm -Track -Agent $a; $hasTrack = $true }
            if ($s) { & $sm -Track -Skill $s; $hasTrack = $true }
            if ($p) { & $sm -Track -Project $p; $hasTrack = $true }
            if (-not $hasTrack) { Write-Host "  Nothing to track." -ForegroundColor $Colors.Warning }
        }
        "5" { & $sm -Prefs }
        "6" { & $sm -Stats }
        "B" { return }
    }
}

function Show-WikiBuilder {
    Clear-Screen
    Write-Header "Wiki Auto-Builder  (v1.4.0)"
    Write-Host ""
    $wb = Join-Path $Root "scripts/build-wiki.ps1"
    if (!(Test-Path $wb)) {
        Write-Host "  scripts/build-wiki.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Auto-generates reference pages from skill/agent/workflow content." -ForegroundColor $Colors.Muted
    Write-Host ""
    Write-Host "  1 - Build All Reference Pages" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Skills Reference Only" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Agents Reference Only" -ForegroundColor $Colors.Muted
    Write-Host "  4 - Workflows Reference Only" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "Wiki Builder"
    switch ($choice.ToUpper()) {
        "1" { & $wb }
        "2" { & $wb -SkillsOnly }
        "3" { & $wb -AgentsOnly }
        "4" { & $wb -WorkflowsOnly }
        "B" { return }
    }
}

function Show-SecurityScan {
    Clear-Screen
    Write-Header "Security Scanner  (v1.6.0)"
    Write-Host ""
    $script = Join-Path $Root "scripts/security-scan.ps1"
    if (!(Test-Path $script)) {
        Write-Host "  scripts/security-scan.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  1 - Scan Staged Files (git diff --cached)" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Scan All Files" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Scan Specific File" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "Security Scanner"
    switch ($choice.ToUpper()) {
        "1" { & $script -Staged }
        "2" { & $script }
        "3" {
            $file = Get-Input "  File path"
            if ($file) { & $script -Path $file }
        }
        "B" { return }
    }
}

function Show-AgentOrch {
    Clear-Screen
    Write-Header "Agent Orchestrator  (v1.6.0)"
    Write-Host ""
    $script = Join-Path $Root "scripts/agent-orchestrator.ps1"
    if (!(Test-Path $script)) {
        Write-Host "  scripts/agent-orchestrator.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Multi-agent task delegation with verification." -ForegroundColor $Colors.Muted
    Write-Host ""
    $task = Get-Input "  Task description"
    if ([string]::IsNullOrWhiteSpace($task)) { return }
    $agents = Get-Input "  Agents (comma-separated, or empty for auto-select)"
    if ($agents) {
        & $script -Task $task -Agents $agents
    } else {
        & $script -Task $task
    }
}

function Show-MCPConnect {
    Clear-Screen
    Write-Header "MCP Connectors  (v1.6.0)"
    Write-Host ""
    $script = Join-Path $Root "scripts/mcp-connect.ps1"
    if (!(Test-Path $script)) {
        Write-Host "  scripts/mcp-connect.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Connect to external tools via MCP." -ForegroundColor $Colors.Muted
    Write-Host ""
    Write-Host "  1 - Chrome DevTools (screenshot/console/network)" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Database Explorer (schema/query/tables)" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Jira Issue Tracker (list/get/create)" -ForegroundColor $Colors.Muted
    Write-Host "  4 - Monitoring (errors/metrics/logs)" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "MCP Tool"
    switch ($choice.ToUpper()) {
        "1" { $act = Get-Input "  Action (screenshot/console/network)"; if ($act) { & $script -Tool "chrome" -Action $act } }
        "2" { $act = Get-Input "  Action (schema/query/tables)"; $tgt = Get-Input "  Target (database name)"; if ($act) { & $script -Tool "database" -Action $act -Target $tgt } }
        "3" { $act = Get-Input "  Action (list/get/create)"; $proj = Get-Input "  Project key"; if ($act) { & $script -Tool "jira" -Action $act -Project $proj } }
        "4" { $act = Get-Input "  Action (errors/metrics/logs)"; $svc = Get-Input "  Service name"; if ($act) { & $script -Tool "monitoring" -Action $act -Service $svc } }
        "B" { return }
    }
}

function Show-SmartGit {
    Clear-Screen
    Write-Header "Smart Git  (v1.6.0)"
    Write-Host ""
    $script = Join-Path $Root "scripts/smart-git.ps1"
    if (!(Test-Path $script)) {
        Write-Host "  scripts/smart-git.ps1 missing." -ForegroundColor $Colors.Error
        return
    }
    Write-Host "  Atomic commits, save points, and rollback." -ForegroundColor $Colors.Muted
    Write-Host ""
    Write-Host "  1 - Smart Commit (auto-generate message)" -ForegroundColor $Colors.Muted
    Write-Host "  2 - Create Save Point" -ForegroundColor $Colors.Muted
    Write-Host "  3 - Rollback to Last Save Point" -ForegroundColor $Colors.Muted
    Write-Host "  4 - Show Diff" -ForegroundColor $Colors.Muted
    Write-Host "  5 - Show Recent Commits" -ForegroundColor $Colors.Muted
    Write-Host "  6 - Git Status" -ForegroundColor $Colors.Muted
    Write-Host "  B - Back" -ForegroundColor $Colors.Muted
    $choice = Get-Input "Smart Git"
    switch ($choice.ToUpper()) {
        "1" { $msg = Get-Input "  Commit message (or empty for auto)"; if ($msg) { & $script commit -Message $msg } else { & $script commit } }
        "2" { & $script savepoint }
        "3" { & $script rollback }
        "4" { & $script diff }
        "5" { & $script log }
        "6" { & $script status }
        "B" { return }
    }
}

function Show-WhatsNew {
    Clear-Screen
    Write-Header "What's New in v1.6.0"
    Write-Host ""
    Write-Host "  Five new features from deep research on what developers want." -ForegroundColor $Colors.Accent
    Write-Host ""
    Write-Section "Security Scanner"
    Write-Host "  scripts\security-scan.ps1 - Pre-commit secret/vulnerability scan" -ForegroundColor $Colors.Text
    Write-Host "  Detects API keys, passwords, SQL injection, XSS, and more." -ForegroundColor $Colors.Text
    Write-Host ""
    Write-Section "Agent Orchestrator"
    Write-Host "  scripts\agent-orchestrator.ps1 - Multi-agent task delegation" -ForegroundColor $Colors.Text
    Write-Host "  Automatically selects agents based on task keywords." -ForegroundColor $Colors.Text
    Write-Host ""
    Write-Section "MCP Connectors"
    Write-Host "  scripts\mcp-connect.ps1 - Connect to Chrome/DB/Jira/Monitoring" -ForegroundColor $Colors.Text
    Write-Host "  See UI, schemas, tickets, and errors from external tools." -ForegroundColor $Colors.Text
    Write-Host ""
    Write-Section "Smart Git"
    Write-Host "  scripts\smart-git.ps1 - Atomic commits, save points, rollback" -ForegroundColor $Colors.Text
    Write-Host "  AI-generated commit messages and safe rollback points." -ForegroundColor $Colors.Text
    Write-Host ""
    Write-Section "Test-Driven AI Workflow"
    Write-Host "  workflows\test-driven-ai.md - Automated test generation" -ForegroundColor $Colors.Text
    Write-Host "  Generate tests before code, then implement to pass." -ForegroundColor $Colors.Text
    Write-Host ""
    Write-Divider
    Write-Host "  Canonical release notes: CHANGELOG.md  ([1.6.0] section)" -ForegroundColor $Colors.Muted
    Write-Divider
}

# ============================================
# MAIN LOOP
# ============================================

while ($true) {
    Show-Dashboard
    $choice = (Get-Input "Command (Enter = install globally)").Trim()

    switch ($choice.ToUpper()) {
        { $_ -eq "" -or $_ -eq "1" } {
            Clear-Screen ; Show-InstallGlobally ; Wait-Key
        }
        "2" { Clear-Screen ; Show-HealthCheck   ; Wait-Key }
        "3" { Clear-Screen ; Show-CodeGraph     ; Wait-Key }
        "4" { Clear-Screen ; Show-SkillFragment ; Wait-Key }
        "5" { Clear-Screen ; Show-Memory        ; Wait-Key }
        "6" { Clear-Screen ; Show-CrossPlatform ; Wait-Key }
        "7" { Clear-Screen ; Show-TestRunner    ; Wait-Key }
        "8" { Clear-Screen ; Show-WikiPage      ; Wait-Key }
        "9" { Clear-Screen ; Show-BrowserDashboard ; Wait-Key }
        "S" { Clear-Screen ; Show-SessionMemory   ; Wait-Key }
        "W" { Clear-Screen ; Show-WikiBuilder     ; Wait-Key }
        "L" { Clear-Screen ; Show-LiveGraph       ; Wait-Key }
        "R" { Clear-Screen ; Show-SkillsSync      ; Wait-Key }
        "C" { Clear-Screen ; Show-CursorExport    ; Wait-Key }
        "T" { Clear-Screen ; Show-SecurityScan   ; Wait-Key }
        "A" { Clear-Screen ; Show-AgentOrch       ; Wait-Key }
        "M" { Clear-Screen ; Show-MCPConnect     ; Wait-Key }
        "G" { Clear-Screen ; Show-SmartGit       ; Wait-Key }
        "N" { Clear-Screen ; Show-WhatsNew        ; Wait-Key }
        "Q" {
            Clear-Screen
            Write-Host "" ; Write-Host "  GOD-OPENCODE UI closed." -ForegroundColor $Colors.Muted ; Write-Host ""
            exit
        }
        default {
            Write-Host "" ; Write-Host "  Invalid. Enter = install globally, ? numbers / Q." -ForegroundColor $Colors.Warning
            Start-Sleep -Seconds 1
        }
    }
}
