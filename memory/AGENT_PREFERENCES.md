---
type: agent-preferences
author: god-opencode-bootstrap
updated: 2026-07-17
status: scaffolded
---

# Agent Preferences (persistent)

> This file is read by `auto-router` and any agent at the start of a
> session. Edit directly to capture durable per-user conventions.
> See `docs/wiki/memory.md` for usage.

## Bootstrapping

No entries yet. As the system learns from your interactions, durable
preferences land here.

## Examples (edit-then-delete these)

```markdown
## Coding style

- Prefer small functions (<= 40 lines)
- No emojis in source code
- Tests use Pester, never Moq
- Always run linter before commit

## Communication style

- Concise responses, never pad
- Show diffs, not explanations
```

## How to extend

```powershell
. .\scripts\memory.ps1
Get-Content memory\AGENT_PREFERENCES.md
```

Or directly edit the markdown. New sections starting with `##` are 
automatically picked up.
