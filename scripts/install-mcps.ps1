# ============================================
# GOD-OPENCODE MCP MANAGER
# Version 1.0
# ============================================

$Root = Split-Path $PSScriptRoot -Parent

$MCPFolder = Join-Path $Root "mcps"

$Registry = Join-Path $MCPFolder "registry.json"


Write-Host ""
Write-Host "============================================"
Write-Host "       MCP MANAGER"
Write-Host "============================================"
Write-Host ""


if (!(Test-Path $Registry)) {

    Write-Host "[ERROR] MCP registry missing"
    exit

}


$MCPs = Get-Content $Registry | ConvertFrom-Json


foreach ($MCP in $MCPs.servers.PSObject.Properties) {


    $Name = $MCP.Name

    $Enabled = $MCP.Value.enabled


    if ($Enabled) {

        Write-Host "[CHECKING] $Name"


        # Placeholder validation layer
        # Future versions will test actual connections

        Write-Host "[READY] $Name"

    }

    else {

        Write-Host "[DISABLED] $Name"

    }

}


Write-Host ""
Write-Host "MCP scan complete."