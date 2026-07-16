# Feature: god-opencode, Property 11: Memory Artifact Timestamp and Author Invariant
# Feature: god-opencode, Property 12: Memory List Completeness
# Run: Invoke-Pester -Path .\tests\unit\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    . (Join-Path $Root "scripts\memory.ps1")

    # Use a temp directory for all memory tests to avoid touching real memory/
    $script:TempMemDir = Join-Path $env:TEMP "god-opencode-mem-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $TempMemDir -Force | Out-Null

    # Override the root so New-MemoryArtifact writes to temp dir
    function Get-TestMemDir { return $script:TempMemDir }
}

AfterAll {
    Remove-Item -Recurse -Force $TempMemDir -ErrorAction SilentlyContinue
}

Describe "Property 11: Memory Artifact Timestamp and Author Invariant" {
    # Creating an artifact must always produce a file with a non-empty ISO-8601 timestamp
    # and a non-empty author field in the YAML front-matter.

    $TestCases = 1..10 | ForEach-Object {
        @{
            n       = $_
            type    = (@("architecture-decision","coding-convention","todo","changelog","assumption") | Get-Random)
            title   = "Test Artifact $_ $(Get-Random)"
            author  = "test-agent-$_"
            content = "Test content for artifact $_"
        }
    }

    It "Artifact <n> (<type>) has non-empty 'timestamp' front-matter" -ForEach $TestCases {
        $FilePath = New-MemoryArtifact `
            -Type $type -Title $title -Author $author -Content $content `
            -MemoryDir $TempMemDir

        $Lines = Get-Content $FilePath
        $Timestamp = $Lines | Where-Object { $_ -match '^timestamp:\s*(.+)' } |
            ForEach-Object { $Matches[1].Trim() } | Select-Object -First 1

        $Timestamp | Should -Not -BeNullOrEmpty
        # Must be parseable as a date
        { [datetime]::Parse($Timestamp) } | Should -Not -Throw
    }

    It "Artifact <n> (<type>) has non-empty 'author' front-matter" -ForEach $TestCases {
        # File already created above — read any matching file for this author
        $Files = Get-ChildItem $TempMemDir -Filter "*.md"
        $MatchingFile = $Files | Where-Object {
            (Get-Content $_.FullName | Where-Object { $_ -match "author:\s*$author" })
        } | Select-Object -First 1

        $MatchingFile | Should -Not -BeNullOrEmpty
        $Lines = Get-Content $MatchingFile.FullName
        $AuthorVal = $Lines | Where-Object { $_ -match '^author:\s*(.+)' } |
            ForEach-Object { $Matches[1].Trim() } | Select-Object -First 1
        $AuthorVal | Should -Not -BeNullOrEmpty
    }
}

Describe "Property 12: Memory List Completeness" {
    # Get-MemoryArtifacts must return exactly one entry per .md file,
    # each with type, title, and timestamp fields.

    BeforeAll {
        # Seed a clean temp dir with N known artifacts
        $script:ListTestDir = Join-Path $env:TEMP "god-opencode-list-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $ListTestDir -Force | Out-Null

        $script:SeedCount = 5
        $Types = @("architecture-decision","coding-convention","todo","changelog","assumption")
        for ($i = 1; $i -le $SeedCount; $i++) {
            New-MemoryArtifact `
                -Type $Types[($i - 1) % $Types.Count] `
                -Title "Seeded Artifact $i" `
                -Author "seeder" `
                -Content "Content $i" `
                -MemoryDir $ListTestDir | Out-Null
        }
    }

    AfterAll {
        Remove-Item -Recurse -Force $ListTestDir -ErrorAction SilentlyContinue
    }

    It "Get-MemoryArtifacts returns exactly <SeedCount> entries" {
        $Artifacts = Get-MemoryArtifacts -MemoryDir $ListTestDir
        $Artifacts.Count | Should -Be $SeedCount
    }

    It "Every returned artifact has a non-empty 'type' field" {
        $Artifacts = Get-MemoryArtifacts -MemoryDir $ListTestDir
        foreach ($A in $Artifacts) {
            $A.Type | Should -Not -BeNullOrEmpty
        }
    }

    It "Every returned artifact has a non-empty 'title' field" {
        $Artifacts = Get-MemoryArtifacts -MemoryDir $ListTestDir
        foreach ($A in $Artifacts) {
            $A.Title | Should -Not -BeNullOrEmpty
        }
    }

    It "Every returned artifact has a non-empty 'timestamp' field" {
        $Artifacts = Get-MemoryArtifacts -MemoryDir $ListTestDir
        foreach ($A in $Artifacts) {
            $A.Timestamp | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Memory artifact conflict handling" {
    It "Creating an artifact with the same slug appends rather than overwrites" {
        $Dir    = Join-Path $env:TEMP "god-opencode-conflict-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null

        New-MemoryArtifact -Type "todo" -Title "Shared Title" -Author "first"  -Content "First content"  -MemoryDir $Dir | Out-Null
        New-MemoryArtifact -Type "todo" -Title "Shared Title" -Author "second" -Content "Second content" -MemoryDir $Dir | Out-Null

        $Files = Get-ChildItem $Dir -Filter "*.md"
        $Files.Count | Should -Be 1  # Same slug -> same file, appended

        $Content = Get-Content $Files[0].FullName -Raw
        $Content | Should -Match "First content"
        $Content | Should -Match "Second content"

        Remove-Item -Recurse -Force $Dir
    }
}
