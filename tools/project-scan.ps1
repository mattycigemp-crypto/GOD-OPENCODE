# ============================================
# GOD-OPENCODE PROJECT SCANNER
# Version 1.0
# ============================================
# Usage: .\tools\project-scan.ps1 -TargetPath "C:\path\to\project"

param(
    [string]$TargetPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

# ============================================
# LANGUAGE DETECTION
# ============================================

$ExtensionMap = @{
    ".py"     = "Python"
    ".ts"     = "TypeScript"
    ".tsx"    = "TypeScript"
    ".js"     = "JavaScript"
    ".jsx"    = "JavaScript"
    ".go"     = "Go"
    ".rs"     = "Rust"
    ".java"   = "Java"
    ".cs"     = "C#"
    ".cpp"    = "C++"
    ".c"      = "C"
    ".rb"     = "Ruby"
    ".php"    = "PHP"
    ".swift"  = "Swift"
    ".kt"     = "Kotlin"
    ".sh"     = "Shell"
    ".ps1"    = "PowerShell"
    ".tf"     = "Terraform"
    ".yaml"   = "YAML"
    ".yml"    = "YAML"
    ".json"   = "JSON"
    ".md"     = "Markdown"
    ".sql"    = "SQL"
    ".html"   = "HTML"
    ".css"    = "CSS"
    ".scss"   = "CSS"
}

function Get-LanguageCounts($Path) {
    $Counts = @{}
    $Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|__pycache__|\.venv|dist|build)\\' }

    foreach ($File in $Files) {
        $Ext = $File.Extension.ToLower()
        if ($ExtensionMap.ContainsKey($Ext)) {
            $Lang = $ExtensionMap[$Ext]
            if (!$Counts.ContainsKey($Lang)) { $Counts[$Lang] = 0 }
            $Counts[$Lang] = $Counts[$Lang] + 1
        }
    }
    return $Counts
}

# ============================================
# PROJECT TYPE DETECTION
# ============================================

function Get-ProjectType($Path) {
    $HasPackageJson   = Test-Path (Join-Path $Path "package.json")
    $HasPyproject     = Test-Path (Join-Path $Path "pyproject.toml")
    $HasRequirements  = Test-Path (Join-Path $Path "requirements.txt")
    $HasDockerfile    = Test-Path (Join-Path $Path "Dockerfile")
    $HasOpenAPI       = (Test-Path (Join-Path $Path "openapi.yaml")) -or (Test-Path (Join-Path $Path "openapi.json"))
    $HasNextConfig    = Test-Path (Join-Path $Path "next.config.js") -or (Test-Path (Join-Path $Path "next.config.ts"))
    $HasViteConfig    = Test-Path (Join-Path $Path "vite.config.ts") -or (Test-Path (Join-Path $Path "vite.config.js"))
    $HasCargoToml     = Test-Path (Join-Path $Path "Cargo.toml")
    $HasGoMod         = Test-Path (Join-Path $Path "go.mod")
    $HasMainPy        = Test-Path (Join-Path $Path "main.py")
    $HasDockerCompose = Test-Path (Join-Path $Path "docker-compose.yml") -or (Test-Path (Join-Path $Path "docker-compose.yaml"))

    # Detect src/app directories
    $HasSrcApp = (Test-Path (Join-Path $Path "src\app")) -or (Test-Path (Join-Path $Path "app"))
    $HasPublic = Test-Path (Join-Path $Path "public")

    if ($HasNextConfig) { return "fullstack" }
    if ($HasViteConfig -and $HasPackageJson) { return "frontend-app" }
    if ($HasPackageJson -and $HasPublic -and -not $HasOpenAPI) { return "frontend-app" }
    if ($HasOpenAPI -or ($HasPyproject -and $HasMainPy)) { return "api" }
    if ($HasRequirements -and $HasMainPy) { return "api" }
    if ($HasCargoToml) { return "cli-tool" }
    if ($HasGoMod) { return "cli-tool" }
    if ($HasDockerCompose -and $HasDockerfile) { return "fullstack" }
    if ($HasPackageJson -and -not $HasPublic) { return "api" }
    return "unknown"
}

