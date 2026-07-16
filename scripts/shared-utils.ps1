# ============================================
# GOD-OPENCODE SHARED UTILITIES
# Version 1.0
# ============================================
# Dot-source this module in any GOD-OPENCODE script:
#   . "$PSScriptRoot\shared-utils.ps1"

$ErrorActionPreference = "Continue"

# ============================================
# EnsureFolder
# Creates a directory if it doesn't exist.
# ============================================
function EnsureFolder {
    param([Parameter(Mandatory)][string]$Folder)
    if (!(Test-Path $Folder)) {
        New-Item -ItemType Directory -Path $Folder -Force | Out-Null
        Write-Host "[CREATED] $Folder" -ForegroundColor Cyan
    } else {
        Write-Host "[EXISTS]  $Folder" -ForegroundColor DarkGray
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
        } else {
            Write-Host "[SKIP]    $Path" -ForegroundColor DarkGray
        }
    }
}

# ============================================
# RunStep
# Executes a sub-script by name from $Scripts.
# Wraps execution in try/catch — logs failure
# and continues. Never aborts the pipeline.
# Returns $true on success, $false on failure.
# ============================================
function RunStep {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Script,
        [string]$ScriptsDir = (Join-Path (Split-Path $PSScriptRoot -Parent) "scripts")
    )

    Write-Host ""
    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------" -ForegroundColor DarkGray

    $Path = Join-Path $ScriptsDir $Script

    if (!(Test-Path $Path)) {
        Write-Host "[SKIPPED] $Script not found at $Path" -ForegroundColor Yellow
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
    param([Parameter(Mandatory)][string]$Text, [int]$MaxLength = 50)
    $Slug = $Text.ToLower() -replace '[^a-z0-9\s]', '' -replace '\s+', '-' -replace '-+', '-'
    $Slug = $Slug.Trim('-')
    if ($Slug.Length -gt $MaxLength) { $Slug = $Slug.Substring(0, $MaxLength).TrimEnd('-') }
    return $Slug
}
