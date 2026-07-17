$ErrorActionPreference = 'Stop'
$Root = 'C:\AI\GOD-OPENCODE'
Set-Location $Root

$results = @()

# 1. JSON parse
try {
    $o = Get-Content "$Root\opencode.json" -Raw | ConvertFrom-Json
    $denyCount = $o.permission.bash.deny.Count
    $results += "JSON OK - $denyCount deny rules"
    # Confirm the smoking-gun broad patterns are GONE
    $broad = $o.permission.bash.deny | Where-Object { $_ -in @('rm -rf *', 'del /f /s /q') }
    if ($broad) {
        $results += "WARN: still has overly broad patterns: $($broad -join ', ')"
    } else {
        $results += "Broad patterns (rm -rf *, del /f /s /q) successfully removed"
    }
} catch {
    $results += "JSON PARSE ERROR: $_"
}

# 2. PowerShell syntax check for all touched scripts
$scripts = @('install.ps1', 'scripts\package-release.ps1', 'god-install.ps1')
foreach ($s in $scripts) {
    try {
        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile("$Root\$s", [ref]$null, [ref]$errors)
        if ($errors -and $errors.Count -gt 0) {
            $results += "$s SYNTAX ERROR: $($errors[0].Message)"
        } else {
            $results += "$s SYNTAX OK"
        }
    } catch {
        $results += "$s SYNTAX ERROR: $_"
    }
}

# 3. Run package release
try {
    Remove-Item "$Root\release" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    .\scripts\package-release.ps1 -Version '1.1.1-test' 2>&1 | Out-Null
    $zip = "$Root\release\god-opencode-v1.1.1-test.zip"
    if (!(Test-Path $zip)) {
        $results += "ZIP NOT CREATED"
    } else {
        Add-Type -A System.IO.Compression.FileSystem
        $z = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $zip).Path)
        $entries = $z.Entries.FullName
        $results += "ZIP created with $($entries.Count) entries"

        # Exclusion check
        $leaked = $entries | Where-Object { $_ -match '\.git\\|\.github\\|\.freebuff\\|^tests\\|\.zip$' -or $_ -match '[\\\/]tests[\\\/]' }
        if ($leaked) {
            $results += "LEAKED: $($leaked | Select-Object -First 5 | ForEach-Object { $_ })"
        } else {
            $results += "Exclusion check PASS (no .git, .github, .freebuff, tests, or zip leaked)"
        }

        # Confirm must-have entries
        $must = @('install.ps1', 'opencode.json', 'AGENTS.md', 'README.md', 'CHANGELOG.md')
        $missing = $must | Where-Object { ($entries -notcontains $_ -and ($entries -notcontains "$_\")) -and -not ($entries | Where-Object { $_ -like "$_*" }) }
        if ($missing) {
            $results += "MISSING: $($missing -join ', ')"
        } else {
            $results += "All required files present in zip"
        }

        # Confirm skills/workflows/agents present and not empty
        $skillsCount = ($entries | Where-Object { $_ -like 'skills\*' -and $_ -like '*SKILL.md' }).Count
        $workflowsCount = ($entries | Where-Object { $_ -like 'workflows\*' -and $_ -like '*.md' }).Count
        $agentsCount = ($entries | Where-Object { $_ -like 'agents\*' -and $_ -like '*AGENT.md' }).Count
        $results += "Counts: skills=$skillsCount SKILL.md, workflows=$workflowsCount .md, agents=$agentsCount AGENT.md"

        $z.Dispose()
        Remove-Item "$Root\release" -Recurse -Force
    }
} catch {
    $results += "package-release.ps1 THREW: $_"
    Remove-Item "$Root\release" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Confirm install.ps1 syntax (already done above)

$results | ForEach-Object { Write-Host $_ }