# ============================================
# WORKFLOW RECOMMENDATION
# ============================================

function Get-RecommendedWorkflow($ProjectType, $Languages) {
    switch ($ProjectType) {
        "api"          { return "api-development" }
        "frontend-app" { return "build-application" }
        "fullstack"    { return "build-application" }
        "cli-tool"     { return "build-application" }
        "library"      { return "build-application" }
        default        { return "build-application" }
    }
}

# ============================================
# AGENT + SKILL RECOMMENDATION
# ============================================

function Get-RecommendedAgents($ProjectType, $Languages) {
    $Agents = @("principal-engineer")
    $TopLangs = ($Languages.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 3).Name

    foreach ($Lang in $TopLangs) {
        switch ($Lang) {
            "Python"     { if ("backend-engineer"  -notin $Agents) { $Agents += "backend-engineer" } }
            "TypeScript" { if ("frontend-engineer" -notin $Agents) { $Agents += "frontend-engineer" } }
            "JavaScript" { if ("frontend-engineer" -notin $Agents) { $Agents += "frontend-engineer" } }
            "Go"         { if ("backend-engineer"  -notin $Agents) { $Agents += "backend-engineer" } }
            "Rust"       { if ("backend-engineer"  -notin $Agents) { $Agents += "backend-engineer" } }
            "SQL"        { if ("database-architect" -notin $Agents) { $Agents += "database-architect" } }
            "Terraform"  { if ("devops-engineer"   -notin $Agents) { $Agents += "devops-engineer" } }
            "PowerShell" { if ("devops-engineer"   -notin $Agents) { $Agents += "devops-engineer" } }
        }
    }

    switch ($ProjectType) {
        "api"       { if ("backend-engineer"   -notin $Agents) { $Agents += "backend-engineer" } }
        "fullstack" { if ("frontend-engineer"  -notin $Agents) { $Agents += "frontend-engineer" } }
    }

    return $Agents
}

function Get-RecommendedSkills($Agents) {
    $AgentSkillMap = @{
        "principal-engineer"  = @("system-design","architect","code-review","principal-engineer")
        "backend-engineer"    = @("api-design","database-design","testing","security")
        "frontend-engineer"   = @("react-expert","typescript-expert","testing","performance")
        "ai-engineer"         = @("ai-engineer","llm-engineer","prompt-engineer","rag-engineer")
        "security-engineer"   = @("security-audit","secure-coding","authentication")
        "database-architect"  = @("database-design","postgres","redis")
        "devops-engineer"     = @("docker","github-actions","ci-cd","terraform")
        "debugger"            = @("debugger","bug-hunter","code-review")
        "researcher"          = @("documentation","architect")
        "technical-writer"    = @("documentation","code-review")
    }

    $Skills = @()
    foreach ($Agent in $Agents) {
        if ($AgentSkillMap.ContainsKey($Agent)) {
            foreach ($Skill in $AgentSkillMap[$Agent]) {
                if ($Skill -notin $Skills) { $Skills += $Skill }
            }
        }
    }
    return $Skills
}

# ============================================
# IMPROVEMENTS GENERATOR
# ============================================

