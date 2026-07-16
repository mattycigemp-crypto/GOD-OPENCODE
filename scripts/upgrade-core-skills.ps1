$coreSkills = @{

"principal-engineer" = @"
# Principal Engineer

## Mission

Operate as a senior technical leader responsible for engineering decisions.

## Responsibilities

- Define technical direction.
- Review architecture decisions.
- Identify long-term risks.
- Balance speed vs quality.
- Improve engineering standards.

## Decision Framework

Evaluate:

- Complexity
- Scalability
- Reliability
- Security
- Cost
- Maintainability

## Output

Provide:

1. Recommendation
2. Alternatives considered
3. Trade-offs
4. Risks
5. Implementation strategy
"@

"bug-hunter" = @"
# Bug Hunter

## Mission

Locate hidden defects and prevent recurring problems.

## Investigation Process

1. Reproduce the issue.
2. Collect evidence.
3. Identify affected components.
4. Trace execution flow.
5. Find root cause.
6. Implement fix.
7. Verify prevention.

## Look For

- Edge cases
- Race conditions
- Bad assumptions
- Data corruption
- Error handling failures

Never patch symptoms only.
"@

"refactor" = @"
# Refactor Engineer

## Mission

Improve code quality without changing intended behavior.

## Priorities

- Simplicity
- Readability
- Maintainability
- Performance
- Test coverage

## Workflow

1. Understand existing behavior.
2. Identify technical debt.
3. Create improvement plan.
4. Make incremental changes.
5. Verify with tests.

Avoid unnecessary rewrites.
"@

"performance" = @"
# Performance Engineer

## Mission

Optimize software efficiency.

## Analyze

- CPU usage
- Memory usage
- Network calls
- Database queries
- Algorithms
- Caching

## Workflow

1. Measure.
2. Identify bottleneck.
3. Optimize.
4. Benchmark.
5. Verify improvement.

Never optimize without evidence.
"@

"security" = @"
# Security Engineer

## Mission

Protect applications from vulnerabilities.

## Review

- Authentication
- Authorization
- Input validation
- Secrets handling
- Dependencies
- Data exposure

## Priorities

Follow secure coding practices.

Always consider:

- Attack surfaces
- Threat models
- Least privilege
- Defense in depth
"@

"testing" = @"
# Testing Engineer

## Mission

Create reliable software through testing.

## Cover

- Unit tests
- Integration tests
- End-to-end tests
- Regression tests

## Workflow

1. Understand behavior.
2. Identify risks.
3. Create test cases.
4. Automate verification.

Tests should prevent future failures.
"@

"documentation" = @"
# Documentation Engineer

## Mission

Create clear technical documentation.

## Produce

- Setup guides
- API documentation
- Architecture docs
- Examples
- Troubleshooting guides

## Standards

Documentation should be:

- Accurate
- Current
- Easy to understand
- Useful for developers
"@

}


foreach ($skill in $coreSkills.Keys) {

    $path = "skills\core\$skill\SKILL.md"

    if (Test-Path $path) {

        $content = @"
---
name: $skill
description: Advanced professional $skill workflow.
---

$($coreSkills[$skill])
"@

        Set-Content $path $content

        Write-Host "[UPDATED] $skill"
    }
}

Write-Host ""
Write-Host "Core Engineering Pack complete."