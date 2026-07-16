# Feature: god-opencode, Property 15: Health Check Failure Message Completeness
# Feature: god-opencode, Property 16: Health Check Success Count
# Feature: god-opencode, Property 8: Error Isolation (MCP Manager)
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
}

Describe "Property 15: Health Check Failure Message Completeness" {
    # Every [FAIL] line must contain: component name, expected state, actual state.
    It "Health check [FAIL] lines include component, expected, and found" {
        # Run health check and capture output
        $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "god-health.ps1") 2>&1 |
            Out-String

        $FailLines = $Output -split "`n" | Where-Object { $_ -match '^\[FAIL\]' }

        foreach ($Line in $FailLines) {
            # Must contain 'expected' keyword
            $Line | Should -Match "expected"
            # Must contain 'found' keyword
            $Line | Should -Match "found"
            # Must have a component name after [FAIL]
            $Line | Should -Match '^\[FAIL\]\s+\S+'
        }
    }
}

Describe "Property 16: Health Check Success Count" {
    # When all checks pass, the final line must include the count of verified components.
    It "Health check final line contains a numeric component count" {
        $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "god-health.ps1") 2>&1 |
            Out-String

        $FinalLine = ($Output -split "`n" | Where-Object { $_ -match '\d+ components' } | Select-Object -Last 1)
        $FinalLine | Should -Not -BeNullOrEmpty
        $FinalLine | Should -Match '\d+'
    }

    It "Health check exits with code 0 on clean installation" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "god-health.ps1") | Out-Null
        $LASTEXITCODE | Should -Be 0
    }
}

Describe "Property 8: MCP Manager error isolation" {
    # The MCP manager must process all enabled MCPs even if one fails.
    It "install-mcps.ps1 does not throw when processing all enabled MCPs" {
        { & (Join-Path $Root "scripts\install-mcps.ps1") } | Should -Not -Throw
    }

    It "install-mcps.ps1 processes all 5 required MCPs" {
        $Output = & (Join-Path $Root "scripts\install-mcps.ps1") 2>&1 | Out-String
        $RequiredMCPs = @("filesystem","github","playwright","context7","tavily")
        foreach ($MCP in $RequiredMCPs) {
            $Output | Should -Match $MCP
        }
    }
}

Describe "Health check verifies all 10 agents" {
    It "Health check output includes a check for each required agent" {
        $Output = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root "god-health.ps1") 2>&1 |
            Out-String

        $RequiredAgents = @(
            "principal-engineer","backend-engineer","frontend-engineer",
            "ai-engineer","security-engineer","database-architect",
            "devops-engineer","debugger","researcher","technical-writer"
        )
        foreach ($Agent in $RequiredAgents) {
            $Output | Should -Match $Agent
        }
    }
}
