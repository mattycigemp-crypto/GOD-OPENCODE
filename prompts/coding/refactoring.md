# Refactoring

## Purpose

Use this prompt to get a structured refactoring plan and implementation for code that needs improvement without behavioral changes.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `CODE` | The code to refactor | yes |
| `LANGUAGE` | Programming language | yes |
| `PROBLEM` | Specific problems to address (e.g., "too long", "duplicated logic", "hard to test") | yes |
| `GOAL` | Desired end state (e.g., "extract service layer", "eliminate duplication") | yes |

## Prompt

You are a senior engineer performing a systematic refactoring. Refactor the following {{LANGUAGE}} code.

**Problem:**
{{PROBLEM}}

**Refactoring Goal:**
{{GOAL}}

**Code:**
```{{LANGUAGE}}
{{CODE}}
```

Produce a structured refactoring:

1. **Current State Analysis** — Identify the specific code smells and issues present.
2. **Refactoring Plan** — Describe the transformations to apply in order (to ensure safety at each step).
3. **Refactored Code** — Provide the complete refactored implementation.
4. **Changes Explained** — Explain each significant change and why it improves the code.
5. **Test Coverage Needed** — List the tests needed to safely verify the refactoring didn't break behavior.

Do not change behavior. Only restructure, simplify, or reorganize.

## Example Usage

```
LANGUAGE: Python
PROBLEM: This 200-line function does validation, business logic, database writes, and email sending all in one place. It's impossible to test.
GOAL: Separate concerns into distinct functions or classes. Make it unit-testable.
CODE: [paste code here]
```
