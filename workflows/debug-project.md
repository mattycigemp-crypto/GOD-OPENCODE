# debug-project

## Purpose

Alias for bug-investigation. Systematic debugging of a project-level bug, regression, or unexpected behavior. See bug-investigation.md for the complete parameterized workflow.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `BUG_DESCRIPTION` | Description of the bug | yes |
| `COMPONENT` | Affected component | yes |
| `ENVIRONMENT` | Environment where it occurs | yes |

## Steps

### Step 1: Reproduce
- Agent: debugger
- Skills: debugger, bug-hunter
- Action: Reproduce {{BUG_DESCRIPTION}} in {{COMPONENT}} reliably in a controlled environment.

### Step 2: Root Cause Analysis
- Agent: debugger
- Skills: bug-hunter, code-review, architect
- Action: Identify the root cause of {{BUG_DESCRIPTION}} in {{COMPONENT}} through systematic hypothesis testing.

### Step 3: Fix
- Agent: backend-engineer
- Skills: code-review, testing
- Action: Implement a targeted fix for the root cause. Do not patch the symptom.

### Step 4: Regression Test
- Agent: debugger
- Skills: testing
- Action: Write a test that fails before the fix and passes after. Add to the test suite.

### Step 5: Documentation
- Agent: technical-writer
- Skills: documentation
- Action: Document the {{BUG_DESCRIPTION}} investigation, root cause, and fix.
