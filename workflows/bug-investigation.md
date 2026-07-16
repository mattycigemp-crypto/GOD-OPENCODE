# bug-investigation

## Purpose

Systematic bug investigation workflow that drives from symptom to root cause to fix to prevention, with full documentation of the investigation.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `BUG_DESCRIPTION` | Description of the bug or unexpected behavior | yes |
| `COMPONENT` | Affected component or service | yes |
| `ENVIRONMENT` | Environment where the bug occurs (e.g., "production", "staging") | yes |
| `SEVERITY` | Bug severity (e.g., "critical", "high", "medium", "low") | no |

## Steps

### Step 1: Bug Triage and Reproduction
- Agent: debugger
- Skills: debugger, bug-hunter
- Action: Triage {{BUG_DESCRIPTION}} in {{COMPONENT}}. Gather all available evidence: logs, stack traces, error messages, and reproduction steps. Reproduce the bug reliably in a controlled environment.

### Step 2: Evidence Collection
- Agent: debugger
- Skills: debugger, performance
- Action: Collect diagnostic data for the bug in {{ENVIRONMENT}}: application logs, metrics, traces, heap dumps, or network captures as appropriate. Establish the timeline of the failure.

### Step 3: Hypothesis Formation
- Agent: debugger
- Skills: bug-hunter, code-review, architect
- Action: Analyze the evidence and form 2–3 ranked hypotheses explaining the root cause of {{BUG_DESCRIPTION}} in {{COMPONENT}}. Use binary search or bisection if a regression is suspected.

### Step 4: Root Cause Identification
- Agent: debugger
- Skills: bug-hunter, code-review
- Action: Test each hypothesis against the evidence. Identify the single root cause. Document the exact code path, data state, or configuration condition that triggers the bug.

### Step 5: Fix Implementation
- Agent: backend-engineer
- Skills: code-review, testing, security
- Action: Implement a targeted fix for the root cause in {{COMPONENT}}. Ensure the fix does not patch only the symptom. Add defensive coding to prevent recurrence.

### Step 6: Regression Test
- Agent: debugger
- Skills: testing, code-review
- Action: Write a regression test that specifically reproduces {{BUG_DESCRIPTION}} before the fix and passes after. Add it to the test suite to prevent future regressions.

### Step 7: Documentation
- Agent: technical-writer
- Skills: documentation
- Action: Document the {{BUG_DESCRIPTION}} investigation: symptoms, root cause analysis, fix description, regression test location, and lessons learned. Update runbooks if operational changes are needed.
