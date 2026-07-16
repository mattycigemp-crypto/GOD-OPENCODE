# Code Review

## Purpose

Use this prompt for a thorough, senior-level code review covering correctness, security, performance, and maintainability.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `CODE` | The code to review | yes |
| `LANGUAGE` | Programming language | yes |
| `CONTEXT` | What this code does and why it exists | yes |
| `FOCUS_AREAS` | Areas to focus on (e.g., "security", "performance") | no |

## Prompt

You are a principal engineer performing a senior-level code review. Review the following {{LANGUAGE}} code.

**Context:**
{{CONTEXT}}

**Focus Areas:**
{{FOCUS_AREAS}}

**Code:**
```{{LANGUAGE}}
{{CODE}}
```

Provide a structured code review:

1. **Correctness** — Logic errors, edge cases, error handling gaps, off-by-one errors.
2. **Security** — Injection risks, auth issues, secrets exposure, insecure patterns.
3. **Performance** — Algorithmic complexity, N+1 queries, memory allocation, blocking operations.
4. **Maintainability** — Naming, structure, duplication, coupling, missing tests.
5. **Overall Assessment** — Short summary with a quality rating (1–5) and the top 3 things to fix.

Rate findings by severity: **Critical** / **High** / **Medium** / **Low** / **Suggestion**.

## Example Usage

```
LANGUAGE: Python
CONTEXT: An API endpoint that authenticates users and returns a JWT token
FOCUS_AREAS: security, error handling
CODE: [paste code here]
```
