# Bug Hunt

## Purpose

Use this prompt to systematically investigate a bug or unexpected behavior. Drives from evidence to root cause to fix using structured reasoning.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `BUG_DESCRIPTION` | Description of the bug or unexpected behavior | yes |
| `COMPONENT` | Affected code, service, or module | yes |
| `ERROR_OUTPUT` | Error message, stack trace, or log output | yes |
| `STEPS_TO_REPRODUCE` | Steps to reliably reproduce the bug | no |
| `EXPECTED_BEHAVIOR` | What should happen instead | no |

## Prompt

You are a senior debugger. Investigate the following bug using systematic root-cause analysis.

**Bug Description:**
{{BUG_DESCRIPTION}}

**Affected Component:**
{{COMPONENT}}

**Error Output / Stack Trace:**
```
{{ERROR_OUTPUT}}
```

**Steps to Reproduce:**
{{STEPS_TO_REPRODUCE}}

**Expected Behavior:**
{{EXPECTED_BEHAVIOR}}

Produce a structured investigation:

1. **Evidence Analysis** - What does the error output tell you? What does it rule out?
2. **Root Cause Hypotheses** - List 2–3 ranked hypotheses. Explain why each could be the cause.
3. **Root Cause Identification** - Which hypothesis is most likely and why?
4. **Fix** - Provide the specific code change to fix the root cause.
5. **Regression Test** - Write a test that fails before the fix and passes after.
6. **Prevention** - What could prevent this class of bug in the future?

Do not patch symptoms. Fix the root cause.

## Example Usage

```
BUG_DESCRIPTION: Users occasionally see duplicate orders in their history
COMPONENT: order_service.py - create_order()
ERROR_OUTPUT: No explicit error - duplicate rows appear in orders table
STEPS_TO_REPRODUCE: Submit an order while the network is slow; sometimes 2 orders appear
EXPECTED_BEHAVIOR: Exactly one order should be created per submission
```

