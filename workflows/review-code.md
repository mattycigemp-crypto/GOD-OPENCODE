# review-code

## Purpose

Structured senior code review covering correctness, security, performance, and maintainability. Produces a severity-rated findings report.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Code, PR, or module being reviewed | yes |
| `LANGUAGE` | Programming language | yes |
| `FOCUS` | Review focus (e.g., "security", "performance", "all") | no |

## Steps

### Step 1: Scope and Context
- Agent: principal-engineer
- Skills: code-review, principal-engineer
- Action: Understand what {{TARGET}} does, its context in the system, and any specific {{FOCUS}} areas for the review.

### Step 2: Correctness Review
- Agent: principal-engineer
- Skills: code-review, bug-hunter, testing
- Action: Review {{TARGET}} for logic errors, edge cases, off-by-one errors, null handling, and error propagation gaps.

### Step 3: Security Review
- Agent: security-engineer
- Skills: secure-coding, security-audit, authentication
- Action: Audit {{TARGET}} for injection vulnerabilities, insecure patterns, secrets exposure, and authentication/authorization issues.

### Step 4: Performance Review
- Agent: principal-engineer
- Skills: performance, database-design, algorithm-expert
- Action: Identify inefficient algorithms, N+1 query patterns, memory leaks, and blocking operations in {{TARGET}}.

### Step 5: Maintainability Review
- Agent: principal-engineer
- Skills: code-review, refactor, documentation
- Action: Assess {{TARGET}} for naming clarity, structural cohesion, code duplication, test coverage, and documentation gaps.

### Step 6: Findings Report
- Agent: technical-writer
- Skills: documentation, code-review
- Action: Produce a structured review report for {{TARGET}} with findings rated Critical/High/Medium/Low/Suggestion and specific line-level recommendations.
