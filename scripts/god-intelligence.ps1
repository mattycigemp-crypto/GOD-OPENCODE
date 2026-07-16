# ============================================
# GOD-OPENCODE INTELLIGENCE ENGINE
# Version 1.0
# ============================================

$Root = Split-Path $PSScriptRoot -Parent


function Ensure($Path){

    if(!(Test-Path $Path)){
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "[CREATED] $Path"
    }
    else{
        Write-Host "[EXISTS] $Path"
    }

}


function Create($Path,$Content){

    if(!(Test-Path $Path)){
        Set-Content $Path $Content
        Write-Host "[NEW] $Path"
    }
    else{
        Write-Host "[SKIP] $Path"
    }

}



# ============================================
# COMMAND SYSTEM
# ============================================

Ensure "$Root\commands"


$Commands = @{
"build"="Build a complete production application."
"debug"="Analyze and fix problems."
"review"="Perform senior code review."
"architect"="Design system architecture."
"secure"="Perform security audit."
"optimize"="Improve performance."
}


foreach($Command in $Commands.Keys){

$content=@"
# /$Command

Purpose:

$($Commands[$Command])

Workflow:

1. Analyze request.
2. Select agent.
3. Select skills.
4. Execute task.
5. Validate output.

"@

Create "$Root\commands\$Command.md" $content

}



# ============================================
# ROUTER
# ============================================

Ensure "$Root\router"


Create "$Root\router\agent-router.json" @"
{
 "routing":{
   "frontend":"frontend-engineer",
   "react":"frontend-engineer",
   "backend":"backend-engineer",
   "api":"backend-engineer",
   "database":"database-architect",
   "sql":"database-architect",
   "ai":"ai-engineer",
   "llm":"ai-engineer",
   "security":"security-engineer",
   "debug":"debugger"
 }
}
"@



# ============================================
# PROJECT ANALYZER
# ============================================

Ensure "$Root\tools"


Create "$Root\tools\project-scan.ps1" @'
Write-Host ""
Write-Host "===== PROJECT SCAN ====="

Write-Host ""

Write-Host "Files:"
(Get-ChildItem -Recurse -File).Count

Write-Host ""

Write-Host "Languages detected:"

Get-ChildItem -Recurse -File |
Select-Object Extension |
Sort-Object Extension |
Get-Unique

Write-Host ""

Write-Host "Scan Complete"
'@



# ============================================
# MODEL ROUTER
# ============================================

Ensure "$Root\models"


Create "$Root\models\router.json" @"
{
 "local":{
   "ollama":true,
   "lmstudio":true
 },
 "routing":{
   "simple":"local",
   "private":"local",
   "architecture":"large",
   "complex":"cloud"
 }
}
"@



# ============================================
# HEALTH CHECK
# ============================================

Create "$Root\god-health.ps1" @'

Write-Host ""
Write-Host "===== GOD-OPENCODE HEALTH ====="

$Checks=@(
"skills",
"agents",
"mcps",
"prompts",
"workflows",
"templates",
"memory"
)

foreach($Check in $Checks){

if(Test-Path "$PSScriptRoot\$Check"){
Write-Host "[OK] $Check"
}
else{
Write-Host "[MISSING] $Check"
}

}

Write-Host ""
Write-Host "System Check Complete"

'@



# ============================================
# BACKUP SYSTEM
# ============================================

Create "$Root\god-backup.ps1" @'

$Date = Get-Date -Format "yyyy-MM-dd-HH-mm"

$Backup = "$PSScriptRoot\backups\$Date"

New-Item -ItemType Directory -Path $Backup -Force | Out-Null

Copy-Item "$PSScriptRoot\*" $Backup -Recurse -Force

Write-Host "Backup created:"
Write-Host $Backup

'@



Write-Host ""
Write-Host "================================"
Write-Host " GOD INTELLIGENCE COMPLETE"
Write-Host "================================"