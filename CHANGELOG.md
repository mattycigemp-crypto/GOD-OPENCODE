# Changelog

All notable changes to GOD-OPENCODE are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.3.0] - 2026-07-17

### Added

- **JSON Schema for `opencode.json`** ([`schemas/opencode.schema.json`](schemas/opencode.schema.json)) — Draft 2020-12 with `patternProperties` for agent / command / mcp_servers keys, `additionalProperties: false` at the top, conditional `then:` clauses for MCP transport, and `mcp_servers.snippets` examples. Editors (Cursor, VS Code) auto-lint `opencode.json` against it via the `$schema` reference.
- **MCP-to-skill bridge** ([`scripts/mcp-to-skill.ps1`](scripts/mcp-to-skill.ps1)) — reads `opencode.json#mcp_servers`, emits `skills/<category>/mcp-<name>/SKILL.md` wrappers, and is invoked at the end of `install.ps1`. Five MCP servers (filesystem, github, playwright, context7, tavily) ship out of the box as both MCP clients and skills.
- **Skills Registry spec + CLI** ([`skills-REGISTRY.md`](skills-REGISTRY.md), [`registry-sources.txt`](registry-sources.txt), [`scripts/install-skill.ps1`](scripts/install-skill.ps1) `-Sync`) — canonical cross-repo skill registry. `install-skill.ps1 -Sync` shallow-clones the top-N entries from `registry-sources.txt` into `skills-mirror/`.
- **Workflow shape tests** ([`tests/unit/Test-Workflows.Tests.ps1`](tests/unit/Test-Workflows.Tests.ps1)) — first-run Pester assertions: every `workflows/*.md` must have an H1 matching its filename, `## Purpose`, `## Parameters`, and `### Step N` sections. Cross-references each step's `Agent:` against `agents/` and `Skills:` against `skills/` (category-aware fallback).
- **Cursor / Windsurf / Aider drop-in exporter** ([`scripts/export-cursorrules.ps1`](scripts/export-cursorrules.ps1), `install-skill.ps1 -Use cursorrules`) — converts `agents/<name>/AGENT.md` into the `.cursorrules` YAML frontmatter schema. One command writes a `.cursorrules` per agent into `dist/cursorrules/`; copy one into your project and any Cursor/Windsurf/Aider session picks up the persona.
- **Live skill/agent/workflow graph** ([`scripts/build-skill-graph.ps1`](scripts/build-skill-graph.ps1)) — emits `docs/wiki/_data/architecture.mmd` (Mermaid) on every wiki CI run. Edges reflect the actual `## Skills` blocks in each agent and the `### Step N: Agent / Skills` blocks in each workflow. Wiki auto-renders the graph.

### Changed

- **Terminal UI** ([`god-ui.ps1`](god-ui.ps1)) — added `[L] Live Architecture`, `[R] Skills Registry`, `[C] Cursor Export`, `[N] What's new in v1.3.0` menu items. Updated the architecture features status block.
- **Browser dashboard** ([`ui/index.html`](ui/index.html)) — added a v1.3.0 announcement banner / card and section anchors linking to the new features.
- **`install-skill.ps1`** — added `-Sync`, `-TopN`, `-Use` dispatchers; existing `-Path`/`-Source`/`-Version` behaviour preserved verbatim.
- **`install.ps1`** — `mcp_servers` merge uses a local `$McpMerged` flag (no longer re-serializes the global config on every install when nothing changed).
- **README** — added "🆕 What's New in v1.3.0" section, "Use with Cursor", "Aggregate skills from anywhere" subsections, and a release badge linking to the v1.3.0 GitHub release.

### Notes

- Releases ship via `git tag v1.3.0 && git push origin v1.3.0`. The `release.yml` workflow runs `scripts/package-release.ps1 -Version 1.3.0` and attaches `release/god-opencode-v1.3.0.zip` + SHA256SUMS to a GitHub Release.
- Schema validator is not invoked in CI yet — `tests/unit/Test-OpenCodeSchema.Tests.ps1` ships the Pester suite but does not call `jsonschema` (lives outside PowerShell). Future work.

---

## [1.2.0] - 2026-07-17

*(Backfilled — the underlying commit `3f1160d` shipped on the date above but the changelog entry was authored in commit `eb06e71` to keep the README self-consistent.)*

### Added

- **Architectural feature pack** addressing the four open concerns documented in `docs/wiki/roadmap.md`:
  - **Code Graph** (`scripts/code-graph.ps1`) — PowerShell call-graph extractor that scans `*.ps1`/`*.psm1` and emits `docs/wiki/_data/code-graph.json` (nodes + edges + per-file references). Render in `docs/wiki/graph.md`.
  - **Dynamic Skills** (`scripts/skill-fragment.ps1`) — query-time skill selector that returns matching `##` sections per request instead of injecting whole SKILL.md files.
  - **Cross-Platform install matrix** — `install.sh` (bash, delegates to `install.ps1` via `pwsh`) + `install.cmd` (cmd.exe shim) so Linux/macOS/WSL/Windows hosts all reach the same installer.
  - **Long-term Memory** (`scripts/memory.ps1` v1.2) — added `New-MemoryRecall` (top-N token-overlap across `memory/*.md`) and `Get-MemoryPreferences`; convention file `memory/AGENT_PREFERENCES.md` for persistent agent preferences.