function Get-Improvements($ProjectType, $Languages, $Path) {
    $Improvements = @()
    $Priority = 1

    # Universal improvements
    if (!(Test-Path (Join-Path $Path ".github\workflows"))) {
        $Improvements += @{ Priority=$Priority; Description="Add CI/CD pipeline"; Rationale="No GitHub Actions workflows found. Automated testing and deployment prevents regressions." }
        $Priority++
    }
    if (!(Test-Path (Join-Path $Path ".env.example")) -and !(Test-Path (Join-Path $Path ".env.sample"))) {
        $Improvements += @{ Priority=$Priority; Description="Add .env.example file"; Rationale="No environment variable template found. Document all required environment variables." }
        $Priority++
    }
    if (!(Test-Path (Join-Path $Path "README.md"))) {
        $Improvements += @{ Priority=$Priority; Description="Add README.md"; Rationale="No README found. Document setup, usage, and architecture for contributors." }
        $Priority++
    }
    if (!(Test-Path (Join-Path $Path "Dockerfile")) -and $ProjectType -in @("api","fullstack","frontend-app")) {
        $Improvements += @{ Priority=$Priority; Description="Add Dockerfile for containerization"; Rationale="No Dockerfile found. Containerization ensures consistent deployments." }
        $Priority++
    }
    if ($Languages.ContainsKey("Python") -and !(Test-Path (Join-Path $Path "tests"))) {
        $Improvements += @{ Priority=$Priority; Description="Add test suite"; Rationale="No tests/ directory found. Automated tests prevent regressions and document behavior." }
        $Priority++
    }
    if ($Languages.ContainsKey("TypeScript") -and !(Test-Path (Join-Path $Path "tsconfig.json"))) {
        $Improvements += @{ Priority=$Priority; Description="Add tsconfig.json"; Rationale="TypeScript files found but no tsconfig.json. Configure strict mode for maximum type safety." }
        $Priority++
    }

    return $Improvements
}

# ============================================
# IMPLEMENTATION PLAN GENERATOR
# ============================================

function Invoke-ProjectScan {
    param(
        [string]$Path = (Get-Location).Path
    )

    $ProjectName = Split-Path $Path -Leaf
    $Timestamp   = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")

    Write-Host ""
    Write-Host "=============================="
    Write-Host "  PROJECT SCAN: $ProjectName"
    Write-Host "=============================="
    Write-Host ""

    # Detect languages
    $LangCounts = Get-LanguageCounts $Path
    $TopLangs   = ($LangCounts.GetEnumerator() | Sort-Object Value -Descending | Where-Object { $_.Name -notin @("YAML","JSON","Markdown") } | Select-Object -First 5)
    $PrimaryLangs = $TopLangs.Name

    # Detect project type
    $ProjectType = Get-ProjectType $Path
    Write-Host "Project type  : $ProjectType"
    Write-Host "Languages     : $($PrimaryLangs -join ', ')"

    # Select workflow, agents, skills
    $Workflow     = Get-RecommendedWorkflow $ProjectType $LangCounts
    $Agents       = Get-RecommendedAgents  $ProjectType $LangCounts
    $Skills       = Get-RecommendedSkills  $Agents
    $Improvements = Get-Improvements $ProjectType $LangCounts $Path

    # Build plan document
    $ImprovementsList = ($Improvements | ForEach-Object {
        "$($_.Priority). $($_.Description) - $($_.Rationale)"
    }) -join "`n"
    if ($ImprovementsList -eq "") { $ImprovementsList = "No critical improvements identified." }

    $Plan = @"
# Implementation Plan — $ProjectName

## Detected Project Type

$ProjectType

## Primary Languages

$($PrimaryLangs -join ', ')

## Recommended Workflow

$Workflow

## Assigned Agents

$($Agents | ForEach-Object { "- $_" } | Out-String)

## Applied Skills

$($Skills | ForEach-Object { "- $_" } | Out-String)

## Prioritized Improvements

$ImprovementsList
"@

    # Store in memory system
    $MemoryDir = Join-Path $Root "memory"
    if (!(Test-Path $MemoryDir)) {
        New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null
    }

    $SlugBase = $ProjectName.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-'
    $Slug     = "adr-scan-$SlugBase"
    $MemFile  = Join-Path $MemoryDir "$Slug.md"

    $MemContent = @"
---
type: architecture-decision
title: Project Scan — $ProjectName
timestamp: $Timestamp
author: god-intelligence
---

$Plan
"@
    Set-Content -Path $MemFile -Value $MemContent -Encoding UTF8
    Write-Host ""
    Write-Host "[MEMORY] Scan result saved: $MemFile"
    Write-Host ""

    # Output plan to console
    Write-Host $Plan
    return $Plan
}

# ============================================
# ENTRY POINT
# ============================================
Invoke-ProjectScan -Path $TargetPath
