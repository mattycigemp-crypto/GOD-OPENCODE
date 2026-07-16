# Feature: god-opencode, Property 8: Error Isolation
# Unit tests for installer utilities: Write-IfChanged, EnsureFolder, RunStep
# Run: Invoke-Pester -Path .\tests\unit\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    . (Join-Path $Root "scripts\shared-utils.ps1")
    $script:TempBase = Join-Path $env:TEMP "god-opencode-installer-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $TempBase -Force | Out-Null
}

AfterAll {
    Remove-Item -Recurse -Force $TempBase -ErrorAction SilentlyContinue
}

Describe "Write-IfChanged" {
    It "Creates a new file when it does not exist" {
        $Path = Join-Path $TempBase "new-file.txt"
        Write-IfChanged -Path $Path -Content "hello"
        Test-Path $Path | Should -BeTrue
        Get-Content $Path -Raw | Should -Match "hello"
    }

    It "Overwrites a file when content has changed" {
        $Path = Join-Path $TempBase "changed-file.txt"
        Set-Content $Path "original"
        Write-IfChanged -Path $Path -Content "updated"
        Get-Content $Path -Raw | Should -Match "updated"
    }

    It "Does NOT write when content is identical" {
        $Path = Join-Path $TempBase "same-file.txt"
        Write-IfChanged -Path $Path -Content "same content"
        $Before = (Get-Item $Path).LastWriteTime
        Start-Sleep -Milliseconds 50
        Write-IfChanged -Path $Path -Content "same content"
        $After = (Get-Item $Path).LastWriteTime
        # LastWriteTime should be unchanged — file was not touched
        $After | Should -Be $Before
    }

    It "Creates intermediate directories if they do not exist" {
        $Path = Join-Path $TempBase "sub\dir\deep\file.txt"
        Write-IfChanged -Path $Path -Content "deep"
        Test-Path $Path | Should -BeTrue
    }
}

Describe "EnsureFolder" {
    It "Creates a directory that does not exist" {
        $Dir = Join-Path $TempBase "new-folder-$(Get-Random)"
        EnsureFolder -Folder $Dir
        Test-Path $Dir | Should -BeTrue
    }

    It "Does not throw when directory already exists" {
        $Dir = Join-Path $TempBase "existing-folder"
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        { EnsureFolder -Folder $Dir } | Should -Not -Throw
    }
}

Describe "RunStep" {
    It "Returns true when a script succeeds" {
        $ScriptDir = Join-Path $TempBase "scripts-ok"
        New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
        Set-Content (Join-Path $ScriptDir "ok.ps1") 'Write-Host "ok"' -Encoding UTF8
        $Result = RunStep -Title "OK Step" -Script "ok.ps1" -ScriptsDir $ScriptDir
        $Result | Should -BeTrue
    }

    It "Returns false and does NOT throw when a script fails" {
        $ScriptDir = Join-Path $TempBase "scripts-fail"
        New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
        Set-Content (Join-Path $ScriptDir "fail.ps1") 'throw "deliberate failure"' -Encoding UTF8
        $Result = $null
        { $Result = RunStep -Title "Fail Step" -Script "fail.ps1" -ScriptsDir $ScriptDir } | Should -Not -Throw
        $Result | Should -BeFalse
    }

    It "Returns false and does NOT throw when script file is missing" {
        $ScriptDir = Join-Path $TempBase "scripts-missing"
        New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
        $Result = $null
        { $Result = RunStep -Title "Missing" -Script "nonexistent.ps1" -ScriptsDir $ScriptDir } | Should -Not -Throw
        $Result | Should -BeFalse
    }

    It "Continues running subsequent steps after one failure (error isolation)" {
        # Property 8: a failed step must not abort the pipeline
        $ScriptDir = Join-Path $TempBase "scripts-isolation"
        New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
        Set-Content (Join-Path $ScriptDir "step1.ps1") 'throw "step 1 fails"' -Encoding UTF8
        Set-Content (Join-Path $ScriptDir "step2.ps1") 'Write-Host "step 2 ran"' -Encoding UTF8
        Set-Content (Join-Path $ScriptDir "step3.ps1") 'Write-Host "step 3 ran"' -Encoding UTF8

        $Results = @()
        $Results += RunStep -Title "Step 1" -Script "step1.ps1" -ScriptsDir $ScriptDir
        $Results += RunStep -Title "Step 2" -Script "step2.ps1" -ScriptsDir $ScriptDir
        $Results += RunStep -Title "Step 3" -Script "step3.ps1" -ScriptsDir $ScriptDir

        $Results[0] | Should -BeFalse  # step 1 failed
        $Results[1] | Should -BeTrue   # step 2 ran
        $Results[2] | Should -BeTrue   # step 3 ran
    }
}

Describe "ConvertTo-Slug" {
    It "Lowercases the input" {
        ConvertTo-Slug "Hello World" | Should -Match "^[a-z-]+$"
    }

    It "Replaces spaces with hyphens" {
        ConvertTo-Slug "hello world" | Should -Be "hello-world"
    }

    It "Strips non-alphanumeric characters" {
        ConvertTo-Slug "hello! world@2024" | Should -Be "hello-world2024"
    }

    It "Truncates at MaxLength" {
        $Long = "a" * 100
        (ConvertTo-Slug $Long -MaxLength 20).Length | Should -BeLessOrEqual 20
    }

    It "Does not start or end with a hyphen" {
        $Slug = ConvertTo-Slug "  hello world  "
        $Slug | Should -Not -Match "^-"
        $Slug | Should -Not -Match "-$"
    }
}
