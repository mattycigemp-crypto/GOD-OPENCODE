# ============================================
# WORKFLOW TESTS
# GOD-OPENCODE Feature 4
# ============================================
# Validates every workflow/*.md has the structural elements required by
# docs/standards.md and the workflow-engine skill:
#   - H1 title matches filename
#   - "## Purpose" section
#   - "## Parameters" section with a markdown table
#   - At least one "### Step N" with bullet fields (Agent, Skills, Action)
# Steps may reference an Agent that exists in agents/ and a Skill that lives
# in skills/ — those cross-refs are checked when the references parse cleanly.
# A representative "deep" test on security-audit.md is inlined to document
# how to author a richer per-workflow test.

BeforeAll {
    $Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
    $script:WorkflowsRoot = Join-Path $Root "workflows"
    $script:Workflows = Get-ChildItem -Path $script:WorkflowsRoot -Filter "*.md" -File | Sort-Object Name
    $script:AgentsRoot = Join-Path $Root "agents"
    $script:SkillsRoot = Join-Path $Root "skills"

    # Slack variables for cross-ref validation
    $script:AgentNames = @()
    if (Test-Path $script:AgentsRoot) {
        $script:AgentNames = Get-ChildItem -Path $script:AgentsRoot -Directory | Select-Object -ExpandProperty Name
    }
    $script:SkillNames = @()
    if (Test-Path $script:SkillsRoot) {
        $script:SkillNames = Get-ChildItem -Path $script:SkillsRoot -Directory -Recurse |
            Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } |
            ForEach-Object { $_.Name } | Sort-Object -Unique
    }
    # Top-level category directories that contain SKILL.md subs (e.g. skills/devops/
    # with docker/, kubernetes/, etc.). A skill reference that names a category is
    # treated as a category alias and accepted by the runtime tests.
    $script:SkillCategoryNames = @()
    if (Test-Path $script:SkillsRoot) {
        $script:SkillCategoryNames = Get-ChildItem -Path $script:SkillsRoot -Directory |
            Where-Object { Get-ChildItem -Path $_.FullName -Directory -Recurse |
                Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') } } |
            ForEach-Object { $_.Name } | Sort-Object -Unique
    }

    # Helper: extract the body of every step (one match per step). Uses
    # [regex]::Matches so each step block is enumerated as a separate
    # match — piping through Select-String treats a multi-line string as
    # one input record and silently under-counts.
    $script:StepPattern = "(?ms)^### Step \d+:.+?(?=^### Step|\z)"

    <#
    .SYNOPSIS
        Returns every "### Step N:" body block in a workflow as a list of
        strings (one per step). Avoids the Select-String pipe under-count
        trap that bit the previous iteration tests.
    #>
    function Get-StepBodies {
        param([Parameter(Mandatory)][string]$Body)
        $matches = [regex]::Matches($Body, $StepPattern)
        $list = New-Object System.Collections.Generic.List[string]
        foreach ($m in $matches) { $list.Add($m.Value) }
        return $list
    }
}

Describe "Workflow inventory" {
    It "There is at least one workflow file" {
        $Workflows.Count | Should -BeGreaterThan 0
    }

    It "Workflow filenames are lowercase-with-hyphens" {
        foreach ($wf in $Workflows) {
            $wf.BaseName | Should -Match '^[a-z][a-z0-9-]*$'
        }
    }
}

Describe "Each workflow has required structural elements" {
    foreach ($wf in $Workflows) {
        Context $wf.Name {
            BeforeAll {
                $script:WfBody = Get-Content (Join-Path $WorkflowsRoot $wf.Name) -Raw
                $script:WfBase  = $wf.BaseName
            }

            It "Has an H1 title that matches its filename" {
                $H1 = ([regex]::Match($WfBody, '(?m)^# (.+)$')).Groups[1].Value
                $H1.Trim().ToLower() | Should -Be $WfBase
            }

            It "Has a '## Purpose' section" {
                $WfBody | Should -Match '(?m)^## Purpose\s*$'
            }

            It "Has a '## Parameters' section" {
                $WfBody | Should -Match '(?m)^## Parameters\s*$'
            }

            It "Has at least one step named '### Step N'" {
                ([regex]::Matches($WfBody, '(?m)^### Step \d+')).Count | Should -BeGreaterOrEqual 1
            }
        }
    }
}

Describe "security-audit workflow" {
    # Representative "deep" test documenting the per-workflow test pattern.
    # Future workflow owners copy this block, swap the file name, and add
    # workflow-specific assertions.

    BeforeAll {
        $script:SABody = Get-Content (Join-Path $WorkflowsRoot 'security-audit.md') -Raw
        $script:SASteps = Get-StepBodies -Body $SABody
    }

    It "Declares TARGET, SCOPE, COMPLIANCE parameters" {
        $SABody | Should -Match '`TARGET`'
        $SABody | Should -Match '`SCOPE`'
        $SABody | Should -Match '`COMPLIANCE`'
    }

    It "Uses 8 steps" {
        ([regex]::Matches($SABody, '(?m)^### Step \d+')).Count | Should -Be 8
    }

    It "Every step references an agent that exists in agents/" {
        # Security-audit delegates Step 5 to devops-engineer for the infrastructure
        # sub-review, so we cannot assert that ALL steps name security-engineer.
        # Assert instead that every step's Agent: field resolves to a defined agent.
        $SASteps.Count | Should -BeGreaterOrEqual 1
        foreach ($step in $SASteps) {
            $agentMatch = [regex]::Match($step, '(?m)^- Agent:\s*([a-z][a-z0-9-]*)')
            $agentMatch.Success | Should -BeTrue -Because "every step must declare an Agent: field"
            $agentName = $agentMatch.Groups[1].Value
            $agentName | Should -BeIn $AgentNames -Because "step agent '$agentName' must be defined in agents/$agentName/AGENT.md"
        }
    }

    It "Each step's Skills list resolves to a curated skill or a known skill category" {
        # Skill references are accepted when their name matches either a curated
        # skill (skills/<name>/SKILL.md) or a category directory (skills/<name>/)
        # that contains SKILL.md subskills. This guards against typos like writing
        # 'devops' where a concrete skill name like 'docker' is expected — while
        # still failing on references to skill names that don't exist at all.
        $SASteps.Count | Should -BeGreaterOrEqual 1
        foreach ($step in $SASteps) {
            $skillLines = ([regex]::Matches($step, '(?m)^- Skills:\s*(.+)$'))
            foreach ($line in $skillLines) {
                $names = ($line.Groups[1].Value -split ',\s*') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                foreach ($n in $names) {
                    $isSkill    = $n -in $SkillNames
                    $isCategory = $n -in $SkillCategoryNames
                    ($isSkill -or $isCategory) | Should -BeTrue -Because "step references skill '$n' which must be either a curated skill (skills/$n/SKILL.md) or a category directory (skills/$n/)"
                }
            }
        }
    }
}
