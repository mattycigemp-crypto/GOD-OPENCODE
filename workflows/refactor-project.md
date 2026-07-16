# refactor-project

## Purpose

Alias for refactor-codebase. Systematic refactoring of a project or module to improve structure, reduce debt, and improve maintainability without changing behavior.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Module or codebase being refactored | yes |
| `GOAL` | Refactoring goal (e.g., "extract service layer") | yes |

## Steps

### Step 1: Behavior Inventory
- Agent: principal-engineer
- Skills: code-review, testing
- Action: Document the current behavior of {{TARGET}} through tests before changing anything.

### Step 2: Debt Analysis
- Agent: principal-engineer
- Skills: code-review, refactor, architect
- Action: Identify technical debt in {{TARGET}}: duplication, coupling, missing abstractions, and dead code.

### Step 3: Refactoring Plan
- Agent: principal-engineer
- Skills: architect, refactor
- Action: Define incremental transformation steps toward {{GOAL}} for {{TARGET}}.

### Step 4: Incremental Refactoring
- Agent: backend-engineer
- Skills: refactor, code-review
- Action: Execute each refactoring step. Run tests after every step to verify behavior is preserved.

### Step 5: Review and Documentation
- Agent: principal-engineer
- Skills: code-review, documentation
- Action: Review refactored {{TARGET}} and update documentation to reflect the new structure.
