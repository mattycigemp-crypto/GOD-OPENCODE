# ============================================
# GOD-OPENCODE MEMORY SYSTEM
# Version 1.1
# ============================================
# Dot-source or call directly.
# Functions: New-MemoryArtifact, Get-MemoryArtifacts, Show-MemoryList

$ErrorActionPreference = "Stop"

function New-MemoryArtifact {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("architecture-decision","coding-convention","todo","changelog","assumption")]
        [string]$Type,
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$Author,
        [Parameter(Mandatory=$true)][string]$Content,
        [string]$MemoryDir = ""
    )

    if ($MemoryDir -eq "") {
        $Root = Split-Path $PSScriptRoot -Parent
        $MemoryDir = Join-Path $Root "memory"
    }

    if (!(Test-Path $MemoryDir)) {
        New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null
    }

    $Slug = $Title.ToLower() -replace '[^a-z0-9\s]', '' -replace '\s+', '-' -replace '-+', '-'
    $Slug = $Slug.Trim('-')
    if ($Slug.Length -gt 40) { $Slug = $Slug.Substring(0, 40).TrimEnd('-') }

    $Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    $FilePath  = Join-Path $MemoryDir "$Type-$Slug.md"

    if (Test-Path $FilePath) {
        $Append = "`n`n---`n`n## Update - $Timestamp`n`n_Author: ${Author}_`n`n$Content"
        Add-Content -Path $FilePath -Value $Append
        Write-Host "[MEMORY] Updated: $FilePath"
    } else {
        $Body = "---`ntype: $Type`ntitle: $Title`ntimestamp: $Timestamp`nauthor: $Author`n---`n`n# $Title`n`n$Content"
        [System.IO.File]::WriteAllText($FilePath, $Body)
        Write-Host "[MEMORY] Created: $FilePath"
    }

    return $FilePath
}

function Get-MemoryArtifacts {
    param([string]$MemoryDir = "")

    if ($MemoryDir -eq "") {
        $Root = Split-Path $PSScriptRoot -Parent
        $MemoryDir = Join-Path $Root "memory"
    }

    if (!(Test-Path $MemoryDir)) { return @() }

    $Files     = Get-ChildItem -Path $MemoryDir -Filter "*.md" -File
    $Artifacts = @()

    foreach ($File in $Files) {
        $Lines = Get-Content $File.FullName -TotalCount 12
        $A = @{ Type = ""; Title = ""; Timestamp = ""; Author = ""; Path = $File.FullName }
        foreach ($Line in $Lines) {
            if ($Line -match '^type:\s*(.+)')      { $A.Type      = $Matches[1].Trim() }
            if ($Line -match '^title:\s*(.+)')     { $A.Title     = $Matches[1].Trim() }
            if ($Line -match '^timestamp:\s*(.+)') { $A.Timestamp = $Matches[1].Trim() }
            if ($Line -match '^author:\s*(.+)')    { $A.Author    = $Matches[1].Trim() }
        }
        $Artifacts += $A
    }

    return $Artifacts
}

function Show-MemoryList {
    $Artifacts = Get-MemoryArtifacts
    if ($Artifacts.Count -eq 0) { Write-Host "No memory artifacts found."; return }

    Write-Host ""
    Write-Host "======================================"
    Write-Host "  GOD-OPENCODE MEMORY"
    Write-Host "======================================"
    Write-Host ("{0,-25} {1,-35} {2,-22} {3}" -f "TYPE","TITLE","TIMESTAMP","AUTHOR")
    Write-Host ("-" * 90)

    foreach ($A in $Artifacts) {
        $T  = if ($A.Type.Length      -gt 24) { $A.Type.Substring(0,24)       } else { $A.Type      }
        $Ti = if ($A.Title.Length     -gt 34) { $A.Title.Substring(0,34)      } else { $A.Title     }
        $Ts = if ($A.Timestamp.Length -gt 21) { $A.Timestamp.Substring(0,21)  } else { $A.Timestamp }
        Write-Host ("{0,-25} {1,-35} {2,-22} {3}" -f $T, $Ti, $Ts, $A.Author)
    }

    Write-Host ""
    Write-Host "Total: $($Artifacts.Count) artifact(s)"
    Write-Host ""
}

# Direct invocation guard
if ($MyInvocation.InvocationName -ne '.') {
    Show-MemoryList
}
