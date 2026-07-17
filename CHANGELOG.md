# Changelog

All notable changes to GOD-OPENCODE are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

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

