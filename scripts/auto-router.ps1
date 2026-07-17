# ============================================
# GOD-OPENCODE AUTO-ROUTER
# Version 2.0
# ============================================
# Intelligent orchestrator that automatically selects
# agents, skills, and workflows for any request.
#
# Usage:
#   $plan = Invoke-AutoRouter -Request "build a fastapi api with auth"
#   $plan.PrimaryAgent
#   $plan.SupportingAgents
#   $plan.Skills
#   $plan.Workflow
#   $plan.Intent
#   $plan.Steps

$ErrorActionPreference = "Stop"

$Root = Split-Path $PSScriptRoot -Parent


# ============================================
# INTENT DETECTION
# ============================================

$IntentPatterns = @{
    "build" = @{
        Keywords = @("build", "create", "scaffold", "generate", "setup", "set up", "start", "new project", "new app", "new api", "new service", "initialize", "spin up", "launch")
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("backend-engineer", "frontend-engineer", "database-architect", "devops-engineer")
        Workflows = @("build-application", "build-project")
        Skills = @("architect", "system-design", "workflow-designer")
    }
    "debug" = @{
        Keywords = @("debug", "fix", "bug", "error", "crash", "broken", "failing", "issue", "problem", "not working", "exception", "stacktrace", "regression", "race condition", "hang", "freeze")
        PrimaryAgent = "debugger"
        SupportingAgents = @("backend-engineer", "frontend-engineer", "security-engineer")
        Workflows = @("bug-investigation", "debug-project", "debug-system")
        Skills = @("bug-hunter", "code-review", "profiling")
    }
    "review" = @{
        Keywords = @("review", "audit code", "code review", "check code", "evaluate code", "assess", "critique")
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("security-engineer", "backend-engineer")
        Workflows = @("review-code")
        Skills = @("code-review", "security", "performance")
    }
    "secure" = @{
        Keywords = @("security", "secure", "vulnerability", "exploit", "pentest", "owasp", "xss", "sqli", "injection", "auth", "authentication", "authorization", "jwt", "oauth", "encrypt", "csrf", "hardening", "threat")
        PrimaryAgent = "security-engineer"
        SupportingAgents = @("backend-engineer", "devops-engineer")
        Workflows = @("security-audit", "security-review")
        Skills = @("security-audit", "secure-coding", "authentication", "penetration-testing")
    }
    "optimize" = @{
        Keywords = @("optimize", "performance", "speed", "fast", "slow", "bottleneck", "latency", "throughput", "cache", "caching", "scale", "scaling", "load test", "profiling", "memory", "cpu")
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("database-architect", "devops-engineer", "backend-engineer")
        Workflows = @("performance-audit")
        Skills = @("performance", "query-optimization", "redis")
    }
    "refactor" = @{
        Keywords = @("refactor", "restructure", "reorganize", "clean up", "cleanup", "technical debt", "simplify", "extract", "modularize", "decouple")
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("backend-engineer", "frontend-engineer")
        Workflows = @("refactor-codebase", "refactor-project")
        Skills = @("refactor", "code-review", "system-design")
    }
    "design" = @{
        Keywords = @("design", "architecture", "architect", "system design", "plan", "blueprint", "adr", "component diagram", "data model", "schema design")
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("database-architect", "backend-engineer")
        Workflows = @()
        Skills = @("architect", "system-design", "api-design", "database-design")
    }
    "test" = @{
        Keywords = @("test", "testing", "unit test", "integration test", "e2e", "coverage", "mock", "stub", "assertion", "pytest", "jest", "vitest")
        PrimaryAgent = "backend-engineer"
        SupportingAgents = @("frontend-engineer", "principal-engineer")
        Workflows = @()
        Skills = @("testing", "e2e-testing", "integration-testing", "test-driven-development")
    }
    "deploy" = @{
        Keywords = @("deploy", "deployment", "ci/cd", "pipeline", "docker", "kubernetes", "k8s", "terraform", "container", "helm", "github actions", "infrastructure", "cloud", "aws", "azure", "gcp")
        PrimaryAgent = "devops-engineer"
        SupportingAgents = @("security-engineer", "backend-engineer")
        Workflows = @("launch-product")
        Skills = @("docker", "kubernetes", "terraform", "github-actions", "ci-cd")
    }
    "api" = @{
        Keywords = @("api", "rest", "graphql", "endpoint", "route", "middleware", "fastapi", "express", "django", "flask", "grpc", "webhook")
        PrimaryAgent = "backend-engineer"
        SupportingAgents = @("security-engineer", "database-architect")
        Workflows = @("api-development")
        Skills = @("api-design", "fastapi", "express", "testing")
    }
    "ai" = @{
        Keywords = @("ai", "llm", "gpt", "claude", "openai", "anthropic", "prompt", "embedding", "rag", "agent", "langchain", "mcp", "vector", "retrieval", "fine-tune", "chatbot", "inference", "model")
        PrimaryAgent = "ai-engineer"
        SupportingAgents = @("backend-engineer")
        Workflows = @("create-ai-agent", "create-mcp-server")
        Skills = @("llm-engineer", "rag-engineer", "prompt-engineer", "agent-builder", "mcp-builder")
    }
    "frontend" = @{
        Keywords = @("frontend", "react", "nextjs", "next.js", "vue", "angular", "css", "html", "ui", "component", "tailwind", "accessibility", "wcag", "responsive", "animation", "state management")
        PrimaryAgent = "frontend-engineer"
        SupportingAgents = @("backend-engineer", "security-engineer")
        Workflows = @()
        Skills = @("react", "nextjs", "typescript", "css-architecture", "state-management", "web-performance")
    }
    "database" = @{
        Keywords = @("database", "sql", "postgres", "postgresql", "mysql", "sqlite", "mongodb", "schema", "migration", "query", "index", "orm", "redis", "nosql", "replication", "sharding")
        PrimaryAgent = "database-architect"
        SupportingAgents = @("backend-engineer", "devops-engineer")
        Workflows = @()
        Skills = @("database-design", "postgres", "redis", "query-optimization", "schema-design")
    }
    "document" = @{
        Keywords = @("documentation", "readme", "docs", "document", "guide", "tutorial", "runbook", "changelog", "adr", "api docs")
        PrimaryAgent = "technical-writer"
        SupportingAgents = @("principal-engineer")
        Workflows = @()
        Skills = @("documentation")
    }
    "research" = @{
        Keywords = @("research", "compare", "investigate", "analysis", "evaluate", "benchmark", "tradeoff", "alternatives", "which", "pros and cons", "best practice")
        PrimaryAgent = "researcher"
        SupportingAgents = @("principal-engineer")
        Workflows = @()
        Skills = @("documentation", "architect")
    }
}


