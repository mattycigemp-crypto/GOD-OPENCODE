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
    $Global = $null
    $Source = $null
    try {
        $Global = Get-Content $GlobalConfig -Raw | ConvertFrom-Json
        $Source = Get-Content $SourceConfig -Raw | ConvertFrom-Json
    } catch {
        Write-Host "[WARNING] Could not parse global config: $_" -ForegroundColor Yellow
        Write-Host "[WARNING] Fix the JSON/JSONC syntax in $GlobalConfig and re-run." -ForegroundColor Yellow
    }

    if ($Global -and $Source) {
        $Merged = $false

        # Merge agents - append only new agent names, never overwrite existing user customizations
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

        # Merge commands - append only new command names, never overwrite existing user customizations
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

        # Merge instructions - deep-merge by appending new entries (supports glob patterns)
        if ($Source.instructions) {
            $ExistingInstructions = @()
            if ($Global.instructions) {
                $ExistingInstructions = @($Global.instructions)
            }
            foreach ($Inst in $Source.instructions) {
                if ($Inst -notin $ExistingInstructions) {
                    $ExistingInstructions += $Inst
                    $Merged = $true
                }
            }
            if ($ExistingInstructions.Count -gt 0) {
                $Global.instructions = $ExistingInstructions
            }
        }

        # Merge permission rules - deep-merge: preserve user's allow/deny, append new deny entries
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
                        continue
                    }

                    # Merge deny arrays - union, never clobber user's existing entries
                    if ($SourceTool.deny) {
                        $GlobalDeny = @()
                        if ($GlobalTool.deny) { $GlobalDeny = @($GlobalTool.deny) }
                        foreach ($Entry in $SourceTool.deny) {
                            if ($Entry -notin $GlobalDeny) {
                                $GlobalDeny += $Entry
                                $Merged = $true
                            }
                        }
                        $GlobalTool.deny = $GlobalDeny
                    }

                    # Merge allow arrays - union, preserving user's custom allows
                    if ($SourceTool.allow) {
                        $GlobalAllow = @()
                        if ($GlobalTool.allow) { $GlobalAllow = @($GlobalTool.allow) }
                        foreach ($Entry in $SourceTool.allow) {
                            if ($Entry -notin $GlobalAllow) {
                                $GlobalAllow += $Entry
                                $Merged = $true
                            }
                        }
                        $GlobalTool.allow = $GlobalAllow
                    }
                }
            }
        }

        if ($Merged) {
            $Global | ConvertTo-Json -Depth 10 | Set-Content $GlobalConfig -Encoding UTF8
            Write-Host "[MERGED] Agent configs added to $GlobalConfig" -ForegroundColor Green
            Write-Host "[NOTE] JSONC comments in $GlobalConfig are not preserved (round-trip via ConvertTo-Json)." -ForegroundColor Yellow
            Write-Host "[NOTE] Back up the file before re-running if it contains custom comments." -ForegroundColor Yellow
        } else {
            Write-Host "[UNCHANGED] Agent configs already present" -ForegroundColor Yellow
        }
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