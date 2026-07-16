# ============================================
# GOD-OPENCODE EXPANSION ENGINE
# Version 2.0
# ============================================
# Extends the skill and prompt libraries with
# additional entries not covered by god-builder.

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")
$Root = Get-ProjectRoot

Write-Banner "GOD-OPENCODE EXPANSION ENGINE"

# ============================================
# TESTING SKILL CATEGORY
# ============================================

EnsureFolder "$Root\skills\testing"

$TestingSkills = @(
    "unit-testing",
    "integration-testing",
    "e2e-testing",
    "test-driven-development",
    "property-based-testing"
)

foreach ($Skill in $TestingSkills) {
    EnsureFolder "$Root\skills\testing\$Skill"
    $Content = @"
---
name: $Skill
description: Expert-level $Skill workflow for production software.
---

# $Skill

## Mission

Ensure software correctness through systematic $Skill practices.

## Core Responsibilities

- Design comprehensive test cases covering happy paths, edge cases, and failure modes.
- Write readable, maintainable tests that serve as living documentation.
- Achieve meaningful coverage targets without gaming metrics.
- Automate test execution in CI/CD pipelines.
- Prevent regressions from reaching production.

## Workflow

1. Understand the behavior being tested.
2. Identify inputs, outputs, and side effects.
3. Design test cases: happy path, boundaries, error conditions.
4. Implement tests before or alongside production code.
5. Run tests in isolation with proper setup/teardown.
6. Integrate with CI/CD for automated execution.

## Quality Standards

Always:
- Name tests to describe the expected behavior, not the implementation.
- Test one thing per test case.
- Keep tests deterministic - no random or time-dependent behavior without mocking.
- Clean up side effects in teardown.

Never:
- Write tests that only verify the happy path.
- Assert on implementation details - assert on behavior.
- Leave flaky tests in the suite.
"@
    Write-IfChanged "$Root\skills\testing\$Skill\SKILL.md" $Content
}

# ============================================
# DATABASE SKILL CATEGORY
# ============================================

EnsureFolder "$Root\skills\database"

$DbSkills = @("schema-design", "query-optimization", "data-migration", "replication", "sharding")

foreach ($Skill in $DbSkills) {
    EnsureFolder "$Root\skills\database\$Skill"
    $Content = @"
---
name: $Skill
description: Expert workflow for $Skill in production database systems.
---

# $Skill

## Mission

Design and operate reliable, performant database systems using $Skill best practices.

## Core Responsibilities

- Apply $Skill patterns to production-grade data systems.
- Ensure data integrity, consistency, and availability.
- Optimize for the target workload characteristics.
- Plan for schema/data evolution without downtime.

## Workflow

1. Understand the access patterns and scale requirements.
2. Design the $Skill approach to satisfy those requirements.
3. Implement with safety mechanisms and rollback plans.
4. Test under realistic load conditions.
5. Monitor performance and adjust as data grows.

## Quality Standards

Always:
- Test migrations on a copy of production data first.
- Keep rollback scripts alongside every migration.
- Document all decisions and tradeoffs.

Never:
- Run untested migrations directly on production.
- Ignore slow query warnings.
"@
    Write-IfChanged "$Root\skills\database\$Skill\SKILL.md" $Content
}

# ============================================
# ADDITIONAL WORKFLOWS
# ============================================

$ExtraWorkflows = @{
    "refactor-codebase" = @"
# refactor-codebase

## Purpose

Systematic codebase refactoring to improve structure, reduce technical debt, and improve maintainability without changing behavior.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| ``TARGET`` | Module or file set being refactored | yes |
| ``GOAL`` | Refactoring goal (e.g., "extract service layer", "reduce duplication") | yes |

## Steps

### Step 1: Behavior Inventory
- Agent: principal-engineer
- Skills: code-review, principal-engineer
- Action: Document the current behavior of {{TARGET}} through tests or behavioral analysis before changing anything.

### Step 2: Technical Debt Analysis
- Agent: principal-engineer
- Skills: code-review, refactor, architect
- Action: Identify technical debt in {{TARGET}}: duplication, high coupling, low cohesion, missing abstractions, and dead code.

### Step 3: Refactoring Plan
- Agent: principal-engineer
- Skills: architect, refactor
- Action: Produce an incremental refactoring plan for {{TARGET}} toward {{GOAL}}. Define safe transformation steps.

### Step 4: Incremental Refactoring
- Agent: backend-engineer
- Skills: refactor, code-review
- Action: Execute refactoring steps incrementally. Run tests after each step to verify behavior is preserved.

### Step 5: Code Review
- Agent: principal-engineer
- Skills: code-review, performance
- Action: Review the refactored {{TARGET}} for correctness, performance regressions, and adherence to {{GOAL}}.

### Step 6: Documentation
- Agent: technical-writer
- Skills: documentation
- Action: Update documentation to reflect the new structure of {{TARGET}}.
"@

    "performance-audit" = @"
# performance-audit

## Purpose

Systematic performance investigation and optimization of an application, service, or infrastructure component.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| ``TARGET`` | Service or component being audited | yes |
| ``SLA`` | Performance target (e.g., "p99 < 200ms") | yes |

## Steps

### Step 1: Baseline Measurement
- Agent: principal-engineer
- Skills: performance, architect
- Action: Establish performance baselines for {{TARGET}} against {{SLA}}. Profile CPU, memory, latency, and throughput under realistic load.

### Step 2: Bottleneck Identification
- Agent: principal-engineer
- Skills: performance, algorithm-expert
- Action: Identify the top 3 bottlenecks from profiling data for {{TARGET}}.

### Step 3: Database Optimization
- Agent: database-architect
- Skills: postgres, redis, database-design
- Action: Identify slow queries, missing indexes, and N+1 problems in {{TARGET}}.

### Step 4: Algorithm and Caching Review
- Agent: principal-engineer
- Skills: algorithm-expert, optimization, performance
- Action: Replace inefficient algorithms and introduce caching where appropriate.

### Step 5: Infrastructure Tuning
- Agent: devops-engineer
- Skills: kubernetes, cloud, docker
- Action: Right-size compute, tune scaling policies, and optimize container resource allocations.

### Step 6: Benchmark and Verify
- Agent: principal-engineer
- Skills: performance, documentation
- Action: Re-benchmark {{TARGET}} against {{SLA}}. Document improvements achieved.
"@
}

foreach ($Name in $ExtraWorkflows.Keys) {
    Write-IfChanged "$Root\workflows\$Name.md" $ExtraWorkflows[$Name]
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " EXPANSION ENGINE COMPLETE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
