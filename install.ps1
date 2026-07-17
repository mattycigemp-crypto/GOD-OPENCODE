# ============================================
# GOD-OPENCODE SMART INSTALLER
# Version 2.2
# ============================================

$Source = Join-Path $PSScriptRoot "skills"
$Destination = Join-Path $HOME ".config\opencode\skills"
$DataDir = Join-Path $HOME ".config\opencode\god-opencode"

Write-Host ""
Write-Host "============================================"
Write-Host "     GOD-OPENCODE SMART INSTALLER"
Write-Host "============================================"
Write-Host ""

# ============================================
# INSTALL SKILLS
# ============================================

Write-Host "--- Installing Skills ---"
Write-Host ""

if (!(Test-Path $Destination)) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
}

$New = 0
$Updated = 0
$Skipped = 0

$Skills = Get-ChildItem -Path $Source -Recurse -Directory |
Where-Object { Test-Path "$($_.FullName)\SKILL.md" }

foreach ($Skill in $Skills) {
    $SkillFile = Join-Path $Skill.FullName "SKILL.md"
    $Target = Join-Path $Destination $Skill.Name
    $TargetFile = Join-Path $Target "SKILL.md"

    if (!(Test-Path $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
    }

    if (!(Test-Path $TargetFile)) {
        Copy-Item $SkillFile $TargetFile -Force
        Write-Host "[NEW] $($Skill.Name)"
        $New++
    } else {
        $SourceHash = Get-FileHash $SkillFile
        $TargetHash = Get-FileHash $TargetFile
        if ($SourceHash.Hash -ne $TargetHash.Hash) {
            Copy-Item $SkillFile $TargetFile -Force
            Write-Host "[UPDATED] $($Skill.Name)"
            $Updated++
        } else {
            Write-Host "[UNCHANGED] $($Skill.Name)"
            $Skipped++
        }
    }
}

Write-Host ""
Write-Host "Skills: New=$New Updated=$Updated Unchanged=$Skipped"

# ============================================
# INSTALL WORKFLOWS
# ============================================

Write-Host ""
Write-Host "--- Installing Workflows ---"
Write-Host ""

$WorkflowSource = Join-Path $PSScriptRoot "workflows"
$WorkflowDest = Join-Path $DataDir "workflows"

if (!(Test-Path $WorkflowDest)) {
    New-Item -ItemType Directory -Path $WorkflowDest -Force | Out-Null
}

$WNew = 0
$WUpdated = 0
$WSkipped = 0

if (Test-Path $WorkflowSource) {
    $Workflows = Get-ChildItem -Path $WorkflowSource -Filter "*.md" -File

    foreach ($WF in $Workflows) {
        $TargetFile = Join-Path $WorkflowDest $WF.Name

        if (!(Test-Path $TargetFile)) {
            Copy-Item $WF.FullName $TargetFile -Force
            Write-Host "[NEW] $($WF.Name)"
            $WNew++
        } else {
            $SourceHash = Get-FileHash $WF.FullName
            $TargetHash = Get-FileHash $TargetFile
            if ($SourceHash.Hash -ne $TargetHash.Hash) {
                Copy-Item $WF.FullName $TargetFile -Force
                Write-Host "[UPDATED] $($WF.Name)"
                $WUpdated++
            } else {
                Write-Host "[UNCHANGED] $($WF.Name)"
                $WSkipped++
            }
        }
    }
}

Write-Host ""
Write-Host "Workflows: New=$WNew Updated=$WUpdated Unchanged=$WSkipped"

# ============================================
# INSTALL AGENTS
# ============================================

Write-Host ""
Write-Host "--- Installing Agents ---"
Write-Host ""

$AgentSource = Join-Path $PSScriptRoot "agents"
$AgentDest = Join-Path $DataDir "agents"

if (!(Test-Path $AgentDest)) {
    New-Item -ItemType Directory -Path $AgentDest -Force | Out-Null
}

$ANew = 0
$AUpdated = 0
$ASkipped = 0

if (Test-Path $AgentSource) {
    $Agents = Get-ChildItem -Path $AgentSource -Directory

    foreach ($Agent in $Agents) {
        $AgentFile = Join-Path $Agent.FullName "AGENT.md"
        if (Test-Path $AgentFile) {
            $TargetDir = Join-Path $AgentDest $Agent.Name
            if (!(Test-Path $TargetDir)) {
                New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
            }
            $TargetFile = Join-Path $TargetDir "AGENT.md"

            if (!(Test-Path $TargetFile)) {
                Copy-Item $AgentFile $TargetFile -Force
                Write-Host "[NEW] $($Agent.Name)"
                $ANew++
            } else {
                $SourceHash = Get-FileHash $AgentFile
                $TargetHash = Get-FileHash $TargetFile
                if ($SourceHash.Hash -ne $TargetHash.Hash) {
                    Copy-Item $AgentFile $TargetFile -Force
                    Write-Host "[UPDATED] $($Agent.Name)"
                    $AUpdated++
                } else {
                    Write-Host "[UNCHANGED] $($Agent.Name)"
                    $ASkipped++
                }
            }
        }
    }
}

Write-Host ""
Write-Host "Agents: New=$ANew Updated=$AUpdated Unchanged=$ASkipped"

# ============================================
# INSTALL COMMANDS
# ============================================

Write-Host ""
Write-Host "--- Installing Commands ---"
Write-Host ""

$CommandSource = Join-Path $PSScriptRoot "commands"
$CommandDest = Join-Path $DataDir "commands"

if (!(Test-Path $CommandDest)) {
    New-Item -ItemType Directory -Path $CommandDest -Force | Out-Null
}

$CNew = 0
$CUpdated = 0
$CSkipped = 0

if (Test-Path $CommandSource) {
    $Commands = Get-ChildItem -Path $CommandSource -Filter "*.md" -File

    foreach ($Cmd in $Commands) {
        $TargetFile = Join-Path $CommandDest $Cmd.Name

        if (!(Test-Path $TargetFile)) {
            Copy-Item $Cmd.FullName $TargetFile -Force
            Write-Host "[NEW] $($Cmd.Name)"
            $CNew++
        } else {
            $SourceHash = Get-FileHash $Cmd.FullName
            $TargetHash = Get-FileHash $TargetFile
            if ($SourceHash.Hash -ne $TargetHash.Hash) {
                Copy-Item $Cmd.FullName $TargetFile -Force
                Write-Host "[UPDATED] $($Cmd.Name)"
                $CUpdated++
            } else {
                Write-Host "[UNCHANGED] $($Cmd.Name)"
                $CSkipped++
            }
        }
    }
}

Write-Host ""
Write-Host "Commands: New=$CNew Updated=$CUpdated Unchanged=$CSkipped"

# ============================================
# MERGE AGENT CONFIGS TO GLOBAL OPENCODE.JSON
# ============================================

Write-Host ""
Write-Host "--- Merging Agent Configs to Global Config ---"
Write-Host ""

$GlobalConfig = Join-Path $HOME ".config\opencode\opencode.jsonc"
$SourceConfig = Join-Path $PSScriptRoot "opencode.json"

if (Test-Path $GlobalConfig) {
    try {
        $Global = Get-Content $GlobalConfig -Raw | ConvertFrom-Json
        $Source = Get-Content $SourceConfig -Raw | ConvertFrom-Json

        $Merged = $false

        # Merge agents
        if ($Source.agent) {
            if (-not $Global.agent) {
                $Global | Add-Member -NotePropertyName "agent" -NotePropertyValue $Source.agent
                $Merged = $true
            } else {
                foreach ($Prop in $Source.agent.PSObject.Properties) {
                    if (-not $Global.agent.PSObject.Properties[$Prop.Name]) {
                        $Global.agent | Add-Member -NotePropertyName $Prop.Name -NotePropertyValue $Prop.Value
                        $Merged = $true
                    }
                }
            }
        }

        # Merge commands
        if ($Source.command) {
            if (-not $Global.command) {
                $Global | Add-Member -NotePropertyName "command" -NotePropertyValue $Source.command
                $Merged = $true
            } else {
                foreach ($Prop in $Source.command.PSObject.Properties) {
                    if (-not $Global.command.PSObject.Properties[$Prop.Name]) {
                        $Global.command | Add-Member -NotePropertyName $Prop.Name -NotePropertyValue $Prop.Value
                        $Merged = $true
                    }
                }
            }
        }

        # Merge instructions (append if not already present; supports glob patterns)
        if ($Source.instructions) {
            $RawContent = Get-Content $GlobalConfig -Raw
            $InstructionsArray = @()

            # Extract existing instructions if present
            if ($RawContent -match '"instructions"\s*:\s*\[([^\]]*)\]') {
                $ExistingStr = $Matches[1].Trim()
                if ($ExistingStr) {
                    $InstructionsArray = $ExistingStr -split ',' | ForEach-Object { $_.Trim().Trim('"') }
                }
            }

            # Add new instructions (including glob patterns like docs/**/*.md)
            foreach ($Inst in $Source.instructions) {
                if ($Inst -notin $InstructionsArray) {
                    $InstructionsArray += $Inst
                    $Merged = $true
                }
            }

            # Write back
            if ($Merged) {
                $InstructionsJson = ($InstructionsArray | ForEach-Object { "`"$_`"" }) -join ', '
                $InstructionsBlock = "`"instructions`": [$InstructionsJson]"

                if ($RawContent -match '"instructions"\s*:\s*\[[^\]]*\]') {
                    $RawContent = $RawContent -replace '"instructions"\s*:\s*\[[^\]]*\]', $InstructionsBlock
                } else {
                    # Add before the last closing brace
                    $LastBrace = $RawContent.LastIndexOf('}')
                    $RawContent = $RawContent.Insert($LastBrace, "$InstructionsBlock,`n  ")
                }
                Set-Content $GlobalConfig -Value $RawContent -Encoding UTF8
            }
        }

        # Merge permission rules (append missing deny entries)
        if ($Source.permission) {
            if (-not $Global.permission) {
                $Global | Add-Member -NotePropertyName "permission" -NotePropertyValue $Source.permission
                $Merged = $true
            } else {
                foreach ($Tool in $Source.permission.PSObject.Properties.Name) {
                    $SourceTool = $Source.permission.$Tool
                    $GlobalTool = $Global.permission.$Tool

                    if (-not $GlobalTool) {
                        $Global.permission | Add-Member -NotePropertyName $Tool -NotePropertyValue $SourceTool
                        $Merged = $true
                    } else {
                        $SourceDeny = @()
                        $GlobalDeny = @()

                        if ($SourceTool.deny) { $SourceDeny = $SourceTool.deny }
                        if ($GlobalTool.deny) { $GlobalDeny = $GlobalTool.deny }

                        foreach ($Entry in $SourceDeny) {
                            if ($Entry -notin $GlobalDeny) {
                                $GlobalDeny += $Entry
                                $Merged = $true
                            }
                        }

                        $GlobalTool.deny = $GlobalDeny
                    }
                }
            }
        }

        if ($Merged) {
            $Global | ConvertTo-Json -Depth 10 | Set-Content $GlobalConfig -Encoding UTF8
            Write-Host "[MERGED] Agent configs added to $GlobalConfig" -ForegroundColor Green
        } else {
            Write-Host "[UNCHANGED] Agent configs already present" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[WARNING] Could not merge config: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[SKIP] Global config not found at $GlobalConfig" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done."

# ============================================
# SUMMARY
# ============================================

Write-Host ""
Write-Host "============================================"
Write-Host " INSTALL COMPLETE"
Write-Host "============================================"
Write-Host ""
Write-Host "Skills:    $($New + $Updated + $Skipped) total ($New new, $Updated updated)"
Write-Host "Workflows: $($WNew + $WUpdated + $WSkipped) total ($WNew new, $WUpdated updated)"
Write-Host "Agents:    $($ANew + $AUpdated + $ASkipped) total ($ANew new, $AUpdated updated)"
Write-Host "Commands:  $($CNew + $CUpdated + $CSkipped) total ($CNew new, $CUpdated updated)"
Write-Host ""
Write-Host "Data directory: $DataDir"
Write-Host "Skills directory: $Destination"
Write-Host ""
Write-Host "Done."