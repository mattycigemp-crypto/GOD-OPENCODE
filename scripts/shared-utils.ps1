# ============================================
# GOD-OPENCODE SHARED UTILITIES
# Version 2.0
# ============================================
# Dot-source this module in any GOD-OPENCODE script:
#   . (Join-Path $PSScriptRoot "shared-utils.ps1")

$ErrorActionPreference = "Stop"

# ============================================
# Get-ProjectRoot
# Returns the absolute path to the GOD-OPENCODE
# root directory, regardless of where the caller
# is located or how the script was invoked.
# ============================================
function Get-ProjectRoot {
    if ($PSScriptRoot) {
        return Split-Path $PSScriptRoot -Parent
    }
    if ($MyInvocation.MyCommand.Path) {
        return Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    return (Get-Location).Path
}

# ============================================
# EnsureFolder
# Creates a directory if it doesn't exist.
# Silently succeeds if it already exists.
# ============================================
function EnsureFolder {
    param([Parameter(Mandatory)][string]$Folder)
    if (!(Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder -Force | Out-Null
        Write-Host "[CREATED] $Folder" -ForegroundColor Cyan
    }
}

# ============================================
# Write-IfChanged
# Writes $Content to $Path only when content
# differs from what is already on disk.
# Never touches files with identical content.
# ============================================
function Write-IfChanged {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )
    if (!(Test-Path $Path)) {
        $Dir = Split-Path $Path -Parent
        if ($Dir -and !(Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        }
        [System.IO.File]::WriteAllText($Path, $Content)
        Write-Host "[NEW]     $Path" -ForegroundColor Green
    } else {
        $Current = [System.IO.File]::ReadAllText($Path)
        if ($Current -ne $Content) {
            [System.IO.File]::WriteAllText($Path, $Content)
            Write-Host "[UPDATED] $Path" -ForegroundColor Yellow
        }
    }
}

# ============================================
# Write-IfMissing
# Writes $Content to $Path only if the file
# does not already exist. Never overwrites.
# ============================================
function Write-IfMissing {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )
    if (!(Test-Path $Path)) {
        $Dir = Split-Path $Path -Parent
        if ($Dir -and !(Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        }
        [System.IO.File]::WriteAllText($Path, $Content)
        Write-Host "[NEW]     $Path" -ForegroundColor Green
    }
}

# ============================================
# RunStep
# Executes a sub-script by name.
# Wraps execution in try/catch, logs failure,
# and continues. Never aborts the pipeline.
# Returns $true on success, $false on failure.
# ============================================
function RunStep {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Script,
        [string]$ScriptsDir = (Join-Path (Get-ProjectRoot) "scripts")
    )

    Write-Host ""
    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray

    $Path = Join-Path $ScriptsDir $Script

    if (!(Test-Path $Path)) {
        Write-Host "[SKIPPED] $Script not found" -ForegroundColor Yellow
        return $false
    }

    try {
        & $Path
        Write-Host "[SUCCESS] $Title" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAILED]  $Title : $_" -ForegroundColor Red
        return $false
    }
}

# ============================================
# Get-ISOTimestamp
# Returns the current time as ISO-8601 string.
# ============================================
function Get-ISOTimestamp {
    return (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
}

# ============================================
# ConvertTo-Slug
# Converts a string to a lowercase kebab-case
# slug safe for use in file names.
# ============================================
function ConvertTo-Slug {
    param(
        [Parameter(Mandatory)][string]$Text,
        [int]$MaxLength = 50
    )
    $Slug = $Text.ToLower() -replace '[^a-z0-9\s]', '' -replace '\s+', '-' -replace '-+', '-'
    $Slug = $Slug.Trim('-')
    if ($Slug.Length -gt $MaxLength) {
        $Slug = $Slug.Substring(0, $MaxLength).TrimEnd('-')
    }
    return $Slug
}

# ============================================
# Write-Banner
# Prints a styled section banner.
# ============================================
function Write-Banner {
    param([Parameter(Mandatory)][string]$Text)
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# Write-CheckPass / Write-CheckFail
# Standardized health check output.
# ============================================
function Write-CheckPass {
    param(
        [Parameter(Mandatory)][string]$Component,
        [string]$Detail = ""
    )
    $msg = "[OK]   $Component"
    if ($Detail) { $msg += " - $Detail" }
    Write-Host $msg -ForegroundColor Green
}

function Write-CheckFail {
    param(
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Expected,
        [Parameter(Mandatory)][string]$Actual
    )
    Write-Host "[FAIL] ${Component}: expected $Expected, found $Actual" -ForegroundColor Red
}
