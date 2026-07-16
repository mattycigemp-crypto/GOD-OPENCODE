# Feature: god-opencode, Property 7: AGENT.md Schema Completeness
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    $AgentFiles = Get-ChildItem (Join-Path $Root "agents") -Recurse -Filter "AGENT.md"
}

Describe "Property 7: AGENT.md Schema Completeness" {
    # Every AGENT.md must contain all four required sections.
    It "AGENT.md for '<agent>' has '## Role' section" -ForEach (
        $AgentFiles | ForEach-Object { @{ path = $_.FullName; agent = $_.Directory.Name } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Role"
    }

    It "AGENT.md for '<agent>' has '## Responsibilities' section" -ForEach (
        $AgentFiles | ForEach-Object { @{ path = $_.FullName; agent = $_.Directory.Name } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Responsibilities"
    }

    It "AGENT.md for '<agent>' has '## Standards' section" -ForEach (
        $AgentFiles | ForEach-Object { @{ path = $_.FullName; agent = $_.Directory.Name } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Standards"
    }

    It "AGENT.md for '<agent>' has '## Skills' section" -ForEach (
        $AgentFiles | ForEach-Object { @{ path = $_.FullName; agent = $_.Directory.Name } }
    ) {
        $Content = Get-Content $path -Raw
        $Content | Should -Match "## Skills"
    }

    It "AGENT.md for '<agent>' has at least one skill listed" -ForEach (
        $AgentFiles | ForEach-Object { @{ path = $_.FullName; agent = $_.Directory.Name } }
    ) {
        $Lines     = Get-Content $path
        $InSkills  = $false
        $SkillCount = 0
        foreach ($Line in $Lines) {
            if ($Line -match '^## Skills')             { $InSkills = $true; continue }
            if ($InSkills -and $Line -match '^## ')    { break }
            if ($InSkills -and $Line -match '^\s*-\s') { $SkillCount++ }
        }
        $SkillCount | Should -BeGreaterThan 0
    }
}

Describe "All 10 required agents are present" {
    $RequiredAgents = @(
        "principal-engineer","backend-engineer","frontend-engineer",
        "ai-engineer","security-engineer","database-architect",
        "devops-engineer","debugger","researcher","technical-writer"
    )
    It "Agent '<agent>' has an AGENT.md file" -ForEach (
        $RequiredAgents | ForEach-Object { @{ agent = $_ } }
    ) {
        $AgentPath = Join-Path $Root "agents\$agent\AGENT.md"
        Test-Path $AgentPath | Should -BeTrue
    }
}
