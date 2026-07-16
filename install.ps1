# ============================================
# GOD-OPENCODE SMART SKILL INSTALLER
# Version 2.0
# ============================================

$Source = Join-Path $PSScriptRoot "skills"
$Destination = Join-Path $HOME ".config\opencode\skills"

Write-Host ""
Write-Host "============================================"
Write-Host "     GOD-OPENCODE SMART INSTALLER"
Write-Host "============================================"
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

    }

    else {

        $SourceHash = Get-FileHash $SkillFile
        $TargetHash = Get-FileHash $TargetFile


        if ($SourceHash.Hash -ne $TargetHash.Hash) {

            Copy-Item $SkillFile $TargetFile -Force

            Write-Host "[UPDATED] $($Skill.Name)"

            $Updated++

        }

        else {

            Write-Host "[UNCHANGED] $($Skill.Name)"

            $Skipped++

        }

    }
}


Write-Host ""
Write-Host "============================================"
Write-Host " INSTALL SUMMARY"
Write-Host "============================================"

Write-Host "New:       $New"
Write-Host "Updated:   $Updated"
Write-Host "Skipped:   $Skipped"

Write-Host ""
Write-Host "Done."