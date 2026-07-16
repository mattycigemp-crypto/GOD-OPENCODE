# Integration tests - require network/MCP environment.
# Tag: [Integration]
# Run: Invoke-Pester -Path .\tests\integration\ -Tag Integration -Output Detailed

BeforeDiscovery {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
    $RegistryPath = Join-Path $Root "mcps\registry.json"
    $ConfigPath = Join-Path $Root "mcps\mcp-config.json"
}

Describe "MCP Connectivity and Configuration" -Tag Integration {
    It "registry.json exists" {
        $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
        $RegistryPath = Join-Path $Root "mcps\registry.json"
        Test-Path $RegistryPath | Should -BeTrue
    }

    It "mcp-config.json exists" {
        $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
        $ConfigPath = Join-Path $Root "mcps\mcp-config.json"
        Test-Path $ConfigPath | Should -BeTrue
    }

    It "MCPs enabled in registry are present in mcp-config.json" {
        $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
        $RegistryPath = Join-Path $Root "mcps\registry.json"
        $ConfigPath = Join-Path $Root "mcps\mcp-config.json"
        
        $Registry = $null
        if (Test-Path $RegistryPath) {
            $Registry = Get-Content $RegistryPath -Raw | ConvertFrom-Json
        }

        $Config = $null
        if (Test-Path $ConfigPath) {
            $Config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        }

        $Registry | Should -Not -BeNullOrEmpty
        $Config | Should -Not -BeNullOrEmpty

        $Registry.servers.PSObject.Properties | ForEach-Object {
            $ServerName = $_.Name
            $ServerData = $_.Value
            if ($ServerData.enabled -eq $true) {
                $ConfigServer = $Config.mcpServers.$ServerName
                $ConfigServer | Should -Not -BeNullOrEmpty
                $ConfigServer.enabled | Should -BeTrue
            }
        }
    }
}

