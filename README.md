<p align="center">
  <img src="brand/wordmark.png" alt="GOD-OPENCODE" width="600">
</p>

<h3 align="center">An AI engineering operating system built on top of OpenCode.</h3>

<p align="center">
  One command bootstraps a complete, production-grade AI engineering environment — with the right experts, skills, workflows, and tools already loaded.
</p>

<p align="center">
  <a href="https://github.com/mattycigemp-crypto/GOD-OPENCODE/releases/tag/v1.4.0"><img alt="v1.4.0" src="https://img.shields.io/badge/release-v1.4.0-8b5cf6?style=for-the-badge"/></a>
</p>

<p align="center">
  <strong>🆕 v1.4.0 — five more features:</strong> <a href="#persistent-session-memory">session memory</a> · <a href="#wiki-auto-builder">wiki auto-builder</a> · <a href="#native-bash-installer">native bash installer</a> · <a href="#multi-language-code-graph">multi-lang code graph</a> · <a href="#smart-skill-loader">smart skill loader</a>
</p>

---

## Purpose

GOD-OPENCODE provides a structured, production-grade AI engineering environment on top of OpenCode. It routes every request to the right expert agent, loads domain-specific skills on demand, and executes proven workflows step by step.

## 📋 Overview

GOD-OPENCODE wraps OpenCode with a modular framework that gives every request the right context: the expert agent persona, the domain-specific skill knowledge, and the proven workflow step sequence. Instead of getting a generic AI assistant, you get a senior principal engineer, a security auditor, a database architect, or a full-stack team — whichever the task calls for.

**Everything is file-based and transparent.** Skills, agents, workflows — all Markdown. Router — JSON config. Nothing is hidden.

---

## 🚀 Quick Start

```powershell
# Clone and enter the directory
git clone https://github.com/mattycigemp-crypto/GOD-OPENCODE
cd GOD-OPENCODE

# Launch the terminal UI (main command)
.\god-ui.ps1
```

The TUI gives you everything: system overview, install, health check, tests, router, and a link to the browser dashboard. **Press Enter to install globally (the default action)** — installs skills/agents/workflows into `~/.config/opencode/`.

### Alternative: Direct OpenCode

```powershell
# Or run OpenCode directly (project-local, auto-discovered)
opencode
```

### Global Install (Optional)

```powershell
# Make skills available from any directory
.\install.ps1
```

Now GOD-OPENCODE works from **any directory** on your machine.

### Alternative: Container

```bash
# Pull the published image (no PowerShell host required)
docker pull ghcr.io/mattycigemp-crypto/god-opencode:latest

# Drop into a PowerShell session with GOD-OPENCODE ready
docker run --rm -it ghcr.io/mattycigemp-crypto/god-opencode:latest

# Or one-shot: run the installer
docker run --rm ghcr.io/mattycigemp-crypto/god-opencode:latest \
  pwsh -File ./install.ps1
```

Each `v*` tag push publishes a versioned image (`ghcr.io/.../god-opencode:v<version>`) plus `latest`. The image bundles PowerShell 7.4 + the installable project so it works identically on Linux, macOS, and Windows hosts.

**Cross-platform shims:** `bash install.sh` (requires `pwsh`) on Linux/macOS/WSL; `install.cmd` on Windows cmd.exe. See [docs/wiki/cross-platform.md](docs/wiki/cross-platform.md).

