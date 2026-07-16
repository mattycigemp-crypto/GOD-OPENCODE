# ============================================
# GOD-OPENCODE MASTER INSTALLER
# Version 5.0
# ============================================

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Scripts = Join-Path $Root "scripts"

Clear-Host

Write-Host ""
Write-Host "====================================================="
Write-Host "               GOD-OPENCODE v5"
Write-Host "====================================================="
Write-Host ""

function Banner($Text){
    Write-Host ""
    Write-Host "-----------------------------------------------------"
    Write-Host $Text
    Write-Host "-----------------------------------------------------"
}

function EnsureFolder($Folder){

    if(!(Test-Path $Folder)){
        New-Item -ItemType Directory -Force -Path $Folder | Out-Null
        Write-Host "[CREATED] $Folder"
    }
    else{
        Write-Host "[OK]      $Folder"
    }

}

function RunStep{

    param(
        [string]$Title,
        [string]$Script
    )

    Banner $Title

    $Path = Join-Path $Scripts $Script

    if(Test-Path $Path){

        try{

            & $Path

            Write-Host ""
            Write-Host "[SUCCESS] $Title"

        }

        catch{

            Write-Host ""
            Write-Host "[FAILED] $Title"
            Write-Host $_

        }

    }

    else{

        Write-Host "[SKIPPED] $Script not found."

    }

}



# =====================================================
# DIRECTORY STRUCTURE
# =====================================================

Banner "Checking Folder Structure"

$Folders=@(

"agents",
"backups",
"commands",
"config",
"logs",
"mcps",
"memory",
"models",
"prompts",
"router",
"scripts",
"skills",
"templates",
"tools",
"workflows"

)

foreach($Folder in $Folders){

    EnsureFolder (Join-Path $Root $Folder)

}



# =====================================================
# BUILD
# =====================================================

RunStep "Builder Engine" "god-builder.ps1"

RunStep "Expansion Engine" "god-expansion.ps1"

RunStep "Intelligence Engine" "god-intelligence.ps1"

RunStep "Skill Upgrader" "upgrade-all-skills.ps1"



# =====================================================
# INSTALL SKILLS
# =====================================================

Banner "Installing OpenCode Skills"

$Installer = Join-Path $Root "install.ps1"

if(Test-Path $Installer){

    & $Installer

}
else{

    Write-Host "install.ps1 missing."

}



# =====================================================
# MCPS
# =====================================================

RunStep "MCP Manager" "install-mcps.ps1"



# =====================================================
# OPTIONAL MODULES
# =====================================================

RunStep "Verification" "verify.ps1"

RunStep "Health Check" "god-health.ps1"

RunStep "Status Generator" "god-status.ps1"



# =====================================================
# SUMMARY
# =====================================================

Banner "Summary"

$Summary = @{}

$Summary["Skills"] =
    if(Test-Path "$HOME\.config\opencode\skills"){
        (Get-ChildItem "$HOME\.config\opencode\skills" -Directory).Count
    }else{0}

$Summary["Agents"] =
    if(Test-Path "$Root\agents"){
        (Get-ChildItem "$Root\agents" -Directory).Count
    }else{0}

$Summary["Workflows"] =
    if(Test-Path "$Root\workflows"){
        (Get-ChildItem "$Root\workflows" -File).Count
    }else{0}

$Summary["Templates"] =
    if(Test-Path "$Root\templates"){
        (Get-ChildItem "$Root\templates" -Directory).Count
    }else{0}

$Summary["Prompts"] =
    if(Test-Path "$Root\prompts"){
        (Get-ChildItem "$Root\prompts" -Directory).Count
    }else{0}

$Summary["MCP Registry"] =
    if(Test-Path "$Root\mcps\registry.json"){
        "Present"
    }else{
        "Missing"
    }

$Summary.GetEnumerator() | ForEach-Object{
    "{0,-15}: {1}" -f $_.Key,$_.Value
}

Write-Host ""
Write-Host "====================================================="
Write-Host "          GOD-OPENCODE READY"
Write-Host "====================================================="
Write-Host ""
Write-Host "Run this anytime:"
Write-Host ""
Write-Host "    .\god-install.ps1"
Write-Host ""