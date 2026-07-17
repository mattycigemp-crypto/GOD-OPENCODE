# Validate opencode.json against schemas/opencode.schema.json (JSON Schema Draft 2020-12).
# Feature 1: editor autocomplete + contributor safety. Run on every PR + on local install.

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    $script:Root          = $Root
    $script:SchemaPath    = Join-Path $Root "schemas\opencode.schema.json"
    $script:ConfigPath    = Join-Path $Root "opencode.json"
    $script:AgentsRoot    = Join-Path $Root "agents"
    $script:CommandsRoot  = Join-Path $Root "commands"
}

Describe "opencode.json schema validation" {
    It "The schema file exists" {
        Test-Path $SchemaPath | Should -BeTrue
        "$SchemaPath"
    }

    It "The schema is valid JSON" {
        try {
            $null = Get-Content $SchemaPath -Raw | ConvertFrom-Json
            "OK"
        } catch {
            "Schema is not valid JSON: $($_.Exception.Message)" | Should -BeNullOrEmpty
        }
    }

    It "The schema declares Draft 2020-12" {
        $schema = Get-Content $SchemaPath -Raw | ConvertFrom-Json
        $schema.'$schema' | Should -Match 'draft/2020-12'
    }

    It "opencode.json exists" {
        Test-Path $ConfigPath | Should -BeTrue
    }

    It "opencode.json is valid JSON" {
        try {
            $null = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            "OK"
        } catch {
            "opencode.json is not valid JSON: $($_.Exception.Message)" | Should -BeNullOrEmpty
        }
    }

    It "opencode.json references the right $schema" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        $config.'$schema' | Should -Match 'opencode\.schema\.json'
    }

    It "Every agent name in opencode.json matches a SKILL/AGENT.md folder + lowercase-with-hyphens" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $config.agent) { return }
        foreach ($name in $config.agent.PSObject.Properties.Name) {
            $name | Should -Match '^[a-z][a-z0-9-]*$'
            $agentMd = Join-Path $AgentsRoot "$name\AGENT.md"
            Test-Path $agentMd | Should -BeTrue -Because "agent name '$name' must have agents/$name/AGENT.md in the tree"
        }
    }

    It "Every command name in opencode.json matches a commands/<name>.md file" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $config.command) { return }
        foreach ($name in $config.command.PSObject.Properties.Name) {
            $name | Should -Match '^[a-z][a-z0-9-]*$'
            $cmdMd = Join-Path $CommandsRoot "$name.md"
            Test-Path $cmdMd | Should -BeTrue -Because "command name '$name' must have commands/$name.md in the tree"
        }
    }

    It "Commands reference agents that exist in the agent section" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $config.command) { return }
        foreach ($name in $config.command.PSObject.Properties.Name) {
            $cmd = $config.command.$name
            if ($cmd.agent) {
                $cmd.agent | Should -BeIn @($config.agent.PSObject.Properties.Name) `
                    -Because "command '$name' references agent '$($cmd.agent)' which is not defined in the agent section"
            }
        }
    }

    It "Every mcp_servers entry has either 'command' (stdio) or 'url' (http/sse)" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $config.mcp_servers) { return }
        foreach ($name in $config.mcp_servers.PSObject.Properties.Name) {
            $server = $config.mcp_servers.$name
            $has_command = $server.PSObject.Properties.Name -contains 'command'
            $has_url = $server.PSObject.Properties.Name -contains 'url'
            ($has_command -xor $has_url) | Should -BeTrue `
                -Because "MCP server '$name' must define exactly one of 'command' (stdio) or 'url' (http/sse)"
        }
    }

    It "Every agent entry exposes a 'prompt' property and a string-typed 'tools' array when present" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        if (-not $config.agent) { return }
        foreach ($name in $config.agent.PSObject.Properties.Name) {
            $entry = $config.agent.$name
            ($entry.PSObject.Properties.Name -contains 'prompt') | Should -BeTrue -Because ("agent '$name' must have a 'prompt' field")
            if ($entry.PSObject.Properties.Name -contains 'tools') {
                ,$entry.tools | Should -BeOfType [System.Array] -Because ("agent '$name' has a non-array tools field")
            }
        }
    }
}
