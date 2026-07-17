# Dynamic Skills

> **Current state (MVP, added 1.2):** a script that takes a query string
> and returns the top SKILL.md files + matching section headers.
> Refactoring all 84 skills is a 1.3 effort.

## Why it matters

Before 1.2, every SKILL.md was loaded whole. A `fastapi`-tagged file
might be 6 KB of markdown. Load that for every call and the context 
window fills with content the LLM doesn't need.

## What ships in 1.2

- `scripts/skill-fragment.ps1` — tokenizes a query, scores each 
  `SKILL.md` header, returns top-N matches with the matching sections.
- TUI option `[4] Skill Fragment` runs it interactively.
- The auto-router skill can call it as a tool before recommending 
  which skills to load.

### Usage

```powershell
.\scripts\skill-fragment.ps1 -Query "authentication jwt"
```

Output is a list of objects with the matching skill path, score, and 
topics:

```
skill   score topics
------  ----- -------------------------------------------
skills/backend/fastapi/SKILL.md  7  @{heading="Auth"; score=4}, ...
skills/security/authentication/SKILL.md 6  ...
```

## Convention for skill authors (1.2+)

Use short, keyword-rich `##` section headings so the fragmenter can
rank sections. Avoid burying critical behaviour inside long prose.

Good:
```
## Auth (JWT, OAuth2)

- Token lifetimes: 15 min access, 7 day refresh.
- ...
```

Avoid:
```
## Implementation details about the way tokens are obtained

...
```

## How to wire into agents

The `auto-router` skill (orchestration) can now include fragment lookup
in its routing path:

```powershell
$fragments = .\scripts\skill-fragment.ps1 -Query $Request
$skillHint = $fragments | Select-Object -First 1
# Pass $skillHint.skill + the specific ## section names into context.
```

## Limitations (MVP)

| Limitation | Impact |
|------------|--------|
| Header-only scoring | Body-text and code blocks aren't weighted |
| PowerShell script | Not yet a callable tool from inside OpenCode |
| Single-pass token match | No semantic similarity, no embeddings |

## Roadmap

- **1.3:** `scripts/skill-fragment.ps1` becomes a callable agent tool
- **1.3:** Body-text scoring + heading + first 200 chars under each heading
- **1.4:** Embedding-based semantic fragment retrieval (`scripts/embed-skills.ps1`)
- **2.0:** Per-skill `## Active Context` blocks that the LLM can opt into

## See also

- [Roadmap](roadmap.md) — dynamic-skills concern in context
- [Architecture](architecture.md) — how skills layer up
