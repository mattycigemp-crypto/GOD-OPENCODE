# refactor-codebase

## Purpose

Systematic codebase refactoring to improve structure, reduce technical debt, and improve maintainability without changing behavior.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Module or file set being refactored | yes |
| `GOAL` | Refactoring goal (e.g., "extract service layer", "reduce duplication") | yes |

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
