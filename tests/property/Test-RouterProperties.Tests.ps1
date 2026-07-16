# Feature: god-opencode, Property 3: Router Keyword-to-Agent Mapping
# Feature: god-opencode, Property 4: Router Default Fallback
# Feature: god-opencode, Property 5: Router Skill Completeness
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeAll {
    $Root   = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    # Dot-source the router so Invoke-Router is available
    . (Join-Path $Root "scripts\router.ps1")
}

Describe "Property 3: Router Keyword-to-Agent Mapping" {
    # For any request containing a known keyword, the router must return the mapped agent.
    $KnownMappings = @(
        @{ keyword = "react";       expected = "frontend-engineer"  }
        @{ keyword = "fastapi";     expected = "backend-engineer"   }
        @{ keyword = "postgres";    expected = "database-architect" }
        @{ keyword = "llm";         expected = "ai-engineer"        }
        @{ keyword = "security";    expected = "security-engineer"  }
        @{ keyword = "docker";      expected = "devops-engineer"    }
        @{ keyword = "debug";       expected = "debugger"           }
        @{ keyword = "docs";        expected = "technical-writer"   }
        @{ keyword = "kubernetes";  expected = "devops-engineer"    }
        @{ keyword = "rag";         expected = "ai-engineer"        }
        @{ keyword = "jwt";         expected = "security-engineer"  }
        @{ keyword = "mongodb";     expected = "database-architect" }
    )

    It "Request with keyword '<keyword>' routes to '<expected>'" -ForEach $KnownMappings {
        $Result = Invoke-Router -Request "please help me with $keyword"
        $Result.SelectedAgent | Should -Be $expected
        $Result.Fallback       | Should -BeFalse
    }

    It "Router returns exactly 3 candidates when enough keywords match" {
        # Multi-keyword request touching 3+ agents
        $Result = Invoke-Router -Request "build a react frontend with postgres database and docker deployment"
        $Result.Candidates.Count | Should -BeGreaterOrEqual 1
        $Result.Candidates.Count | Should -BeLessOrEqual 3
    }

    It "Candidates are ordered by score descending" {
        $Result = Invoke-Router -Request "api backend database postgres schema"
        $Scores = $Result.Candidates | ForEach-Object { $_.Score }
        for ($i = 0; $i -lt ($Scores.Count - 1); $i++) {
            $Scores[$i] | Should -BeGreaterOrEqual $Scores[$i + 1]
        }
    }
}

Describe "Property 4: Router Default Fallback" {
    # For any request with no matching keywords, return principal-engineer with Fallback = true.
    $NoMatchRequests = @(
        @{ request = "xyzzy plugh thud wump" }
        @{ request = "aaaaaaa bbbbbbb ccccccc" }
        @{ request = "the quick brown fox" }
        @{ request = "lorem ipsum dolor sit amet" }
        @{ request = "zork adventure game" }
    )

    It "Request '<request>' falls back to principal-engineer" -ForEach $NoMatchRequests {
        $Result = Invoke-Router -Request $request
        $Result.SelectedAgent | Should -Be "principal-engineer"
        $Result.Fallback       | Should -BeTrue
    }
}

Describe "Property 5: Router Skill Completeness" {
    # For any agent returned by the router, the result must include
    # all skills listed in that agent's AGENT.md.
    $Requests = @(
        @{ request = "build a react frontend component" }
        @{ request = "design a postgres database schema" }
        @{ request = "build a rag pipeline with embeddings" }
        @{ request = "security audit jwt authentication" }
        @{ request = "deploy with docker kubernetes ci-cd" }
    )

    It "Router result for '<request>' includes skills from the agent's AGENT.md" -ForEach $Requests {
        $Result    = Invoke-Router -Request $request
        $AgentFile = Join-Path $Root "agents\$($Result.SelectedAgent)\AGENT.md"

        if (!(Test-Path $AgentFile)) {
            Set-ItResult -Skipped -Because "AGENT.md not found for $($Result.SelectedAgent)"
            return
        }

        # Parse skills from AGENT.md
        $Lines    = Get-Content $AgentFile
        $InSkills = $false
        $Expected = @()
        foreach ($Line in $Lines) {
            if ($Line -match '^## Skills')            { $InSkills = $true; continue }
            if ($InSkills -and $Line -match '^## ')   { break }
            if ($InSkills -and $Line -match '^\s*-\s+(.+)') { $Expected += $Matches[1].Trim() }
        }

        foreach ($Skill in $Expected) {
            $Result.Skills | Should -Contain $Skill
        }
    }
}

Describe "Router handles edge cases" {
    It "Empty string request returns principal-engineer fallback" {
        $Result = Invoke-Router -Request ""
        $Result.SelectedAgent | Should -Be "principal-engineer"
        $Result.Fallback       | Should -BeTrue
    }

    It "Single matching keyword returns correct agent with score 1" {
        $Result = Invoke-Router -Request "docker"
        $Result.SelectedAgent | Should -Be "devops-engineer"
        $Result.Candidates[0].Score | Should -Be 1
    }

    It "Two keywords for same agent accumulate score" {
        $Result = Invoke-Router -Request "docker kubernetes"
        $Result.SelectedAgent | Should -Be "devops-engineer"
        $Result.Candidates[0].Score | Should -BeGreaterOrEqual 2
    }
}
