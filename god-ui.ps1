# ============================================
# GOD-OPENCODE TERMINAL INTERFACE
# Version 2.0
# ============================================
# Professional TUI for managing the GOD-OPENCODE
# AI engineering operating system.
#
# Usage: .\god-ui.ps1
# ============================================

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================
# UI CONSTANTS
# ============================================

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

$Script:BoxChars = @{
    TopLeft     = "+"
    TopRight    = "+"
    BottomLeft  = "+"
    BottomRight = "+"
    Horizontal  = "-"
    Vertical    = "|"
}

# ============================================
# UI FUNCTIONS
# ============================================

function Clear-Screen {
    Clear-Host
}

function Write-Logo {
    $logo = @"

     _____ ____   ____            __  __ ___
    / ____|  _ \ / ___|___ _   _|  \/  | _ \
   | |  __| |_) | |   / _ \ | | | |\/| | |_)
   | |_| |  _ <| |__|  __/ |_| | |  | | _ <
     \____|_| \_\\____\___|\__, |_|  |_|_(_) |
                           |___/             |_|

"@
    Write-Host $logo -ForegroundColor $Colors.Primary
}

function Write-Header {
    param([string]$Title)
    $width = 60
    $pad = $width - $Title.Length - 4
    if ($pad -lt 0) { $pad = 0 }
    $line = [string]::new($BoxChars.Horizontal, $width)
    Write-Host ""
    Write-Host "  $($BoxChars.TopLeft)$line$($BoxChars.TopRight)" -ForegroundColor $Colors.Border
    Write-Host "  $($BoxChars.Vertical) " -ForegroundColor $Colors.Border -NoNewline
    Write-Host ("$Title$([string]::new(' ', $pad))") -ForegroundColor $Colors.Primary -NoNewline
    Write-Host " $($BoxChars.Vertical)" -ForegroundColor $Colors.Border
    Write-Host "  $($BoxChars.BottomLeft)$line$($BoxChars.BottomRight)" -ForegroundColor $Colors.Border
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor $Colors.Accent
    Write-Host "  $([string]::new('-', 50))" -ForegroundColor $Colors.Muted
}

function Write-MenuItem {
    param(
        [string]$Key,
        [string]$Label,
        [string]$Description,
        [string]$Color = "White"
    )
    Write-Host "  " -NoNewline
    Write-Host "[$Key]" -ForegroundColor $Colors.Primary -NoNewline
    Write-Host " $Label" -ForegroundColor $Color -NoNewline
    Write-Host "  $Description" -ForegroundColor $Colors.Muted
}

function Write-Status {
    param(
        [string]$Label,
        [string]$Value,
        [string]$Color = "Green"
    )
    Write-Host "  " -NoNewline
    Write-Host "$Label" -ForegroundColor $Colors.Muted -NoNewline
    Write-Host " $Value" -ForegroundColor $Color
}

function Write-Divider {
    Write-Host ""
    Write-Host "  $([string]::new('=', 56))" -ForegroundColor $Colors.Border
}

function Get-Input {
    param([string]$Prompt = "Select")
    Write-Host ""
    Write-Host "  $Prompt" -ForegroundColor $Colors.Accent -NoNewline
    Write-Host ": " -ForegroundColor $Colors.Muted -NoNewline
    return (Read-Host)
}

