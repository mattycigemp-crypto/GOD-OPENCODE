# ============================================
# GOD-OPENCODE UNINSTALLER
# Version 1.0
# ============================================
# Removes ALL GOD-OPENCODE traces from the system:
#   - Installed skills from ~/.config/opencode/skills/
#   - Agents, workflows, commands from god-opencode/ and cognivect/
#   - Merged entries from global opencode.jsonc
#   - Synced skills from all AI tool directories (16 tools)
#   - Local build artifacts (dist/, release/, cache, code graph)
#
# Usage:
#   .\god-uninstall.ps1                # interactive uninstall (asks before each step)
#   .\god-uninstall.ps1 -All           # remove everything (global + local artifacts)
#   .\god-uninstall.ps1 -DryRun        # preview what would be removed
#   .\god-uninstall.ps1 -Force         # skip confirmation prompts
#   .\god-uninstall.ps1 -KeepConfig    # don't touch global opencode.jsonc
#   .\god-uninstall.ps1 -Status        # show what's installed before removing

[CmdletBinding()]
param(
    [switch]$All,
    [switch]$DryRun,
    [switch]$Force,
    [switch]$KeepConfig,
    [switch]$Status
)

$ErrorActionPreference = "Stop"

# ============================================
# Colors & Helpers
# ============================================

$C = @{
    Ok = "Green"; Warn = "Yellow"; Err = "Red"
    Info = "Cyan"; Accent = "Magenta"; Dim = "DarkGray"
    Head = "White"
}

function Write-Status($label, $value, $color = "Green") {
    Write-Host "  " -NoNewline
    Write-Host ($label.PadRight(28)) -ForegroundColor $C.Dim -NoNewline
    Write-Host $value -ForegroundColor $color
}

function Write-Removed($path) {
    Write-Host "  [REMOVED] " -ForegroundColor Red -NoNewline
    Write-Host $path -ForegroundColor $C.Dim
}

function Write-Kept($path) {
    Write-Host "  [KEPT]    " -ForegroundColor Green -NoNewline
    Write-Host $path -ForegroundColor $C.Dim
}

function Write-Skipped($path) {
    Write-Host "  [SKIPPED] " -ForegroundColor Yellow -NoNewline
    Write-Host $path -ForegroundColor $C.Dim
}

function Write-DryRun($path) {
    Write-Host "  [WOULD REMOVE] " -ForegroundColor Yellow -NoNewline
    Write-Host $path -ForegroundColor $C.Dim
}

function Remove-DirectorySafely($path, $label) {
    if (!(Test-Path $path)) { return $false }
    $items = (Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue).Count
    if ($DryRun) {
        Write-DryRun "$path ($items items)"
        return $true
    }
    if ($Force) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Removed "$path ($items items)"
        return $true
    }
    # Interactive: ask user
    Write-Host ""
    Write-Host "  Found: $path" -ForegroundColor $C.Info
    Write-Host "  Contains: $items items" -ForegroundColor $C.Dim
    $ans = Read-Host "  Remove? [y/N]"
    if ($ans -match '^[Yy]') {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Removed "$path ($items items)"
        return $true
    } else {
        Write-Kept $path
        return $false
    }
}

function Remove-FileSafely($path, $label) {
    if (!(Test-Path $path)) { return $false }
    if ($DryRun) {
        Write-DryRun $path
        return $true
    }
    if ($Force) {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        Write-Removed $path
        return $true
    }
    Write-Host ""
    Write-Host "  Found: $path" -ForegroundColor $C.Info
    $ans = Read-Host "  Remove? [y/N]"
    if ($ans -match '^[Yy]') {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
        Write-Removed $path
        return $true
    } else {
        Write-Kept $path
        return $false
    }
}

# ============================================
# Header
# ============================================

Clear-Host
Write-Host ""
Write-Host "============================================" -ForegroundColor $C.Accent
Write-Host "     GOD-OPENCODE UNINSTALLER" -ForegroundColor $C.Accent
Write-Host "     Remove all installed components" -ForegroundColor $C.Accent
Write-Host "============================================" -ForegroundColor $C.Accent
Write-Host ""

