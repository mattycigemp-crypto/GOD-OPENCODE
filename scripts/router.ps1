# ============================================
# GOD-OPENCODE ROUTER ENGINE
# Version 1.0
# ============================================
# Usage: Invoke-Router -Request "build a fastapi api"
# Returns: hashtable with SelectedAgent, Candidates, Skills, Fallback

$ErrorActionPreference = "Stop"

function Invoke-Router {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Request
    )

    $Root = Split-Path $PSScriptRoot -Parent
    $RouterConfig = Join-Path $Root "router\agent-router.json"

    # Load routing config
    if (!(Test-Path $RouterConfig)) {
        Write-Warning "[ROUTER] agent-router.json not found. Defaulting to principal-engineer."
        return @{
            SelectedAgent = "principal-engineer"
            Candidates    = @(@{ Agent = "principal-engineer"; Score = 0 })
            Skills        = @()
            Fallback      = $true
            Notice        = "Router config not found. Defaulted to principal-engineer."
        }
    }

    $Config = Get-Content $RouterConfig -Raw | ConvertFrom-Json
    $Routing = $Config.routing

    # Tokenize request — lowercase words, strip punctuation
    $Tokens = $Request.ToLower() -replace '[^a-z0-9\-\s]', '' -split '\s+' | Where-Object { $_ -ne '' }

    # Count keyword matches per agent
    $AgentScores = @{}

    foreach ($Token in $Tokens) {
        $Props = $Routing.PSObject.Properties | Where-Object { $_.Name -eq $Token }
        foreach ($Prop in $Props) {
            $AgentName = $Prop.Value
            if ($AgentScores.ContainsKey($AgentName)) {
                $AgentScores[$AgentName]++
            } else {
                $AgentScores[$AgentName] = 1
            }
        }
    }

    # Handle fallback — no matches
    if ($AgentScores.Count -eq 0) {
        Write-Host "[INFO] No routing match found for request. Defaulting to principal-engineer." -ForegroundColor Yellow
        return @{
            SelectedAgent = "principal-engineer"
            Candidates    = @(@{ Agent = "principal-engineer"; Score = 0 })
            Skills        = Get-AgentSkills "principal-engineer" $Root
            Fallback      = $true
            Notice        = "No routing match found. Defaulted to principal-engineer."
        }
    }

    # Sort by score descending, take top 3
    $Sorted = $AgentScores.GetEnumerator() |
        Sort-Object Value -Descending

    $Top3 = $Sorted | Select-Object -First 3 | ForEach-Object {
        @{ Agent = $_.Key; Score = $_.Value }
    }

    $Selected = $Top3[0].Agent

    # Load skills from selected agent
    $Skills = Get-AgentSkills $Selected $Root

    return @{
        SelectedAgent = $Selected
        Candidates    = $Top3
        Skills        = $Skills
        Fallback      = $false
        Notice        = $null
    }
}


function Get-AgentSkills {
    param(
        [string]$AgentName,
        [string]$Root
    )

    $AgentFile = Join-Path $Root "agents\$AgentName\AGENT.md"

    if (!(Test-Path $AgentFile)) {
        return @()
    }

    $Lines = Get-Content $AgentFile
    $InSkills = $false
    $Skills = @()

    foreach ($Line in $Lines) {
        if ($Line -match '^## Skills') {
            $InSkills = $true
            continue
        }
        if ($InSkills -and $Line -match '^##') {
            break
        }
        if ($InSkills -and $Line -match '^\s*-\s+(.+)') {
            $Skills += $Matches[1].Trim()
        }
    }

    return $Skills
}


# ============================================
# DIRECT INVOCATION (non-import mode)
# ============================================
if ($MyInvocation.InvocationName -ne '.') {

    param(
        [string]$Request = ""
    )

    if ($Request -eq "") {
        Write-Host ""
        Write-Host "Usage: .\scripts\router.ps1 -Request 'describe your task here'"
        Write-Host ""
        exit
    }

    $Result = Invoke-Router -Request $Request

    Write-Host ""
    Write-Host "=============================="
    Write-Host "  GOD-OPENCODE ROUTER RESULT"
    Write-Host "=============================="
    Write-Host ""
    Write-Host "Selected Agent : $($Result.SelectedAgent)"
    Write-Host "Fallback       : $($Result.Fallback)"

    if ($Result.Notice) {
        Write-Host "Notice         : $($Result.Notice)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Top Candidates:"
    foreach ($C in $Result.Candidates) {
        Write-Host "  $($C.Agent) (score: $($C.Score))"
    }

    Write-Host ""
    Write-Host "Skills Loaded:"
    foreach ($S in $Result.Skills) {
        Write-Host "  - $S"
    }

    Write-Host ""
}