function Invoke-Action {
    param(
        [string]$Title,
        [scriptblock]$Action
    )
    Clear-Screen
    Write-Header $Title
    Write-Host ""
    try {
        & $Action
    } catch {
        Write-Host ""
        Write-Host "  Error: $_" -ForegroundColor $Colors.Error
    }
    Write-Host ""
    Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================
# PAGE: DASHBOARD
# ============================================

function Show-Dashboard {
    Clear-Screen
    Write-Logo
    Write-Header "AI Engineering Operating System"
    Write-Host ""

    # System stats
    Write-Section "System Overview"

    $agentCount = 0
    $skillCount = 0
    $workflowCount = 0
    $commandCount = 0

    if (Test-Path "$Root\agents") {
        $agentCount = (Get-ChildItem "$Root\agents" -Directory).Count
    }
    if (Test-Path "$HOME\.config\opencode\skills") {
        $skillCount = (Get-ChildItem "$HOME\.config\opencode\skills" -Directory -ErrorAction SilentlyContinue).Count
    }
    if (Test-Path "$Root\workflows") {
        $workflowCount = (Get-ChildItem "$Root\workflows" -File).Count
    }
    if (Test-Path "$Root\commands") {
        $commandCount = (Get-ChildItem "$Root\commands" -File).Count
    }

    Write-Status "Agents"    "$agentCount loaded" "Cyan"
    Write-Status "Skills"    "$skillCount installed" "Magenta"
    Write-Status "Workflows" "$workflowCount available" "Yellow"
    Write-Status "Commands"  "$commandCount slash commands" "Green"

    # Quick actions
    Write-Section "Quick Actions"
    Write-MenuItem "1" "Install / Update" "Bootstrap or refresh the framework"
    Write-MenuItem "2" "Health Check"     "Verify system integrity"
    Write-MenuItem "3" "Project Scan"     "Analyze a codebase"
    Write-MenuItem "4" "Run Tests"        "Execute Pester test suite"
    Write-MenuItem "5" "Memory"           "View architectural decisions"
    Write-MenuItem "6" "Router Test"      "Test keyword routing"
    Write-MenuItem "Q" "Exit"             "Close the interface"

    Write-Divider
}

# ============================================
# PAGE: HEALTH CHECK
# ============================================

function Show-HealthCheck {
    Clear-Screen
    Write-Header "System Health Check"
    Write-Host ""

    $healthScript = Join-Path $Root "god-health.ps1"
    if (Test-Path $healthScript) {
        & $healthScript
    } else {
        Write-Host "  Health check script not found." -ForegroundColor $Colors.Error
    }
}

# ============================================
# PAGE: PROJECT SCAN
# ============================================

function Show-ProjectScan {
    Clear-Screen
    Write-Header "Intelligence Engine - Project Scan"
    Write-Host ""

    $target = Get-Input "Enter project path (Enter for current dir)"
    if ([string]::IsNullOrWhiteSpace($target)) {
        $target = (Get-Location).Path
    }

    if (!(Test-Path $target)) {
        Write-Host ""
        Write-Host "  Path not found: $target" -ForegroundColor $Colors.Error
        return
    }

    Write-Host ""
    Write-Host "  Scanning: $target" -ForegroundColor $Colors.Accent
    Write-Host ""

    $scanScript = Join-Path $Root "tools\project-scan.ps1"
    if (Test-Path $scanScript) {
        & $scanScript -TargetPath $target
    } else {
        Write-Host "  Scanner not found at $scanScript" -ForegroundColor $Colors.Error
    }
}

# ============================================
# PAGE: TEST RUNNER
# ============================================

function Show-TestRunner {
    Clear-Screen
    Write-Header "Pester Test Suite"
    Write-Host ""

    Write-Section "Test Options"
    Write-MenuItem "1" "Unit Tests"       "Fast, isolated tests"
    Write-MenuItem "2" "Property Tests"   "Invariant verification"
    Write-MenuItem "3" "Smoke Tests"      "Structure validation"
    Write-MenuItem "4" "All (excl. integration)" "Full suite minus integration"
    Write-MenuItem "B" "Back"             "Return to dashboard"

    $choice = Get-Input "Select test suite"

    $testPath = Join-Path $Root "tests"
    $config = New-PesterConfiguration
    $config.Run.Path = $testPath
    $config.Output.Verbosity = "Detailed"

    switch ($choice) {
        "1" {
            $config.Filter.Tag = "Unit"
            Invoke-Pester -Configuration $config
        }
        "2" {
            $config.Filter.Tag = "Property"
            Invoke-Pester -Configuration $config
        }
        "3" {
            $config.Filter.Tag = "Smoke"
            Invoke-Pester -Configuration $config
        }
        "4" {
            $config.Filter.ExcludeTagFilter = "Integration"
            Invoke-Pester -Configuration $config
        }
        "B" { return }
        default {
            Write-Host "  Invalid option." -ForegroundColor $Colors.Warning
        }
    }
}

# ============================================
# PAGE: MEMORY VIEWER
# ============================================

function Show-Memory {
    Clear-Screen
    Write-Header "Memory - Architectural Decisions"
    Write-Host ""

    $memoryScript = Join-Path $Root "scripts\memory.ps1"
    if (Test-Path $memoryScript) {
        & $memoryScript
    } else {
        Write-Host "  Memory script not found." -ForegroundColor $Colors.Error
    }
}

# ============================================
# PAGE: ROUTER TESTER
# ============================================

function Show-RouterTest {
    Clear-Screen
    Write-Header "Router - Keyword Test"
    Write-Host ""

    $request = Get-Input "Enter a task description"
    if ([string]::IsNullOrWhiteSpace($request)) {
        Write-Host "  No input provided." -ForegroundColor $Colors.Warning
        return
    }

    Write-Host ""
    Write-Host "  Routing: $request" -ForegroundColor $Colors.Accent
    Write-Host ""

    $routerScript = Join-Path $Root "scripts\router.ps1"
    if (Test-Path $routerScript) {
        & $routerScript -Request $request
    } else {
        Write-Host "  Router script not found." -ForegroundColor $Colors.Error
    }
}

# ============================================
# MAIN LOOP
# ============================================

while ($true) {
    Show-Dashboard
    $choice = Get-Input "Command"

    switch ($choice.ToUpper()) {
        "1" {
            Invoke-Action "Installing GOD-OPENCODE" {
                & (Join-Path $Root "god-install.ps1")
            }
        }
        "2" {
            Clear-Screen
            Show-HealthCheck
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Clear-Screen
            Show-ProjectScan
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Clear-Screen
            Show-TestRunner
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" {
            Clear-Screen
            Show-Memory
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "6" {
            Clear-Screen
            Show-RouterTest
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor $Colors.Muted
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "Q" {
            Clear-Screen
            Write-Host ""
            Write-Host "  GOD-OPENCODE UI closed." -ForegroundColor $Colors.Muted
            Write-Host ""
            exit
        }
        default {
            Write-Host ""
            Write-Host "  Invalid option. Try again." -ForegroundColor $Colors.Warning
            Start-Sleep -Seconds 1
        }
    }
}
