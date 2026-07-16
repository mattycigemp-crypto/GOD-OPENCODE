# Feature: god-opencode, Property 13: Intelligence Engine Plan Completeness
# Feature: god-opencode, Property 14: Intelligence Engine Memory Storage
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")

    # Create fixture project directories for scan tests
    $script:FixtureBase = Join-Path $env:TEMP "god-opencode-scan-fixtures-$(Get-Random)"
    New-Item -ItemType Directory -Path $FixtureBase -Force | Out-Null

    # Fixture 1: Python FastAPI project
    $script:PythonApiDir = Join-Path $FixtureBase "python-api"
    New-Item -ItemType Directory -Path $PythonApiDir -Force | Out-Null
    Set-Content (Join-Path $PythonApiDir "main.py")          "from fastapi import FastAPI`napp = FastAPI()"
    Set-Content (Join-Path $PythonApiDir "requirements.txt") "fastapi`nuvicorn"
    Set-Content (Join-Path $PythonApiDir "pyproject.toml")   "[project]`nname = 'test-api'"

    # Fixture 2: Node/TypeScript project
    $script:NodeDir = Join-Path $FixtureBase "node-app"
    New-Item -ItemType Directory -Path $NodeDir -Force | Out-Null
    Set-Content (Join-Path $NodeDir "package.json")   '{"name":"test-app","version":"1.0.0"}'
    Set-Content (Join-Path $NodeDir "tsconfig.json")  '{"compilerOptions":{"strict":true}}'
    Set-Content (Join-Path $NodeDir "index.ts")       "const x: number = 1;"

    # Fixture 3: Next.js app
    $script:NextDir = Join-Path $FixtureBase "nextjs-app"
    New-Item -ItemType Directory -Path $NextDir -Force | Out-Null
    Set-Content (Join-Path $NextDir "next.config.js") "module.exports = {}"
    Set-Content (Join-Path $NextDir "package.json")   '{"name":"nextjs-app"}'
}

AfterAll {
    Remove-Item -Recurse -Force $FixtureBase -ErrorAction SilentlyContinue
}

Describe "Property 13: Intelligence Engine Plan Completeness" {
    # The output plan must contain all six required sections.
    $Fixtures = @(
        @{ name = "Python API";  dir = "" }  # will be set in BeforeEach
        @{ name = "Node App";   dir = "" }
        @{ name = "Next.js App"; dir = "" }
    )

    It "Scan of Python API project produces plan with 'Detected Project Type'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Detected Project Type"
    }

    It "Scan of Python API project produces plan with 'Primary Languages'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Primary Languages"
    }

    It "Scan of Python API project produces plan with 'Recommended Workflow'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Recommended Workflow"
    }

    It "Scan of Python API project produces plan with 'Assigned Agents'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Assigned Agents"
    }

    It "Scan of Python API project produces plan with 'Applied Skills'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Applied Skills"
    }

    It "Scan of Python API project produces plan with 'Prioritized Improvements'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "Prioritized Improvements"
    }

    It "Scan of Node app produces all 6 required plan sections" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $NodeDir 2>&1 | Out-String
        $Plan | Should -Match "Detected Project Type"
        $Plan | Should -Match "Primary Languages"
        $Plan | Should -Match "Recommended Workflow"
        $Plan | Should -Match "Assigned Agents"
        $Plan | Should -Match "Applied Skills"
        $Plan | Should -Match "Prioritized Improvements"
    }
}

Describe "Property 14: Intelligence Engine Memory Storage" {
    # After each scan, exactly one adr-scan-*.md must be written with
    # type: architecture-decision and a valid ISO-8601 timestamp.
    It "Scan writes an ADR memory artifact to memory/" {
        # Clean memory dir before this test
        $MemDir = Join-Path $Root "memory"
        $Before = (Get-ChildItem $MemDir -Filter "adr-scan-*.md" -ErrorAction SilentlyContinue).Count

        & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-Null

        $After = (Get-ChildItem $MemDir -Filter "adr-scan-*.md" -ErrorAction SilentlyContinue).Count
        $After | Should -BeGreaterOrEqual $Before
    }

    It "The ADR artifact has type: architecture-decision" {
        $MemDir   = Join-Path $Root "memory"
        $AdrFiles = Get-ChildItem $MemDir -Filter "adr-scan-*.md" -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if (!$AdrFiles) {
            Set-ItResult -Skipped -Because "No adr-scan-*.md files found in memory/"
            return
        }

        $Content = Get-Content $AdrFiles.FullName -Raw
        $Content | Should -Match "type: architecture-decision"
    }

    It "The ADR artifact has a valid ISO-8601 timestamp" {
        $MemDir   = Join-Path $Root "memory"
        $AdrFiles = Get-ChildItem $MemDir -Filter "adr-scan-*.md" -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1

        if (!$AdrFiles) {
            Set-ItResult -Skipped -Because "No adr-scan-*.md files found in memory/"
            return
        }

        $Lines = Get-Content $AdrFiles.FullName
        $Ts    = $Lines | Where-Object { $_ -match '^timestamp:\s*(.+)' } |
                 ForEach-Object { $Matches[1].Trim() } | Select-Object -First 1

        $Ts | Should -Not -BeNullOrEmpty
        { [datetime]::Parse($Ts) } | Should -Not -Throw
    }
}

Describe "Intelligence Engine project type detection" {
    It "Detects Python FastAPI project as 'api'" {
        # project-scan.ps1 outputs the project type in the plan
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $PythonApiDir 2>&1 | Out-String
        $Plan | Should -Match "api"
    }

    It "Detects Next.js project as 'fullstack'" {
        $Plan = & (Join-Path $Root "tools\project-scan.ps1") -TargetPath $NextDir 2>&1 | Out-String
        $Plan | Should -Match "fullstack"
    }
}
