# Integration tests - require a working installation.
# Tag: [Integration]
# Run: Invoke-Pester -Path .\tests\integration\ -Tag Integration -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    $SkillsTarget = Join-Path $env:USERPROFILE ".config\opencode\skills"
}

Describe "Full install pipeline" -Tag Integration {
    It "god-install.ps1 runs without throwing" {
        { & (Join-Path $Root "god-install.ps1") } | Should -Not -Throw
    }

    It "All 15 required directories exist after install" {
        $Required = @(
            "agents","backups","commands","config","logs","mcps",
            "memory","models","prompts","router","scripts","skills",
            "templates","tools","workflows"
        )
        foreach ($Dir in $Required) {
            Test-Path (Join-Path $Root $Dir) | Should -BeTrue
        }
    }

    It "install.ps1 copies skills to OpenCode skills directory" {
        & (Join-Path $Root "install.ps1") | Out-Null
        Test-Path $SkillsTarget | Should -BeTrue
        (Get-ChildItem $SkillsTarget -Directory).Count | Should -BeGreaterThan 0
    }

    It "Skill count in OpenCode matches skill count in repo" {
        $RepoCount   = (Get-ChildItem (Join-Path $Root "skills") -Recurse -Filter "SKILL.md").Count
        $InstCount   = (Get-ChildItem $SkillsTarget -Directory -ErrorAction SilentlyContinue).Count
        # Installed count should be >= repo count (may include previously installed skills)
        $InstCount | Should -BeGreaterOrEqual $RepoCount
    }
}

Describe "Health check passes after install" -Tag Integration {
    It "god-health.ps1 exits with code 0" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "god-health.ps1") | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
}

Describe "Router returns expected agents after install" -Tag Integration {
    BeforeAll {
        . (Join-Path $Root "scripts\router.ps1")
    }

    It "Router returns backend-engineer for API request" {
        (Invoke-Router -Request "build an api endpoint").SelectedAgent | Should -Be "backend-engineer"
    }

    It "Router returns ai-engineer for LLM request" {
        (Invoke-Router -Request "build a rag pipeline with llm").SelectedAgent | Should -Be "ai-engineer"
    }

    It "Router loads skills from agent AGENT.md" {
        $Result = Invoke-Router -Request "react frontend component"
        $Result.Skills.Count | Should -BeGreaterThan 0
    }
}

Describe "Intelligence Engine scan of GOD-OPENCODE repo" -Tag Integration {
    It "project-scan.ps1 completes without error on the repo itself" {
        { & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $Root 2>&1 | Out-Null } | Should -Not -Throw
    }

    It "Scan output contains all required plan sections" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $Root 2>&1 | Out-String
        $Plan | Should -Match "Detected Project Type"
        $Plan | Should -Match "Recommended Workflow"
        $Plan | Should -Match "Assigned Agents"
        $Plan | Should -Match "Prioritized Improvements"
    }
}