if ($DryRun) {
    Write-Host "  MODE: DRY RUN (nothing will be removed)" -ForegroundColor Yellow
    Write-Host ""
}
if ($Status) {
    Write-Host "  MODE: STATUS (showing what's installed)" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# Paths
# ============================================

$OpenCodeDir   = Join-Path $HOME ".config\opencode"
$SkillsDir     = Join-Path $OpenCodeDir "skills"
$GodDataDir    = Join-Path $OpenCodeDir "god-opencode"
$CogDataDir    = Join-Path $OpenCodeDir "cognivect"
$GlobalConfig  = Join-Path $OpenCodeDir "opencode.jsonc"
$GlobalConfig2 = Join-Path $OpenCodeDir "opencode.json"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# AI tool directories that sync-skills.ps1 targets
$ToolDirectories = [ordered]@{
    "claude"     = Join-Path $HOME ".claude\skills"
    "cursor"     = Join-Path $HOME ".cursor\skills"
    "windsurf"   = Join-Path $HOME ".windsurf\skills"
    "cline"      = Join-Path $HOME ".cline\skills"
    "copilot"    = Join-Path $HOME ".copilot\skills"
    "aider"      = Join-Path $HOME ".aider\skills"
    "openhands"  = Join-Path $HOME ".openhands\skills"
    "continue"   = Join-Path $HOME ".continue\skills"
    "zed"        = Join-Path $HOME ".zed\skills"
    "gemini"     = Join-Path $HOME ".gemini\skills"
    "codex"      = Join-Path $HOME ".codex\skills"
    "hermes"     = Join-Path $HOME ".hermes\skills"
    "vscode"     = Join-Path $HOME ".vscode\skills"
    "jetbrains"  = Join-Path $HOME ".jetbrains\skills"
    "nvim"       = Join-Path $HOME ".config\nvim\skills"
}

# ============================================
# Status check mode
# ============================================

if ($Status) {
    Write-Host "  INSTALLATION STATUS" -ForegroundColor $C.Accent
    Write-Host "  " + ("=" * 50) -ForegroundColor $C.Dim
    Write-Host ""

    # Global install
    $hasSkills = Test-Path $SkillsDir
    $hasGod    = Test-Path $GodDataDir
    $hasCog    = Test-Path $CogDataDir
    $hasConfig = (Test-Path $GlobalConfig) -or (Test-Path $GlobalConfig2)

    if ($hasSkills) {
        $skillCount = (Get-ChildItem -Path $SkillsDir -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "Global Skills" "$skillCount installed" "Green"
    } else {
        Write-Status "Global Skills" "Not installed" "Dim"
    }
    if ($hasGod) {
        $agentCount = (Get-ChildItem -Path "$GodDataDir\agents" -Directory -ErrorAction SilentlyContinue).Count
        $wfCount    = (Get-ChildItem -Path "$GodDataDir\workflows" -Filter "*.md" -File -ErrorAction SilentlyContinue).Count
        $cmdCount   = (Get-ChildItem -Path "$GodDataDir\commands" -Filter "*.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "God-OpenCode Data" "$agentCount agents, $wfCount workflows, $cmdCount cmds" "Green"
    } else {
        Write-Status "God-OpenCode Data" "Not installed" "Dim"
    }
    if ($hasCog) {
        $cAgentCount = (Get-ChildItem -Path "$CogDataDir\agents" -Directory -ErrorAction SilentlyContinue).Count
        $cWfCount    = (Get-ChildItem -Path "$CogDataDir\workflows" -Filter "*.md" -File -ErrorAction SilentlyContinue).Count
        Write-Status "CogniVect Data" "$cAgentCount agents, $cWfCount workflows" "Green"
    } else {
        Write-Status "CogniVect Data" "Not installed" "Dim"
    }

    $cfgFile = if (Test-Path $GlobalConfig) { $GlobalConfig } elseif (Test-Path $GlobalConfig2) { $GlobalConfig2 } else { "" }
    if ($cfgFile) {
        $cfgContent = Get-Content $cfgFile -Raw -ErrorAction SilentlyContinue
        if ($cfgContent -match "god-opencode" -or $cfgContent -match "security-engineer") {
            Write-Status "Global Config" "Merged (has GOD-OPENCODE entries)" "Green"
        } else {
            Write-Status "Global Config" "Exists (not merged)" "Dim"
        }
    } else {
        Write-Status "Global Config" "Not found" "Dim"
    }

    # Synced tools
    Write-Host ""
    Write-Host "  SYNCED AI TOOL DIRECTORIES" -ForegroundColor $C.Accent
    Write-Host "  " + ("=" * 50) -ForegroundColor $C.Dim
    Write-Host ""

    $foundAny = $false
    foreach ($key in $ToolDirectories.Keys) {
        $toolPath = $ToolDirectories[$key]
        if (Test-Path $toolPath) {
            $count = (Get-ChildItem -Path $toolPath -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
            if ($count -gt 0) {
                Write-Status $key "$count skills in $toolPath" "Green"
                $foundAny = $true
            }
        }
    }
    if (-not $foundAny) {
        Write-Status "(none)" "No synced skills found" "Dim"
    }

    # Local artifacts
    Write-Host ""
    Write-Host "  LOCAL BUILD ARTIFACTS" -ForegroundColor $C.Accent
    Write-Host "  " + ("=" * 50) -ForegroundColor $C.Dim
    Write-Host ""

    $artifacts = @(
        @("$Root\dist\converted", "Converted skills"),
        @("$Root\dist\cursorrules", "Cursor rules export"),
        @("$Root\release", "Release packages"),
        @("$Root\memory\session.json", "Session memory"),
        @("$Root\docs\wiki\_data\code-graph.json", "Code graph"),
        @("$Root\scripts\.cache", "Smart loader cache")
    )
    foreach ($art in $artifacts) {
        $artPath = $art[0]; $artLabel = $art[1]
        if (Test-Path $artPath) {
            Write-Status $artLabel "Found at $artPath" "Yellow"
        }
    }

    Write-Host ""
    Write-Host "  Run without -Status to proceed with removal." -ForegroundColor $C.Dim
    Write-Host ""
    exit 0
}

# ============================================
# Confirmation
# ============================================

if (-not $Force -and -not $DryRun) {
    Write-Host "  This will remove ALL GOD-OPENCODE installed components:" -ForegroundColor $C.Warn
    Write-Host "    - Skills from ~/.config/opencode/skills/" -ForegroundColor $C.Dim
    Write-Host "    - Agents, workflows, commands data dirs" -ForegroundColor $C.Dim
    Write-Host "    - Synced skills from 16 AI tool directories" -ForegroundColor $C.Dim
    if ($All) {
        Write-Host "    - Local build artifacts (dist/, release/, cache)" -ForegroundColor $C.Dim
    }
    Write-Host ""
    $ans = Read-Host "  Are you sure? Type YES to confirm"
    if ($ans -ne "YES") {
        Write-Host ""
        Write-Host "  Cancelled." -ForegroundColor $C.Warn
        exit 0
    }
}

# ============================================
# Counters
# ============================================

$removedDirs = 0
$removedFiles = 0
$skippedDirs = 0
$skippedFiles = 0

# ============================================
# STEP 1: Remove Global Skills
# ============================================

Write-Host ""
Write-Host "  --- Removing Global Skills ---" -ForegroundColor $C.Info
Write-Host ""

if (Test-Path $SkillsDir) {
    $skillCount = (Get-ChildItem -Path $SkillsDir -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
    if ($skillCount -gt 0) {
        if (Remove-DirectorySafely $SkillsDir "skills") { $removedDirs++ }
    } else {
        if ($DryRun) {
            Write-Host "  [SKIPPED] $SkillsDir (empty)" -ForegroundColor $C.Dim
        }
        $skippedDirs++
    }
} else {
    if (-not $DryRun) { Write-Status "Global Skills" "Not installed" "Dim" }
}

# ============================================
# STEP 2: Remove God-OpenCode Data Dir
# ============================================

Write-Host ""
Write-Host "  --- Removing God-OpenCode Data ---" -ForegroundColor $C.Info
Write-Host ""

$godSubdirs = @("agents", "workflows", "commands")
foreach ($sub in $godSubdirs) {
    $subPath = Join-Path $GodDataDir $sub
    if (Remove-DirectorySafely $subPath "god-opencode/$sub") { $removedDirs++ }
}

# Remove the god-opencode directory itself if empty
if (Test-Path $GodDataDir) {
    $remaining = (Get-ChildItem -Path $GodDataDir -ErrorAction SilentlyContinue).Count
    if ($remaining -eq 0) {
        if ($DryRun) { Write-DryRun $GodDataDir }
        else { Remove-Item -Path $GodDataDir -Force -ErrorAction SilentlyContinue; Write-Removed $GodDataDir }
        $removedDirs++
    }
}

# ============================================
# STEP 3: Remove CogniVect Data Dir
# ============================================

Write-Host ""
Write-Host "  --- Removing CogniVect Data ---" -ForegroundColor $C.Info
Write-Host ""

if (Test-Path $CogDataDir) {
    $cogSubdirs = @("agents", "workflows", "commands")
    foreach ($sub in $cogSubdirs) {
        $subPath = Join-Path $CogDataDir $sub
        if (Remove-DirectorySafely $subPath "cognivect/$sub") { $removedDirs++ }
    }
    $remaining = (Get-ChildItem -Path $CogDataDir -ErrorAction SilentlyContinue).Count
    if ($remaining -eq 0) {
        if ($DryRun) { Write-DryRun $CogDataDir }
        else { Remove-Item -Path $CogDataDir -Force -ErrorAction SilentlyContinue; Write-Removed $CogDataDir }
        $removedDirs++
    }
}

# ============================================
# STEP 4: Clean Global Config (opencode.jsonc / opencode.json)
# ============================================

Write-Host ""
Write-Host "  --- Cleaning Global Config ---" -ForegroundColor $C.Info
Write-Host ""

if (-not $KeepConfig) {
    $cfgFile = if (Test-Path $GlobalConfig) { $GlobalConfig } elseif (Test-Path $GlobalConfig2) { $GlobalConfig2 } else { "" }

    if ($cfgFile) {
        $cfgContent = Get-Content $cfgFile -Raw -ErrorAction SilentlyContinue
        if ($cfgContent -and ($cfgContent -match "god-opencode" -or $cfgContent -match "security-engineer")) {
            # Helper: remove GOD-OPENCODE entries from parsed JSON
            function Remove-GocEntries {
                param([string]$ConfigFile)
                $raw = Get-Content $ConfigFile -Raw
                # Strip JSONC comments (lines starting with //) before parsing
                $stripped = ($raw -split "`r?`n" | Where-Object { $_ -notmatch '^[\s]*//' }) -join "`n"
                try {
                    $json = $stripped | ConvertFrom-Json
                } catch {
                    Write-Host "  [WARN] Could not parse $ConfigFile as JSON — skipping config cleanup" -ForegroundColor Yellow
                    return $false
                }

                $gocAgents = @(
                    "backend-engineer", "frontend-engineer", "fullstack-engineer",
                    "security-engineer", "devops-engineer", "data-engineer",
                    "qa-engineer", "ai-engineer", "documentation-engineer", "refactoring-engineer"
                )
                $gocCommands = @(
                    "/brainstorm", "/code-review", "/debug", "/deploy",
                    "/explain", "/refactor", "/test"
                )
                $changed = $false

                # Remove GOD-OPENCODE agents from agent object
                if ($json.agent) {
                    foreach ($name in $gocAgents) {
                        if ($json.agent.PSObject.Properties[$name]) {
                            $json.agent.PSObject.Properties.Remove($name)
                            $changed = $true
                        }
                    }
                }

                # Remove GOD-OPENCODE commands from command object
                if ($json.command) {
                    foreach ($name in $gocCommands) {
                        $cmdKey = $name.TrimStart('/')
                        if ($json.command.PSObject.Properties[$cmdKey]) {
                            $json.command.PSObject.Properties.Remove($cmdKey)
                            $changed = $true
                        }
                    }
                }

                # Remove instructions that reference god-opencode
                if ($json.instructions) {
                    $filtered = @($json.instructions) | Where-Object { $_ -notmatch 'god-opencode' }
                    if ($filtered.Count -ne @($json.instructions).Count) {
                        $json.instructions = @($filtered)
                        $changed = $true
                    }
                }

                # Remove permission entries referencing god-opencode
                if ($json.permission) {
                    foreach ($tool in @($json.permission.PSObject.Properties.Name)) {
                        $toolObj = $json.permission.$tool
                        if ($toolObj.deny) {
                            $filtered = @($toolObj.deny) | Where-Object { $_ -notmatch 'god-opencode' }
                            if ($filtered.Count -ne @($toolObj.deny).Count) {
                                $toolObj.deny = @($filtered)
                                $changed = $true
                            }
                        }
                    }
                }

                if ($changed) {
                    $json | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile -Encoding UTF8
                    Write-Removed "GOD-OPENCODE entries from $ConfigFile"
                    return $true
                } else {
                    Write-Status "Global Config" "No GOD-OPENCODE entries found" "Dim"
                    return $false
                }
            }

            if ($DryRun) {
                Write-DryRun "$cfgFile (remove GOD-OPENCODE entries via JSON parse)"
            } elseif ($Force) {
                $backupPath = "$cfgFile.god-backup"
                Copy-Item $cfgFile $backupPath -Force
                Write-Host "  [BACKUP] $backupPath" -ForegroundColor $C.Dim
                if (Remove-GocEntries -ConfigFile $cfgFile) { $removedFiles++ }
            } else {
                Write-Host "  Found GOD-OPENCODE entries in: $cfgFile" -ForegroundColor $C.Info
                $ans = Read-Host "  Remove GOD-OPENCODE entries (backup will be created)? [y/N]"
                if ($ans -match '^[Yy]') {
                    $backupPath = "$cfgFile.god-backup"
                    Copy-Item $cfgFile $backupPath -Force
                    Write-Host "  [BACKUP] $backupPath" -ForegroundColor $C.Dim
                    if (Remove-GocEntries -ConfigFile $cfgFile) { $removedFiles++ }
                } else {
                    Write-Kept $cfgFile
                }
            }
        } else {
            Write-Status "Global Config" "No GOD-OPENCODE entries found" "Dim"
        }
    } else {
        Write-Status "Global Config" "Not found" "Dim"
    }
} else {
    Write-Status "Global Config" "Skipped (-KeepConfig)" "Yellow"
}

# ============================================
# STEP 5: Remove Synced Skills from AI Tool Dirs
# ============================================

Write-Host ""
Write-Host "  --- Removing Synced Skills from AI Tools ---" -ForegroundColor $C.Info
Write-Host ""

$foundSynced = $false
foreach ($key in $ToolDirectories.Keys) {
    $toolPath = $ToolDirectories[$key]
    if (Test-Path $toolPath) {
        $syncedSkills = Get-ChildItem -Path $toolPath -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue
        if ($syncedSkills.Count -gt 0) {
            $foundSynced = $true
            if ($DryRun) {
                Write-DryRun "$key ($($syncedSkills.Count) skills in $toolPath)"
            } elseif ($Force) {
                Remove-Item -Path $toolPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Removed "$key ($($syncedSkills.Count) skills)"
                $removedDirs++
            } else {
                Write-Host ""
                Write-Host "  Found $($syncedSkills.Count) skills in $key" -ForegroundColor $C.Info
                Write-Host "  Path: $toolPath" -ForegroundColor $C.Dim
                $ans = Read-Host "  Remove all? [y/N]"
                if ($ans -match '^[Yy]') {
                    Remove-Item -Path $toolPath -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Removed "$key ($($syncedSkills.Count) skills)"
                    $removedDirs++
                } else {
                    Write-Kept "$key ($($syncedSkills.Count) skills)"
                    $skippedDirs++
                }
            }
        }
    }
}

if (-not $foundSynced -and -not $DryRun) {
    Write-Status "Synced Skills" "None found" "Dim"
}

# ============================================
# STEP 6: Remove Local Build Artifacts (-All)
# ============================================

if ($All) {
    Write-Host ""
    Write-Host "  --- Removing Local Build Artifacts ---" -ForegroundColor $C.Info
    Write-Host ""

    # dist/converted
    $convertDir = Join-Path $Root "dist\converted"
    if (Remove-DirectorySafely $convertDir "dist/converted") { $removedDirs++ }

    # dist/cursorrules
    $cursorDir = Join-Path $Root "dist\cursorrules"
    if (Remove-DirectorySafely $cursorDir "dist/cursorrules") { $removedDirs++ }

    # dist/ root (if only has converted/ and cursorrules/)
    $distDir = Join-Path $Root "dist"
    if (Test-Path $distDir) {
        $remaining = (Get-ChildItem -Path $distDir -ErrorAction SilentlyContinue).Count
        if ($remaining -eq 0) {
            if ($DryRun) { Write-DryRun $distDir }
            else { Remove-Item -Path $distDir -Force; Write-Removed $distDir }
            $removedDirs++
        }
    }

    # release/ (zip packages)
    $releaseDir = Join-Path $Root "release"
    if (Test-Path $releaseDir) {
        $zips = Get-ChildItem -Path $releaseDir -Filter "*.zip" -File -ErrorAction SilentlyContinue
        if ($zips.Count -gt 0) {
            foreach ($zip in $zips) {
                Remove-FileSafely $zip.FullName "release/$($zip.Name)"
                $removedFiles++
            }
        }
        # Remove SHA256SUMS.txt if present
        $shaFile = Join-Path $releaseDir "SHA256SUMS.txt"
        if (Test-Path $shaFile) {
            Remove-FileSafely $shaFile "release/SHA256SUMS.txt"
            $removedFiles++
        }
        $remaining = (Get-ChildItem -Path $releaseDir -ErrorAction SilentlyContinue).Count
        if ($remaining -eq 0) {
            if ($DryRun) { Write-DryRun $releaseDir }
            else { Remove-Item -Path $releaseDir -Force; Write-Removed $releaseDir }
            $removedDirs++
        }
    }

    # memory/session.json
    $sessionFile = Join-Path $Root "memory\session.json"
    if (Remove-FileSafely $sessionFile "memory/session.json") { $removedFiles++ }

    # docs/wiki/_data/code-graph.json
    $codeGraph = Join-Path $Root "docs\wiki\_data\code-graph.json"
    if (Remove-FileSafely $codeGraph "code-graph.json") { $removedFiles++ }

    # scripts/.cache/
    $cacheDir = Join-Path $Root "scripts\.cache"
    if (Remove-DirectorySafely $cacheDir "scripts/.cache") { $removedDirs++ }

    # nul (accidental file)
    $nulFile = Join-Path $Root "nul"
    if (Test-Path $nulFile) {
        Remove-FileSafely $nulFile "nul (accidental)"
        $removedFiles++
    }
}

# ============================================
# STEP 7: Clean OpenCode skills-mirror if present
# ============================================

$mirrorDir = Join-Path $Root "skills-mirror"
if (Test-Path $mirrorDir) {
    Write-Host ""
    Write-Host "  --- Removing Skills Mirror ---" -ForegroundColor $C.Info
    Write-Host ""
    if (Remove-DirectorySafely $mirrorDir "skills-mirror") { $removedDirs++ }
}

# ============================================
# STEP 8: Clean .opencode/skills symlink
# ============================================

$localSkills = Join-Path $Root ".opencode\skills"
if (Test-Path $localSkills) {
    Write-Host ""
    Write-Host "  --- Removing Project-Local Skills ---" -ForegroundColor $C.Info
    Write-Host ""
    if (Remove-DirectorySafely $localSkills ".opencode/skills") { $removedDirs++ }
}

# Remove .opencode dir if empty
$opencodeLocal = Join-Path $Root ".opencode"
if (Test-Path $opencodeLocal) {
    $remaining = (Get-ChildItem -Path $opencodeLocal -ErrorAction SilentlyContinue).Count
    if ($remaining -eq 0) {
        if ($DryRun) { Write-DryRun $opencodeLocal }
        else { Remove-Item -Path $opencodeLocal -Force; Write-Removed $opencodeLocal }
        $removedDirs++
    }
}

# ============================================
# Summary
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor $C.Accent
if ($DryRun) {
    Write-Host "     DRY RUN COMPLETE" -ForegroundColor $C.Accent
} else {
    Write-Host "     UNINSTALL COMPLETE" -ForegroundColor $C.Accent
}
Write-Host "============================================" -ForegroundColor $C.Accent
Write-Host ""

if ($DryRun) {
    Write-Host "  No files were removed. Re-run without -DryRun to proceed." -ForegroundColor $C.Dim
} else {
    Write-Host "  Directories removed: $removedDirs" -ForegroundColor $(if ($removedDirs -gt 0) { "Green" } else { "Dim" })
    Write-Host "  Files removed:       $removedFiles" -ForegroundColor $(if ($removedFiles -gt 0) { "Green" } else { "Dim" })
    Write-Host "  Directories kept:    $skippedDirs" -ForegroundColor $(if ($skippedDirs -gt 0) { "Yellow" } else { "Dim" })
    Write-Host ""

    # Post-uninstall status
    $anyRemaining = $false
    $checks = @(
        $SkillsDir, $GodDataDir, $CogDataDir
    )
    foreach ($check in $checks) {
        if (Test-Path $check) { $anyRemaining = $true }
    }

    if ($anyRemaining) {
        Write-Host "  Some directories still exist (user chose to keep)." -ForegroundColor $C.Warn
    } else {
        Write-Host "  GOD-OPENCODE has been fully removed." -ForegroundColor $C.Ok
    }
}

Write-Host ""
Write-Host "  To reinstall: .\install.ps1" -ForegroundColor $C.Dim
Write-Host ""
