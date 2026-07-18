# CogniVect Wiki

> The single source of truth for CogniVect — replacing scattered
> README sections with an organized, browseable reference.

Welcome. The wiki documents the system honestly, including the four
architectural concerns we're actively working on (see [Roadmap](roadmap.md)).

## Sections

| Page | What it covers |
|------|---------------|
| [Getting Started](getting-started.md) | 5 minutes: clone to first slash command |
| [Architecture](architecture.md) | Agents / skills / workflows + OpenCode integration |
| [Code Graph](graph.md) | Structural codebase mapping (6 languages) |
| [Dynamic Skills](dynamic-skills.md) | Per-request context pruning for skills |
| [Cross-Platform](cross-platform.md) | Linux / macOS / Windows / Docker install matrix |
| [Memory System](memory.md) | Long-term session + project memory |
| [Roadmap](roadmap.md) | Four open architectural concerns and how we're addressing them |

## v1.6.0 Features

New in v1.6.0 — five features from deep research on developer needs:

| Feature | Access | Purpose |
|---------|--------|--------|
| Security Scanner | TUI `[T]` / CLI `security-scan` | Pre-commit secret/vulnerability scan |
| Agent Orchestrator | TUI `[A]` / CLI `agent-orch` | Multi-agent task delegation |
| MCP Connectors | TUI `[M]` / CLI `mcp-connect` | Chrome/DB/Jira/Monitoring integration |
| Smart Git | TUI `[G]` / CLI `smart-git` | Atomic commits, save points, rollback |
| Test-Driven AI | Workflow `test-driven-ai.md` | Generate tests before code |

## How this wiki is built

The wiki is a `docs/wiki/` folder of Markdown files. There is no build
step. You can browse it directly in any markdown viewer, or open
`docs/wiki/index.md` in your editor.

The wiki is also surfaced via:
- TUI option `[8] Wiki` (or `W`)
- Dashboard nav link `Wiki`
- Inline links from agent prompts (e.g., `AGENTS.md` references 
  `docs/wiki/architecture.md`)

## Conventions

- Each page has a one-line purpose at the top.
- Code blocks show both the command and expected output where possible.
- "Current state" sections are kept honest — limited features are
  flagged as MVP, full solutions are linked in the Roadmap.

## See also

- [CHANGELOG.md](https://github.com/mattycigemp-crypto/CogniVect/blob/master/CHANGELOG.md) — version history
- [README.md](https://github.com/mattycigemp-crypto/CogniVect/blob/master/README.md) — one-page overview
- [AGENTS.md](https://github.com/mattycigemp-crypto/CogniVect/blob/master/AGENTS.md) — context file for OpenCode
