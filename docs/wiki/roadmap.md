# Roadmap

Four architectural concerns raised during review of GOD-OPENCODE 1.1.x.
Each is addressed with an MVP in 1.2 and a follow-up path to a fuller
solution.

## 1. Lacks Graph-Based Codebase Mapping

| Status | Item |
|--------|------|
| Problem | No function-to-file call-trees; multi-step refactors require brute-force directory search |
| MVP (1.2)  | `scripts/code-graph.ps1` emits a JSON call-graph index for PowerShell files |
| 1.3       | Multi-language graph (JS/TS/Python via tree-sitter) + static HTML viewer |
| 1.4       | PowerShell AST parsing for parameter flow + types |
| 2.0       | Live agent tool: `Get-GodCallers foo` returns who's calling `foo` |
| Owner     | UI / tooling |

See: [graph.md](graph.md)

## 2. Static Markdown Prompts

| Status | Item |
|--------|------|
| Problem | 84 SKILL.md files are loaded whole, even when only one section is relevant |
| MVP (1.2)  | `scripts/skill-fragment.ps1` returns top skills + matching ## sections for a query |
| 1.2+      | Authoring guideline: short, keyword-rich `##` headings for fragmenter scoring |
| 1.3       | Body-text + code-block scoring; skill-fragment becomes a callable agent tool |
| 1.4       | Embedding-based semantic retrieval per skill |
| 2.0       | Per-skill `## Active Context` blocks the LLM can opt into for long-running loops |
| Owner     | Skills |

See: [dynamic-skills.md](dynamic-skills.md)

## 3. Heavy Windows/PowerShell Reliance

| Status | Item |
|--------|------|
| Problem | Linux/macOS users need a non-PowerShell path |
| MVP (1.2)  | `install.sh` (bash) and `install.cmd` (cmd.exe) shims; container image on ghcr.io |
| 1.3       | `.devcontainer/devcontainer.json` for Codespaces |
| 1.3       | Multi-arch container (amd64 + arm64) |
| 2.0       | PowerShell Gallery module: `Install-Module GodOpenCode` |
| Owner     | Installer |

See: [cross-platform.md](cross-platform.md)

## 4. No Long-Term Memory / State Management

| Status | Item |
|--------|------|
| Problem | Auto-router routes per-request, no persistent user-session memory across sessions |
| MVP (1.2)  | `New-MemoryRecall` + `memory/AGENT_PREFERENCES.md` convention; TUI `5` Memory page upgraded |
| 1.3       | Git-synced memory via `memory/remote.config.json` (opt-in) |
| 1.3       | Embedding-based memory recall via `scripts/embed-memory.ps1` |
| 2.0       | Cross-session preference accumulation with attribution tracking |
| Owner     | Memory / agents |

See: [memory.md](memory.md)

## How the roadmap gets prioritized

We rank by:
1. **Ratio of users benefitted / lines of code.** E.g., `install.sh` 
   unblocks 60% of users for ~30 lines.
2. **Unblock a future feature.** E.g., `New-MemoryRecall` is required 
   for the embedding-based recall to be meaningful.
3. **Maintainability.** The wiki (this folder) replaces scattered README 
   content; one source of truth.

## See also

- [CHANGELOG.md](../../CHANGELOG.md) — released improvements
- [wiki README](index.md) — back to wiki landing
