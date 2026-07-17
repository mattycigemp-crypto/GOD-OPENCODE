# Memory System

> **Before 1.2:** `scripts/memory.ps1` was a single-shot markdown dumper.
> Nothing lasted between sessions.
>
> **In 1.2:** `scripts/memory.ps1` retains its append-only store, gets a 
> new `New-MemoryRecall` function, and the project ships with a 
> persistent `memory/AGENT_PREFERENCES.md` convention.

## Why it matters

OpenCode's auto-router routes per-request. Between requests, you lose
the "this user wants small functions, hates emojis in code, prefers 
concise tests" thread of context. Without memory, every session starts 
cold.

## What's in the repo now (1.2)

- `scripts/memory.ps1` — append-only markdown store under `memory/`
- The store uses five artifact types: 
  `architecture-decision`, `coding-convention`, `todo`, `changelog`, 
  `assumption`
- TUI option `[5] Memory` lists + appends via the menu
- All files are plain markdown; you can edit them directly

## New in 1.2

### `New-MemoryRecall` function

```powershell
. .\scripts\memory.ps1
$relevant = New-MemoryRecall -Query "jwt auth" -Top 3
```

Returns the top-N most-relevant artifacts as a list, scored by token
overlap with the query.

### `memory/AGENT_PREFERENCES.md`

A persistent preferences file the LLM reads at session start. Edit
this directly to capture durable per-user conventions:

```markdown
---
type: agent-preferences
author: you@yourcompany.com
updated: 2026-07-17
---
# Coding Conventions (persistent)

- Prefer small functions (<= 40 lines)
- No emojis in source code
- Tests use Pester, never Moq
```

The auto-router skill checks this file first before falling back to 
the SKILL.md defaults. Updated by any agent at any time.

## Limitations (MVP)

| Limitation | Impact |
|------------|--------|
| Local-only | Not synced between machines |
| No embedding search | Token-match recall only |
| No auto-load | The agent must explicitly read preferences each session |
| Single-user | No multi-tenant preference model |

## How to use it today

1. Open TUI: `.\god-ui.ps1`.
2. Press `[5] Memory`.
3. Add an entry with `[A]rchitecture-decision`, `[C]oding-convention`, 
   `[T]odo`, `[L]og`, or `[S]upposition` then a title and content.
4. Files land in `memory/<type>-<slug>.md`.

## Roadmap

- **1.2 (shipped):** `New-MemoryRecall`, `AGENT_PREFERENCES.md` 
  convention
- **1.3:** Git-synced memory via `memory/remote.config.json`
- **1.3:** Embedding-based recall (`scripts/embed-memory.ps1`)
- **2.0:** Cross-session preference accumulation with attribution 
  tracking

## See also

- [Roadmap](roadmap.md) — memory concern in context
- [Dynamic Skills](dynamic-skills.md) — similar context-pruning approach
