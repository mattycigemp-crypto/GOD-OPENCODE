# GOD-OPENCODE Canonical Skills Registry

> Every community skill listed here ships as a regular `SKILL.md` (YAML frontmatter + body) at the path `<category>/<skill-name>/SKILL.md` in the listed source repo. `scripts/install-skill.ps1` pull-installs any entry below into `~/.config/opencode/skills/<category>/<skill-name>/` and follows the same idempotent hash-based update rules as `install.ps1`.

## Registry entry format

Each row in this file is one registry entry:

```
<source-owner>/<source-repo> | <category>/<skill-name> | <version-or-tag> | <one-line description>
```

Field rules:

| Field | Format | Example |
|---|---|---|
| **source** | GitHub `owner/repo` | `mattycigemp-crypto/god-opencode` |
| **path** | `<category>/<skill-name>` (matches GOD-OPENCODE layout) | `backend/fastapi` |
| **version** | git tag, branch, or `latest` | `v1.2.0`, `latest`, `main` |
| **description** | one-line, ≤ 80 chars | `Professional senior backend ...` |

## Seed entries (canonical GOD-OPENCODE skills)

These always resolve to the in-repo skills. Useful for testing `install-skill.ps1` and for users who want only a subset:

```
mattycigemp-crypto/god-opencode | backend/fastapi        | latest | Async Python web framework — Pydantic, dependency injection, OpenAPI.
mattycigemp-crypto/god-opencode | backend/postgres      | latest | Postgres schema design, query optimization, migrations.
mattycigemp-crypto/god-opencode | security/security-audit | latest | OWASP, STRIDE, threat modelling, depth-of-field security review.
mattycigemp-crypto/god-opencode | devops/docker         | latest | Dockerfile, multi-stage builds, image audit, compose patterns.
mattycigemp-crypto/god-opencode | ai/llm-engineer        | latest | LLM provider selection, token economics, evals.
mattycigemp-crypto/god-opencode | core/architect        | latest | Senior system architecture, ADRs, trade-off analysis.
```

## Adding a new skill (contributor workflow)

1. Fork `mattycigemp-crypto/god-opencode` and create your skill in the standard layout.
2. Add an entry below in this file with your fork's `owner/repo` path until your PR is merged.
3. Open a PR that adds your entry to this file AND bumps `version`.
4. After merge, `scripts/install-skill.ps1 -Source mattycigemp-crypto/god-opencode -Path <category>/<skill-name>` will install from upstream.

## Compatibility matrix

GOD-OPENCODE versions and the SKILL.md format they consume:

| GOD-OPENCODE | SKILL.md frontmatter | Notes |
|---|---|---|
| v1.0.x – v1.1.x | none | tolerated; `name` heuristic from folder |
| v1.2.0+ | `name`, `description` required | schema enforced by `tests/unit/Test-OpenCodeSchema.Tests.ps1` analogue |
| v1.3.0+ (planned) | + `version`, `requires` | declarative dependency graph between skills |

## CLI

```powershell
# Install one skill from the canonical registry (defaults to upstream)
.\scripts\install-skill.ps1 -Path backend/fastapi

# Install from a specific source repo + version
.\scripts\install-skill.ps1 `
    -Source mattycigemp-crypto/god-opencode `
    -Path security/security-audit `
    -Version v1.2.0

# Dry-run (print actions, don’t write)
.\scripts\install-skill.ps1 -Path devops/docker -DryRun
```

See `scripts/install-skill.ps1` and `registry-sources.txt` for the seed list.
