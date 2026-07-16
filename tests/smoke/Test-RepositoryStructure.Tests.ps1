# Feature: god-opencode
# Smoke tests - verify the repository structure is complete and well-formed.
# Run: Invoke-Pester -Path .\tests\smoke\ -Output Detailed

BeforeAll {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

Describe "Required directories" {
    $RequiredDirs = @(
        "agents","backups","commands","config","logs","mcps",
        "memory","models","prompts","router","scripts","skills",
        "templates","tools","workflows"
    )
    It "Directory '<dir>' exists" -ForEach ($RequiredDirs | ForEach-Object { @{ dir = $_ } }) {
        Test-Path (Join-Path $Root $dir) | Should -BeTrue
    }
}

Describe "Required root files" {
    $RequiredFiles = @(
        "god-install.ps1","god-health.ps1","god-backup.ps1",
        "install.ps1","README.md","CONTRIBUTING.md","CHANGELOG.md","LICENSE"
    )
    It "File '<file>' exists" -ForEach ($RequiredFiles | ForEach-Object { @{ file = $_ } }) {
        Test-Path (Join-Path $Root $file) | Should -BeTrue
    }
}

Describe "Required scripts" {
    $RequiredScripts = @(
        "scripts\god-builder.ps1","scripts\god-expansion.ps1",
        "scripts\god-intelligence.ps1","scripts\upgrade-all-skills.ps1",
        "scripts\install-mcps.ps1","scripts\router.ps1",
        "scripts\memory.ps1","scripts\workflow-engine.ps1",
        "scripts\shared-utils.ps1","tools\project-scan.ps1"
    )
    It "Script '<script>' exists" -ForEach ($RequiredScripts | ForEach-Object { @{ script = $_ } }) {
        Test-Path (Join-Path $Root $script) | Should -BeTrue
    }
}

Describe "Router config is valid JSON with routing rules" {
    # Property 3+4: Router config must be valid JSON with at least one routing rule
    It "router/agent-router.json parses as valid JSON" {
        $Path = Join-Path $Root "router\agent-router.json"
        { Get-Content $Path -Raw | ConvertFrom-Json } | Should -Not -Throw
    }
    It "router/agent-router.json contains at least 1 routing rule" {
        $Config = Get-Content (Join-Path $Root "router\agent-router.json") -Raw | ConvertFrom-Json
        ($Config.routing.PSObject.Properties | Measure-Object).Count | Should -BeGreaterThan 0
    }
}

Describe "MCP registry is valid JSON" {
    It "mcps/registry.json parses as valid JSON" {
        $Path = Join-Path $Root "mcps\registry.json"
        { Get-Content $Path -Raw | ConvertFrom-Json } | Should -Not -Throw
    }
    It "mcps/registry.json contains at least 1 server entry" {
        $Config = Get-Content (Join-Path $Root "mcps\registry.json") -Raw | ConvertFrom-Json
        ($Config.servers.PSObject.Properties | Measure-Object).Count | Should -BeGreaterThan 0
    }
}

Describe "README section completeness" {
    # Property 21: README must contain all five required sections
    BeforeAll {
        $ReadmePath = Join-Path $Root "README.md"
        $script:ReadmeContent = Get-Content $ReadmePath -Raw
    }
    It "README contains project purpose section" {
        $ReadmeContent | Should -Match "Project Purpose|## Purpose"
    }
    It "README contains architecture overview" {
        $ReadmeContent | Should -Match "Architecture"
    }
    It "README contains installation instructions" {
        $ReadmeContent | Should -Match "Installation|Install"
    }
    It "README contains quick start example" {
        $ReadmeContent | Should -Match "Quick Start|Quickstart"
    }
    It "README contains contribution guidelines" {
        $ReadmeContent | Should -Match "Contribut"
    }
}

Describe "Template directories have README.md" {
    # Property 18: Every template must include a README.md
    It "Template '<name>' has README.md" -ForEach @(
        Get-ChildItem (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path "templates") -Directory |
            ForEach-Object { @{ name = $_.Name; path = $_.FullName } }
    ) {
        Test-Path (Join-Path $path "README.md") | Should -BeTrue
    }
}