# ============================================
# WORKFLOW TRIGGER KEYWORDS
# ============================================

$WorkflowTriggers = @{
    "build-application" = @("build app", "build application", "full stack", "fullstack", "full-stack", "new project", "new app", "scaffold", "startup", "saas", "mvp")
    "api-development" = @("build api", "create api", "rest api", "graphql api", "api design", "api endpoint", "backend api")
    "security-audit" = @("security audit", "security review", "penetration test", "vulnerability scan", "owasp check", "threat model")
    "bug-investigation" = @("investigate bug", "find bug", "root cause", "debug issue", "fix error", "track down")
    "performance-audit" = @("performance audit", "performance review", "optimize performance", "speed up", "bottleneck analysis")
    "refactor-codebase" = @("refactor code", "clean code", "technical debt", "restructure code", "improve code quality")
    "create-ai-agent" = @("build agent", "create agent", "ai agent", "langchain agent", "tool-using agent")
    "create-mcp-server" = @("build mcp", "create mcp", "mcp server", "mcp tool")
    "launch-product" = @("launch", "go live", "ship", "production ready", "release", "deploy to production")
    "review-code" = @("code review", "review code", "pr review", "pull request review")
}


# ============================================
# MAIN ROUTER FUNCTION
# ============================================

function Invoke-AutoRouter {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Request,

        [string]$CurrentAgent = "",
        [string]$Context = ""
    )

    if (!$Request -or $Request.Trim() -eq '') {
        return Get-DefaultPlan "Empty request"
    }

    $LowerRequest = $Request.ToLower()

    # 1. Detect intent
    $Intent = Detect-Intent -Request $LowerRequest

    # 2. Match workflow
    $Workflow = Match-Workflow -Request $LowerRequest

    # 3. Get primary agent skills
    $PrimarySkills = Get-AgentSkills -AgentName $Intent.PrimaryAgent

    # 4. Get supporting agent skills
    $SupportingSkills = @{}
    foreach ($SA in $Intent.SupportingAgents) {
        $SupportingSkills[$SA] = Get-AgentSkills -AgentName $SA
    }

    # 5. Build execution steps
    $Steps = Build-Steps -Intent $Intent -Workflow $Workflow -Request $Request

    # 6. Detect if we should switch agent mid-flow
    $SwitchPoints = @()
    if ($CurrentAgent -and $CurrentAgent -ne $Intent.PrimaryAgent) {
        $SwitchPoints += @{
            From = $CurrentAgent
            To = $Intent.PrimaryAgent
            Reason = "Request intent changed to $($Intent.Name)"
        }
    }

    return @{
        Intent = $Intent.Name
        PrimaryAgent = $Intent.PrimaryAgent
        SupportingAgents = $Intent.SupportingAgents
        PrimarySkills = $PrimarySkills
        SupportingSkills = $SupportingSkills
        Workflow = $Workflow
        Steps = $Steps
        SwitchPoints = $SwitchPoints
        Request = $Request
        Confidence = $Intent.Confidence
    }
}


