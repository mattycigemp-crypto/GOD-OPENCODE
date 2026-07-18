# CogniVect Standards

## PowerShell 5.1 Compatibility

All PowerShell scripts in CogniVect must be compatible with **Windows PowerShell 5.1**.

### Do

- Use ASCII characters only for box drawing and separators.
- Use `;` instead of `&&` for chaining statements.
- Use `Join-Path` for path construction.
- Use `Test-Path` before creating files or directories.
- Use `Out-Null` to suppress unwanted output.
- Use `$ErrorActionPreference = "Stop"` or `"Continue"` explicitly.
- Use Unicode box-drawing characters via `[char]0xXXXX` variables (not literal strings in hashtables).

### Don't

- Use Unicode box-drawing characters directly in hashtable literals (parser issue).
- Use `char * int` multiplication (e.g., `"=" * 50`).
- Use `&&` or `||` operators.
- Assume PowerShell 7+ features are available.

### Example

```powershell
# Good
Write-Host "============================================"
Write-Host "     CogniVect SMART INSTALLER"
Write-Host "============================================"

# Bad
Write-Host "────────────────────────────────────────────"
Write-Host ("─" * 44)
```

## SKILL.md Format Requirements

Every skill must be a Markdown file named `SKILL.md` located at `skills/<category>/<skill-name>/SKILL.md`.

### Required Frontmatter

```yaml
---
name: <skill-name>
description: <short description>
---
```

### Required Sections

A typical skill includes:

- `## Mission` — What the skill covers.
- `## Core Responsibilities` — Key duties.
- `## Workflow` — Numbered or bulleted process.
- `## Quality Standards` — Always/Never rules.
- `## Expert Mindset` — Tone and perspective.

### Example

```markdown
---
name: api-design
description: Professional expert workflow for API design.
---

# api-design

## Mission

You are a specialized senior-level expert in API design.

## Core Responsibilities

- Design RESTful and GraphQL APIs.
- Define request/response schemas.
- Document error handling.

## Workflow

1. Understand requirements.
2. Model resources.
3. Define endpoints.
4. Validate with stakeholders.

## Quality Standards

Always:

- Use HTTP status codes correctly.
- Version public APIs.

Never:

- Expose internal identifiers.
- Ignore pagination for large collections.

## Expert Mindset

Think like a senior engineer responsible for systems used in production.
```

## Workflow Parameter Syntax

Workflows use `{{PARAM}}` syntax for parameter substitution.

### Declaration

Define parameters in a table near the top of the workflow:

```markdown
## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `API_NAME` | Name of the API being built | yes |
| `FRAMEWORK` | Backend framework | yes |
| `DATABASE` | Database technology | no |
```

### Usage

Reference parameters in step actions:

```markdown
### Step 1: Design

- Agent: backend-engineer
- Skills: api-design
- Action: Design the API contract for {{API_NAME}} using {{FRAMEWORK}}.
```

### Rules

- Parameter names are UPPER_SNAKE_CASE.
- Required parameters must be provided before execution.
- Optional parameters should have sensible defaults or be skipped gracefully.

## Markdown Conventions

- Use ATX-style headings (`#`, `##`, `###`).
- Use fenced code blocks with language identifiers.
- Use tables for structured data.
- Use bullet lists for unordered items.
- Use numbered lists for sequential steps.
- Keep lines under 120 characters where possible.
- End files with a single newline.
