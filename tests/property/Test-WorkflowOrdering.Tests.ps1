# Feature: god-opencode, Property 19: Workflow Step Ordering
# Feature: god-opencode, Property 20: Workflow Parameterization Substitution
# Run: Invoke-Pester -Path .\tests\property\ -Output Detailed

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    . (Join-Path $Root "scripts\workflow-engine.ps1")
    $WorkflowFiles = Get-ChildItem (Join-Path $Root "workflows") -Filter "*.md"
}

Describe "Property 19: Workflow Step Ordering" {
    # Steps in each workflow must appear in ascending sequential order.
    It "Workflow '<name>' has steps in ascending order" -ForEach (
        $WorkflowFiles | ForEach-Object { @{ name = $_.BaseName; path = $_.FullName } }
    ) {
        $Lines = Get-Content $path
        $StepNumbers = @()
        foreach ($Line in $Lines) {
            if ($Line -match '^### Step (\d+)') {
                $StepNumbers += [int]$Matches[1]
            }
        }

        if ($StepNumbers.Count -eq 0) {
            Set-ItResult -Skipped -Because "Workflow '$name' has no ### Step N: entries"
            return
        }

        for ($i = 0; $i -lt ($StepNumbers.Count - 1); $i++) {
            $StepNumbers[$i + 1] | Should -Be ($StepNumbers[$i] + 1)
        }
    }
}

Describe "Property 20: Workflow Parameterization Substitution" {
    # When all required params are supplied, no {{PARAM}} placeholders remain.
    It "build-application substitution resolves all placeholders" {
        $Params = @{
            PROJECT_NAME  = "MyApp"
            STACK         = "FastAPI + React"
            DESCRIPTION   = "A test application"
            DEPLOY_TARGET = "Docker"
        }
        $Result = Invoke-WorkflowSubstitution -WorkflowName "build-application" -Params $Params
        $Result | Should -Not -Match "\{\{[A-Z_]+\}\}"
    }

    It "api-development substitution resolves all placeholders" {
        $Params = @{
            API_NAME    = "TestAPI"
            FRAMEWORK   = "FastAPI"
            AUTH_METHOD = "JWT"
            DATABASE    = "PostgreSQL"
        }
        $Result = Invoke-WorkflowSubstitution -WorkflowName "api-development" -Params $Params
        $Result | Should -Not -Match "\{\{[A-Z_]+\}\}"
    }

    It "security-audit substitution resolves all placeholders" {
        $Params = @{
            TARGET     = "OrderService"
            SCOPE      = "full-stack"
            COMPLIANCE = "OWASP"
        }
        $Result = Invoke-WorkflowSubstitution -WorkflowName "security-audit" -Params $Params
        $Result | Should -Not -Match "\{\{[A-Z_]+\}\}"
    }

    It "bug-investigation substitution resolves all placeholders" {
        $Params = @{
            BUG_DESCRIPTION = "Duplicate emails"
            COMPONENT       = "auth_service"
            ENVIRONMENT     = "production"
            SEVERITY        = "high"
        }
        $Result = Invoke-WorkflowSubstitution -WorkflowName "bug-investigation" -Params $Params
        $Result | Should -Not -Match "\{\{[A-Z_]+\}\}"
    }

    It "Missing required parameter throws an error with placeholder name" {
        $Params = @{ STACK = "FastAPI" }  # Missing PROJECT_NAME, DESCRIPTION, DEPLOY_TARGET
        { Invoke-WorkflowSubstitution -WorkflowName "build-application" -Params $Params } | Should -Throw
    }
}

Describe "Workflow files have required structural sections" {
    $RequiredWorkflows = @("build-application","api-development","security-audit","bug-investigation")
    It "Workflow '<wf>' has '## Purpose' section" -ForEach (
        $RequiredWorkflows | ForEach-Object { @{ wf = $_ } }
    ) {
        $Content = Get-Content (Join-Path $Root "workflows\$wf.md") -Raw
        $Content | Should -Match "## Purpose"
    }
    It "Workflow '<wf>' has '## Parameters' section" -ForEach (
        $RequiredWorkflows | ForEach-Object { @{ wf = $_ } }
    ) {
        $Content = Get-Content (Join-Path $Root "workflows\$wf.md") -Raw
        $Content | Should -Match "## Parameters"
    }
    It "Workflow '<wf>' has at least one '### Step' entry" -ForEach (
        $RequiredWorkflows | ForEach-Object { @{ wf = $_ } }
    ) {
        $Content = Get-Content (Join-Path $Root "workflows\$wf.md") -Raw
        $Content | Should -Match "### Step \d+"
    }
}
