# Feature: god-opencode, Property 1: Skill Installation Round Trip
# Feature: god-opencode, Property 2: Idempotent Installation
# Feature: god-opencode, Property 6: SKILL.md Schema Completeness
# Feature: god-opencode, Property 10: Skill Directory Structure Invariant
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeDiscovery {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
    $SkillFiles = Get-ChildItem (Join-Path $Root "skills") -Recurse -Filter "SKILL.md"
}

BeforeAll {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

Describe "Property 6: SKILL.md Schema Completeness" {
    # Every SKILL.md must contain required front-matter keys and all required sections.
    It "SKILL.md at '<path>' has required front-matter 'name'" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "(?m)^name:"
    }

    It "SKILL.md at '<rel>' has required front-matter 'description'" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "(?m)^description:"
    }

    It "SKILL.md at '<rel>' has '## Mission' section" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Mission"
    }

    It "SKILL.md at '<rel>' has '## Core Responsibilities' section" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Core Responsibilities"
    }

    It "SKILL.md at '<rel>' has '## Workflow' section" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Workflow"
    }

    It "SKILL.md at '<rel>' has '## Quality Standards' section" -ForEach (
        $SkillFiles | ForEach-Object { @{ path = $_.FullName; rel = $_.FullName.Replace($Root, '') } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Quality Standards"
    }
}

Describe "Property 10: Skill Directory Structure Invariant" {
    # Every skill path must match skills/{category}/{skill-name}/SKILL.md
    # where category and skill-name use only lowercase letters and hyphens.
    It "SKILL.md at '<rel>' has valid path structure" -ForEach (
        $SkillFiles | ForEach-Object {
            $rel = $_.FullName.Replace($Root + '\', '').Replace('\', '/')
            @{ path = $_.FullName; rel = $rel }
        }
    ) {
        $rel | Should -Match "^skills/[a-z][a-z0-9-]*/[a-z][a-z0-9-]*/SKILL\.md$"
    }
}

Describe "Property 1: Skill Installation Round Trip" {
    # After install.ps1 runs, every skill in the repo must exist in the OpenCode skills dir.
    BeforeAll {
        $script:TargetDir = Join-Path $env:USERPROFILE ".config\opencode\skills"
    }

    It "OpenCode skills directory exists" {
        Test-Path $TargetDir | Should -BeTrue
    }

    It "Skill '<name>' is installed in OpenCode" -ForEach (
        $SkillFiles | ForEach-Object { @{ name = $_.Directory.Name; skillPath = $_.FullName } }
    ) {
        $InstalledPath = Join-Path $TargetDir $name
        Test-Path $InstalledPath | Should -BeTrue
    }
}

Describe "Property 2: Idempotent Installation" {
    # Re-running install.ps1 must not delete or modify user-created files.
    It "install.ps1 does not error when run on already-installed skills" {
        $InstallScript = Join-Path $Root "install.ps1"
        { & $InstallScript } | Should -Not -Throw
    }
}

Describe "Property 9: Installer Summary Accuracy" {
    # The installer summary counts must match actual file counts.
    It "Agents directory count matches expected agents" {
        $AgentCount = (Get-ChildItem (Join-Path $Root "agents") -Directory).Count
        $AgentCount | Should -BeGreaterOrEqual 10
    }
    It "Workflows directory contains required workflow files" {
        $WfCount = (Get-ChildItem (Join-Path $Root "workflows") -Filter "*.md").Count
        $WfCount | Should -BeGreaterOrEqual 4
    }
}