**Wiki:** the eight-page reference at `docs/wiki/` is built and published automatically to **GitHub Pages** on every push to `master` — see [mattycigemp-crypto.github.io/GOD-OPENCODE](https://mattycigemp-crypto.github.io/GOD-OPENCODE/). One-time setup: repo **Settings → Pages → Build and deployment → Source: GitHub Actions → workflow: `Build and Deploy Wiki`**, then Save.

---

## 🆕 What's New in v1.4.0

Five new capabilities addressing the remaining roadmap concerns — persistent memory, wiki generation, native bash installer, multi-language code graph, and smart skill loading. See [CHANGELOG.md](CHANGELOG.md) for the full record.

### Persistent Session Memory

Cross-session memory that learns your preferences automatically:

```powershell
# Initialize a session, track usage, recall later
.\scripts\session-memory.ps1 -Init
.\scripts\session-memory.ps1 -Track -Agent "backend-engineer" -Skill "fastapi"
.\scripts\session-memory.ps1 -Save
.\scripts\session-memory.ps1 -Recall          # see what you did last time
.\scripts\session-memory.ps1 -Prefs            # learned favorites
.\scripts\session-memory.ps1 -Stats            # full usage analytics
```

### Wiki Auto-Builder

Auto-generates comprehensive reference pages from skill, agent, and workflow content:

```powershell
.\scripts\build-wiki.ps1                  # build all reference pages
.\scripts\build-wiki.ps1 -SkillsOnly      # rebuild skills reference only
.\scripts\build-wiki.ps1 -AgentsOnly      # rebuild agents reference only
```

Outputs `docs/wiki/skills-reference.md`, `agents-reference.md`, and `workflows-reference.md` — wired into the wiki CI pipeline.

### Native Bash Installer

Full native bash installer — **no PowerShell dependency** on Linux/macOS/WSL:

```bash
bash install.sh              # interactive install
bash install.sh --yes        # skip prompts
bash install.sh --status     # check install status
bash install.sh --uninstall  # remove global install
```

### Multi-Language Code Graph

Code graph now supports 6 languages: PowerShell, Python, JavaScript, TypeScript, Go, and Rust:

```powershell
.\scripts\code-graph.ps1                          # scan all languages
.\scripts\code-graph.ps1 -Languages "py,js,ts"   # specific languages only
```

### Smart Skill Loader

Context-aware section extraction with TF-IDF scoring and LRU caching:

```powershell
.\scripts\smart-loader.ps1 -Query "authentication jwt"
.\scripts\smart-loader.ps1 -Query "fastapi async" -Context "backend api" -Top 3
.\scripts\smart-loader.ps1 -CacheStats
```

---

## 🆕 What's New in v1.3.0

Five new capabilities — schema, MCP bridge, registry, workflow tests, Cursor export — and a major UX unlock for non-OpenCode hosts. See [CHANGELOG.md](CHANGELOG.md) and the [wiki](docs/wiki/index.md) for the canonical record.

### Use with Cursor (or Windsurf / Aider)

```powershell
# One command writes .cursorrules for every agent into dist/cursorrules/
.\scripts\install-skill.ps1 -Use cursorrules

# Drop into your project and Cursor picks up the persona immediately
cp dist\cursorrules\backend-engineer.cursorrules <your-project>\.cursorrules
```

Each `.cursorrules` includes the agent's role, responsibilities, standards, and skill allowlist — same persona you would see inside OpenCode. See [`scripts/export-cursorrules.ps1`](scripts/export-cursorrules.ps1).

### Aggregate skills from anywhere

```powershell
# Shallow-clone the top 20 sources from registry-sources.txt into skills-mirror/
.\scripts\install-skill.ps1 -Sync

# Or just the top 5 for a quick start
.\scripts\install-skill.ps1 -Sync -TopN 5
```

Then copy `skills-mirror/<source>/skills/<category>/<name>` into your own `skills/` and re-run `.\install.ps1`. See [`registry-sources.txt`](registry-sources.txt) for the curated upstream list.

### Live skill graph

Every wiki build now re-emits `docs/wiki/_data/architecture.mmd` from the actual `agents/` + `skills/` + `workflows/` tree. The wiki architecture page renders it as a live Mermaid graph — never stale. Generator: [`scripts/build-skill-graph.ps1`](scripts/build-skill-graph.ps1).

### Schema-validated opencode.json

[`schemas/opencode.schema.json`](schemas/opencode.schema.json) is now a JSON Schema 2020-12 that any editor (Cursor, VS Code) auto-lints against. Conditional `then:` rules ensure MCP servers carry `command` (stdio) or `url` (http/sse) — never neither, never both.

### Cross-host MCP bridge

Every entry in `opencode.json#mcp_servers` is wrapped as `skills/<category>/mcp-<name>/SKILL.md` by `scripts/mcp-to-skill.ps1` and shipped through the global installer — any OpenCode agent can now opt in to any registered MCP server as if it were a regular skill.

---

## Architectural features (1.2)

Four open concerns documented in [docs/wiki/roadmap.md](docs/wiki/roadmap.md) — all four have a working MVP shipped:

| Concern | MVP (1.2) | Where |
|---------|-----------|-------|
| Code graph (no function-to-file call trees) | ✅ `scripts/code-graph.ps1` — 6 languages (PS, Python, JS, TS, Go, Rust) | v1.2 + v1.4 |
| Static markdown prompts (full SKILL.md over-consumes context) | ✅ `scripts/smart-loader.ps1` — TF-IDF scoring + LRU cache | v1.2 + v1.4 |
| Heavy PowerShell reliance (Linux/macOS friction) | ✅ `install.sh` (pure bash, no pwsh needed) + `install.cmd` + ghcr.io | v1.2 + v1.4 |
| No long-term memory between sessions | ✅ `scripts/session-memory.ps1` — session tracking + preference learning | v1.2 + v1.4 |
| Wiki not auto-generated from content | ✅ `scripts/build-wiki.ps1` — auto-generates reference pages from content | v1.4 |

Full wiki lives at [docs/wiki/index.md](docs/wiki/index.md) and is auto-published to **GitHub Pages** by `.github/workflows/wiki-pages.yml` on every push to `master` (mkdocs-material, dark theme, instant search, pinned to the 9.5.x minor). Browse online: [mattycigemp-crypto.github.io/GOD-OPENCODE](https://mattycigemp-crypto.github.io/GOD-OPENCODE/) (after a one-time Settings → Pages → Source: **GitHub Actions** toggle). Each MVP has a concrete next milestone in the roadmap page.

---

## 🧠 How It Works

### Automatic Discovery

When you run `opencode` in the GOD-OPENCODE directory, OpenCode **automatically** discovers:

| What | Where | Status |
|------|-------|--------|
| 📄 Project context | `AGENTS.md` | ✅ Automatic |
| ⚙️ Agent configs | `opencode.json` | ✅ Automatic |
| 🎯 Project-local skills | `.opencode/skills/` | ✅ Automatic |
| 🌐 Global skills | `~/.config/opencode/skills/` | ⚠️ Requires `install.ps1` |

### Routing Flow

```
You type: "security audit the auth flow"
         ↓
auto-router detects intent: secure (confidence: high)
         ↓
auto-router matches workflow: security-audit
         ↓
workflow-engine loads: workflows/security-audit.md
         ↓
Executes 8 steps, loading skills per step
         ↓
agent-orchestrator switches agents when needed
```

---

## 🎯 What You Get

| Component | Count | Purpose |
|-----------|-------|---------|
| 🤖 Agents | 10 | Specialized AI personas |
| 🧩 Skills | 84 | Domain knowledge loaded on-demand |
| 📋 Workflows | 15 | Step-by-step processes |
| ⚡ Commands | 6 | Slash commands for common tasks |

---

## 🤖 Agents

Invoke with `@agent-name` in OpenCode, or switch between primary agents with Tab.

| Agent | Specialty | Use When |
|-------|-----------|----------|
| `principal-engineer` | System design, architecture, technical strategy | Architecture decisions, code review |
| `backend-engineer` | APIs, server architecture, database integration | Building APIs, database work |
| `frontend-engineer` | React, Next.js, UI/UX, accessibility | UI components, frontend bugs |
| `security-engineer` | Threat modelling, OWASP, pentesting, crypto | Security audits, auth implementation |
| `database-architect` | Schema design, query optimization, migrations | Database design, performance |
| `devops-engineer` | CI/CD, Docker, Kubernetes, Terraform | Deployment, infrastructure |
| `debugger` | Root cause analysis, profiling, log analysis | Bug investigation, troubleshooting |
| `ai-engineer` | LLMs, RAG, embeddings, prompt engineering | AI features, ML pipelines |
| `researcher` | Technology evaluation, comparative analysis | Tech decisions, comparisons |
| `technical-writer` | Documentation, ADRs, runbooks, changelogs | Documentation, guides |

---

## ⚡ Slash Commands

| Command | What It Does | Agent Used |
|---------|--------------|------------|
| `/security-audit` | Full security audit with threat modelling + OWASP | `security-engineer` |
| `/api-design` | Design RESTful/GraphQL APIs with schemas | `backend-engineer` |
| `/debug` | Systematic bug investigation from symptom to fix | `debugger` |
| `/review` | Senior-level code review (correctness, security, performance) | `principal-engineer` |
| `/optimize` | Measurement-driven performance optimization | `principal-engineer` |
| `/build` | Scaffold new agents, skills, workflows, commands | `backend-engineer` |

---

## 🧩 Skills (84 Total)

### Orchestration (4)
`auto-router` · `workflow-engine` · `agent-orchestrator` · `command-builder`

### Backend (10)
`api-design` · `fastapi` · `express` · `graphql` · `django` · `database-design` · `postgres` · `mongodb` · `redis` · `sqlite`

### Frontend (10)
`react` · `nextjs` · `typescript` · `css-architecture` · `state-management` · `component-design` · `web-performance` · `testing-frontend` · `accessibility` · `bundling`

### Security (5)
`authentication` · `cryptography` · `penetration-testing` · `secure-coding` · `security-audit`

### DevOps (8)
`docker` · `kubernetes` · `ci-cd` · `terraform` · `cloud` · `linux` · `networking` · `github-actions`

### Database (5)
`query-optimization` · `schema-design` · `replication` · `sharding` · `data-migration`

### Testing (5)
`unit-testing` · `integration-testing` · `e2e-testing` · `test-driven-development` · `property-based-testing`

### AI (10)
`ai-engineer` · `llm-engineer` · `rag-engineer` · `embedding-engineer` · `evaluation-engineer` · `prompt-engineer` · `mcp-builder` · `agent-builder` · `tool-builder` · `workflow-designer`

### Languages (10)
`python-expert` · `javascript-expert` · `typescript-expert` · `go-expert` · `rust-expert` · `java-expert` · `cpp-expert` · `node-expert` · `react-expert` · `nextjs-expert`

### Core (10)
`architect` · `principal-engineer` · `code-review` · `debugger` · `performance` · `refactor` · `documentation` · `bug-hunter` · `security` · `testing`

### Advanced (7)
`algorithm-expert` · `compiler-design` · `distributed-systems` · `operating-systems` · `optimization` · `reverse-engineering` · `system-design`

> Each skill lives in exactly one category folder under `skills/`, and the per-category counts above sum to exactly **84** — same as the headline.

---

## 📁 Project Structure

```
GOD-OPENCODE/
├── opencode.json              # OpenCode config (agents, commands)
├── AGENTS.md                  # Project context for OpenCode
├── install.ps1                # Global installer (skills, workflows, agents, commands)
├── install.sh                 # Native bash installer (no PowerShell needed)
├── .opencode/skills/          # Project-local skills (auto-discovered)
├── agents/                    # 10 agent personas (AGENT.md each)
├── skills/                    # 84 skill definitions (SKILL.md each, 11 categories)
├── workflows/                 # 15 parameterized workflows
├── commands/                  # 6 slash command definitions
├── router/                    # Intent detection and routing config
├── scripts/                   # PowerShell engines (builder, expansion, health)
├── mcps/                      # MCP server configs
├── templates/                 # Project scaffolds
├── tests/                     # Pester test suite
├── docs/wiki/                 # Markdown wiki (8 pages, single source of truth)
├── memory/                    # Long-term memory store + AGENT_PREFERENCES.md
└── ui/                        # Browser dashboard
```

---

## 🧪 Testing

```powershell
# Run all tests
.\tests\run-tests.ps1

# Run with integration tests
.\tests\run-tests.ps1 -All

# Run specific suite
Invoke-Pester -Path .\tests\unit\ -Output Detailed
```

---

## 🏥 Health Check

```powershell
.\god-health.ps1
```

Verifies:
- ✅ All required directories exist
- ✅ SKILL.md files present in repo
- ✅ Skills installed in `~/.config/opencode/skills/`
- ✅ Workflows/agents/commands in `~/.config/opencode/god-opencode/`
- ✅ Router config is valid JSON
- ✅ All agents have valid AGENT.md

---

## 🖥️ Interfaces

### Terminal UI (TUI)

```powershell
.\god-ui.ps1
```

Interactive terminal interface (v4.0) with the following menu (Enter = the default action):

| Key | Action |
|-----|--------|
| Enter / `1` | **Install Globally** — default; installs skills/agents/workflows into `~/.config/opencode/` |
| `2` | Health Check |
| `3` | Code Graph — build/refresh the call-graph index (6 languages) |
| `4` | Skill Fragment — dynamic context lookup for a topic |
| `5` | Memory — recall / append session memory |
| `6` | Cross-Platform — show bash / cmd / PowerShell install paths |
| `7` | Tests — Pester suite |
| `8` | Wiki — open the local wiki |
| `9` | Dashboard — open the browser dashboard |
| `S` | Session Memory — init / track / recall cross-session context |
| `W` | Wiki Builder — auto-generate reference pages from content |
| `L` | Live Architecture — regenerate wiki skill/agent/workflow graph |
| `R` | Skills Registry — bulk-fetch top-N from registry-sources.txt |
| `C` | Cursor Export — generate .cursorrules for every agent |
| `N` | What's new — current release notes from CHANGELOG.md |
| `Q` | Exit |

### Browser Dashboard

```powershell
start ui\index.html
```

Dark-themed, responsive dashboard showing all agents, skills, workflows, commands, the Architectural Features roadmap, and the Wiki landing page. Launch from TUI (option 9) or directly.

---

## 🤝 Contributing

| Component | Location | Format |
|-----------|----------|--------|
| Skill | `skills/{category}/{skill-name}/SKILL.md` | YAML frontmatter + content |
| Agent | `agents/{agent-name}/AGENT.md` | Role, Responsibilities, Standards, Skills |
| Workflow | `workflows/{workflow-name}.md` | Purpose, Parameters, Steps |
| Command | `commands/{command-name}.md` | Purpose, Usage, Steps |

**Rules:**
- All names: lowercase with hyphens only
- Skills must have `name` and `description` in frontmatter
- Test with `.\god-health.ps1` before submitting

---

## 📄 License

MIT