# ============================================
# INTENT DETECTION
# ============================================

function Detect-Intent {
    param([string]$Request)

    $BestMatch = $null
    $BestScore = 0

    foreach ($IntentName in $IntentPatterns.Keys) {
        $Intent = $IntentPatterns[$IntentName]
        $Score = 0

        foreach ($Keyword in $Intent.Keywords) {
            if ($Request -match [regex]::Escape($Keyword)) {
                $Score += $Keyword.Length
            }
        }

        if ($Score -gt $BestScore) {
            $BestScore = $Score
            $BestMatch = $IntentName
        }
    }

    if ($BestMatch) {
        return @{
            Name = $BestMatch
            PrimaryAgent = $IntentPatterns[$BestMatch].PrimaryAgent
            SupportingAgents = $IntentPatterns[$BestMatch].SupportingAgents
            Skills = $IntentPatterns[$BestMatch].Skills
            Confidence = [math]::Min(100, $BestScore * 10)
        }
    }

    # Fallback
    return @{
        Name = "general"
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @("backend-engineer", "frontend-engineer")
        Skills = @("architect", "system-design")
        Confidence = 0
    }
}


# ============================================
# WORKFLOW MATCHING
# ============================================

function Match-Workflow {
    param([string]$Request)

    $BestMatch = $null
    $BestScore = 0

    foreach ($WF in $WorkflowTriggers.Keys) {
        $Score = 0
        foreach ($Trigger in $WorkflowTriggers[$WF]) {
            if ($Request -match [regex]::Escape($Trigger)) {
                $Score += $Trigger.Length
            }
        }
        if ($Score -gt $BestScore) {
            $BestScore = $Score
            $BestMatch = $WF
        }
    }

    if ($BestMatch -and $BestScore -gt 0) {
        # Verify workflow file exists
        $WFPath = Join-Path $Root "workflows\$BestMatch.md"
        if (Test-Path $WFPath) {
            return @{
                Name = $BestMatch
                Path = $WFPath
                Matched = $true
            }
        }
    }

    return @{
        Name = $null
        Path = $null
        Matched = $false
    }
}


# ============================================
# AGENT SKILLS EXTRACTION
# ============================================

function Get-AgentSkills {
    param([string]$AgentName)

    $AgentFile = Join-Path $Root "agents\$AgentName\AGENT.md"
    if (!(Test-Path $AgentFile)) { return @() }

    $Lines = Get-Content $AgentFile
    $InSkills = $false
    $Skills = @()

    foreach ($Line in $Lines) {
        if ($Line -match '^## Skills') { $InSkills = $true; continue }
        if ($InSkills -and $Line -match '^##') { break }
        if ($InSkills -and $Line -match '^\s*-\s+(.+)') {
            $Skills += $Matches[1].Trim()
        }
    }

    return $Skills
}


# ============================================
# STEP BUILDER
# ============================================

function Build-Steps {
    param(
        $Intent,
        $Workflow,
        [string]$Request
    )

    $Steps = @()

    if ($Workflow.Matched) {
        # Load workflow steps
        $WFSteps = Get-WorkflowSteps -WorkflowName $Workflow.Name
        foreach ($WS in $WFSteps) {
            $Steps += @{
                Number = $WS.Number
                Title = $WS.Title
                Agent = $WS.Agent
                Skills = $WS.Skills
                Action = $WS.Action
                Source = "workflow"
            }
        }
    } else {
        # Generate steps from intent
        $Steps += @{
            Number = 1
            Title = "Analyze Request"
            Agent = $Intent.PrimaryAgent
            Skills = $Intent.Skills
            Action = "Parse and analyze the request: $Request"
            Source = "auto"
        }
        $Steps += @{
            Number = 2
            Title = "Execute Task"
            Agent = $Intent.PrimaryAgent
            Skills = $Intent.Skills
            Action = "Execute the core task using $($Intent.Skills -join ', ')"
            Source = "auto"
        }
        $Steps += @{
            Number = 3
            Title = "Validate Output"
            Agent = $Intent.PrimaryAgent
            Skills = @("code-review")
            Action = "Review and validate the output for correctness and quality"
            Source = "auto"
        }
    }

    return $Steps
}


# ============================================
# WORKFLOW STEPS PARSER
# ============================================

