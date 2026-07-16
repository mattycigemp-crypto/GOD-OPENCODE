# ============================================
# GOD-OPENCODE WORKFLOW ENGINE
# Version 1.0
# ============================================
# Usage: Invoke-WorkflowSubstitution -WorkflowName "build-application" -Params @{ PROJECT_NAME = "MyApp"; STACK = "FastAPI + React" }

$ErrorActionPreference = "Stop"

function Invoke-WorkflowSubstitution {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkflowName,

        [Parameter(Mandatory=$true)]
        [hashtable]$Params
    )

    $Root = Split-Path $PSScriptRoot -Parent
    $WorkflowFile = Join-Path $Root "workflows\$WorkflowName.md"

    if (!(Test-Path $WorkflowFile)) {
        throw "[WORKFLOW] Workflow '$WorkflowName' not found at $WorkflowFile"
    }

    $Content = Get-Content $WorkflowFile -Raw

    # Substitute all {{PARAM_NAME}} placeholders
    foreach ($Key in $Params.Keys) {
        $Content = $Content -replace "\{\{$Key\}\}", $Params[$Key]
    }

    # Check for unresolved placeholders
    $Unresolved = [regex]::Matches($Content, '\{\{[A-Z_]+\}\}') | ForEach-Object { $_.Value } | Sort-Object -Unique

    if ($Unresolved.Count -gt 0) {
        throw "[WORKFLOW] Unresolved placeholders in '$WorkflowName': $($Unresolved -join ', '). Provide values for all required parameters."
    }

    return $Content
}


function Get-WorkflowSteps {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkflowName
    )

    $Root = Split-Path $PSScriptRoot -Parent
    $WorkflowFile = Join-Path $Root "workflows\$WorkflowName.md"

    if (!(Test-Path $WorkflowFile)) {
        throw "[WORKFLOW] Workflow '$WorkflowName' not found."
    }

    $Lines = Get-Content $WorkflowFile
    $Steps = @()
    $CurrentStep = $null

    foreach ($Line in $Lines) {
        if ($Line -match '^### Step (\d+):?\s*(.*)') {
            if ($CurrentStep) { $Steps += $CurrentStep }
            $CurrentStep = @{
                Number = [int]$Matches[1]
                Title  = $Matches[2].Trim()
                Agent  = ""
                Skills = @()
                Action = ""
            }
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Agent:\s*(.+)') {
            $CurrentStep.Agent = $Matches[1].Trim()
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Skills:\s*\[(.+)\]') {
            $CurrentStep.Skills = $Matches[1].Trim() -split ',\s*'
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Action:\s*(.+)') {
            $CurrentStep.Action = $Matches[1].Trim()
        }
    }

    if ($CurrentStep) { $Steps += $CurrentStep }

    return $Steps
}


function Invoke-Workflow {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WorkflowName,

        [hashtable]$Params = @{}
    )

    Write-Host ""
    Write-Host "======================================"
    Write-Host "  WORKFLOW: $WorkflowName"
    Write-Host "======================================"
    Write-Host ""

    # Substitute parameters if provided
    if ($Params.Count -gt 0) {
        $ResolvedContent = Invoke-WorkflowSubstitution -WorkflowName $WorkflowName -Params $Params
        Write-Host "[WORKFLOW] Parameters substituted successfully."
    }

    # Load and display steps
    $Steps = Get-WorkflowSteps -WorkflowName $WorkflowName

    Write-Host "Steps ($($Steps.Count) total):"
    Write-Host ""

    foreach ($Step in $Steps) {
        Write-Host "  [$($Step.Number)] $($Step.Title)"
        if ($Step.Agent)  { Write-Host "       Agent  : $($Step.Agent)" }
        if ($Step.Skills.Count -gt 0) { Write-Host "       Skills : $($Step.Skills -join ', ')" }
        if ($Step.Action) { Write-Host "       Action : $($Step.Action)" }
        Write-Host ""
    }

    return $Steps
}


# ============================================
# DIRECT INVOCATION
# ============================================
if ($MyInvocation.InvocationName -ne '.') {

    param(
        [string]$WorkflowName = ""
    )

    if ($WorkflowName -eq "") {
        Write-Host ""
        Write-Host "Usage: .\scripts\workflow-engine.ps1 -WorkflowName 'build-application'"
        Write-Host ""
        $Root = Split-Path $PSScriptRoot -Parent
        Write-Host "Available workflows:"
        Get-ChildItem (Join-Path $Root "workflows") -Filter "*.md" | ForEach-Object {
            Write-Host "  - $($_.BaseName)"
        }
        Write-Host ""
        exit
    }

    Invoke-Workflow -WorkflowName $WorkflowName
}