- **Wiki** (`docs/wiki/`) — 8 markdown pages: `index.md`, `getting-started.md`, `architecture.md`, `graph.md`, `dynamic-skills.md`, `cross-platform.md`, `memory.md`, `roadmap.md`. Single source of truth for the architectural roadmap.
- **Browser dashboard update** (`ui/index.html`) — added Wiki landing grid, Architecture Features status section, and Wiki nav link.

### Changed

- **Terminal UI** (`god-ui.ps1` v3.0) — global install (`.\install.ps1`) elevated to the default action (Enter keypress). New menu pages: Code Graph (3), Skill Fragment (4), Memory (5), Cross-Platform (6), Wiki (8). Adds an Architecture Features status section that surfaces code-graph / dynamic-skills / cross-platform / memory health. PowerShell 5.1 compatible (no PS7-only constructs).
- **README** — added the **Architectural features (1.2)** section + wiki link table, Project Structure entries for `docs/wiki/` and `memory/`, and a "Press Enter to install globally" quick-start note.
- **`.gitignore`** — excludes local memory artifacts (`memory/*`) while keeping `memory/AGENT_PREFERENCES.md` tracked (whitelist pattern).
- **Wiki Pages workflow** (`.github/workflows/wiki-pages.yml`) — switched from `mkdocs gh-deploy --force --clean` (which required a `gh-pages` branch) to the official `actions/deploy-pages@v4` + `actions/upload-pages-artifact@v3` + `actions/configure-pages@v5` stack. Two-job pipeline (`build` → `deploy` with `needs`), `pages: write` + `id-token: write` OIDC permissions, no branch requirement. Pinned `mkdocs-material~=9.5.0` + `mkdocs~=1.6.0`. Users now enable Pages via **Settings → Pages → Source: GitHub Actions** (no branch selection needed).

### Notes

- No new agents, workflows, or commands — all additions are tooling + docs.
- The skill headline count stays at **84 unique** across 11 topical categories — each skill lives in exactly one category folder, so per-category counts sum to 84 exactly.

## [1.1.0] - 2026-07-17

### Added

- **Documentation** (`docs/`) — New architecture, standards, and workflow authoring guides.
  - `docs/architecture.md` — System overview, three-layer architecture, and OpenCode integration points.
  - `docs/standards.md` — PowerShell 5.1 compatibility, SKILL.md format, workflow syntax, and Markdown conventions.
  - `docs/workflows.md` — Workflow authoring guide with parameter substitution and examples.
- **OpenCode Configuration** (`opencode.json`) — Added `permission` rules to restrict destructive bash commands, per-agent `tools` restrictions, and glob-based `instructions`.
- **Installer v2.2** (`install.ps1`) — Added merge support for `permission` fields and glob `instructions` when merging into the global OpenCode config.
- **GitHub Release Automation** (`.github/workflows/release.yml`) — Triggered on `v*` tag pushes, creates a GitHub Release, and attaches the packaged `.zip` asset with auto-generated release notes.
- **Local Release Packager** (`scripts/package-release.ps1`) — Builds a versioned `.zip` release package locally with all components.

### Changed

- **AGENTS.md** — Added build/test/health commands section and contribution workflow.
- **`.gitignore`** — Ignores `*.zip` release packages and `release/` directory.

## [1.0.0] - 2026-07-16

### Added

- **Core Installer Engine** (`god-install.ps1`) - Fully idempotent one-command setup.
- **Skills System** - 70+ SKILL.md files across 8 categories: `ai`, `backend`, `frontend`, `devops`, `security`, `database`, `advanced`, `testing`.
- **Agent System** - 10 fully-specified agent personas with role definitions, responsibilities, standards, skills, and delegation mappings.
- **Workflow System** - 10+ parameterized workflows including `build-application`, `api-development`, `security-audit`, `bug-investigation`, `refactor-codebase`, and `performance-audit`.
- **Router** (`router/agent-router.json`, `scripts/router.ps1`) - 80+ keyword-to-agent mappings with top-3 candidate scoring and fallback to `principal-engineer`.
- **Command System** - 6 slash commands: `/build`, `/architect`, `/debug`, `/review`, `/secure`, `/optimize`.
- **MCP Management** - Registry and config for 5 MCPs: filesystem, github, playwright, context7, tavily.
- **Prompt Library** - 11 prompt templates across 6 categories with full `{{PARAM}}` substitution support.
- **Template System** - 6 project scaffolds: fastapi-api, react-app, nextjs-saas, ai-agent, mcp-server, rag-project, discord-bot.
- **Memory System** (`scripts/memory.ps1`) - `New-MemoryArtifact` and `Get-MemoryArtifacts` with ISO-8601 timestamps and append-on-conflict semantics.
- **Workflow Engine** (`scripts/workflow-engine.ps1`) - Parameter substitution, step extraction, and unresolved placeholder detection.
- **Intelligence Engine** (`tools/project-scan.ps1`) - Language detection, project type detection, agent/skill recommendation, and implementation plan generation.
- **Health Check** (`god-health.ps1`) - 8-category verification with `[OK]` / `[FAIL]` output and CI exit codes.
- **UI Dashboard** (`ui/index.html`) - Local browser dashboard for browsing agents, skills, workflows, prompts, and router rules.
- **Repository quality** - README, CONTRIBUTING, CHANGELOG, and MIT LICENSE.