function Get-WorkflowSteps {
    param([string]$WorkflowName)

    $WFPath = Join-Path $Root "workflows\$WorkflowName.md"
    if (!(Test-Path $WFPath)) { return @() }

    $Lines = Get-Content $WFPath
    $Steps = @()
    $CurrentStep = $null

    foreach ($Line in $Lines) {
        if ($Line -match '^### Step (\d+):?\s*(.*)') {
            if ($CurrentStep) { $Steps += $CurrentStep }
            $CurrentStep = @{
                Number = [int]$Matches[1]
                Title = $Matches[2].Trim()
                Agent = ""
                Skills = @()
                Action = ""
            }
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Agent:\s*(.+)') {
            $CurrentStep.Agent = $Matches[1].Trim()
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Skills:\s*\[(.+)\]') {
            $CurrentStep.Skills = $Matches[1].Trim() -split ',\s*'
        }
        elseif ($CurrentStep -and $Line -match '^\s*-\s+Action:\s*(.+)') {
            $CurrentStep.Action = $Matches[1].Trim()
        }
    }

    if ($CurrentStep) { $Steps += $CurrentStep }
    return $Steps
}


# ============================================
# DEFAULT PLAN
# ============================================

function Get-DefaultPlan {
    param([string]$Reason)

    return @{
        Intent = "general"
        PrimaryAgent = "principal-engineer"
        SupportingAgents = @()
        PrimarySkills = @("architect", "system-design")
        SupportingSkills = @{}
        Workflow = @{ Name = $null; Path = $null; Matched = $false }
        Steps = @()
        SwitchPoints = @()
        Request = ""
        Confidence = 0
        Notice = $Reason
    }
}


# ============================================
# DISPLAY FUNCTION
# ============================================

function Show-AutoRoute {
    param([hashtable]$Plan)

    Write-Host ""
    Write-Host "=========================================="
    Write-Host "  GOD-OPENCODE AUTO-ROUTER"
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "Intent       : $($Plan.Intent) (confidence: $($Plan.Confidence)%)"
    Write-Host "Primary Agent: $($Plan.PrimaryAgent)"
    Write-Host "Skills       : $($Plan.PrimarySkills -join ', ')"
    Write-Host ""

    if ($Plan.SupportingAgents.Count -gt 0) {
        Write-Host "Supporting Agents:"
        foreach ($SA in $Plan.SupportingAgents) {
            Write-Host "  - $SA"
        }
        Write-Host ""
    }

    if ($Plan.Workflow.Matched) {
        Write-Host "Workflow     : $($Plan.Workflow.Name)"
        Write-Host ""
    }

    if ($Plan.SwitchPoints.Count -gt 0) {
        Write-Host "Agent Switches:"
        foreach ($SP in $Plan.SwitchPoints) {
            Write-Host "  $($SP.From) -> $($SP.To) ($($SP.Reason))"
        }
        Write-Host ""
    }

    if ($Plan.Steps.Count -gt 0) {
        Write-Host "Execution Steps:"
        foreach ($Step in $Plan.Steps) {
            Write-Host "  [$($Step.Number)] $($Step.Title)"
            Write-Host "       Agent : $($Step.Agent)"
            if ($Step.Skills.Count -gt 0) {
                Write-Host "       Skills: $($Step.Skills -join ', ')"
            }
            Write-Host "       Source: $($Step.Source)"
        }
        Write-Host ""
    }

    if ($Plan.Notice) {
        Write-Host "Notice: $($Plan.Notice)" -ForegroundColor Yellow
        Write-Host ""
    }
}


# ============================================
# DIRECT INVOCATION
# ============================================
if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.InvocationName -eq '&') {
    # Dot-sourced or called via & — just define functions, don't run
} elseif ($args.Count -gt 0 -or $Request) {
    # Called directly with arguments
    $Req = if ($args.Count -gt 0) { $args[0] } else { $Request }
    $Agent = if ($args.Count -gt 1) { $args[1] } else { "" }

    if (!$Req -or $Req -eq "") {
        Write-Host ""
        Write-Host "Usage: .\scripts\auto-router.ps1 -Request 'describe your task'"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host '  .\scripts\auto-router.ps1 -Request "build a fastapi api with auth"'
        Write-Host '  .\scripts\auto-router.ps1 -Request "debug the login timeout issue"'
        Write-Host '  .\scripts\auto-router.ps1 -Request "security audit the auth flow"'
        Write-Host '  .\scripts\auto-router.ps1 -Request "optimize postgres query performance"'
        Write-Host ""
    } else {
        $Plan = Invoke-AutoRouter -Request $Req -CurrentAgent $Agent
        Show-AutoRoute -Plan $Plan
    }
}
