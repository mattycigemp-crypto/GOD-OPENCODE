<p align="center">
  <img src="brand/wordmark.png" alt="GOD-OPENCODE" width="600">
</p>

<h3 align="center">An AI engineering operating system built on top of OpenCode.</h3>

<p align="center">
  One command bootstraps a complete, production-grade AI engineering environment — with the right experts, skills, workflows, and tools already loaded.
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

Each `v*` tag publish a versioned image (`ghcr.io/.../god-opencode:v1.1.5`) plus `latest`. The image bundles PowerShell 7.4 + the installable project so it works identically on Linux, macOS, and Windows hosts.

**Cross-platform shims:** `bash install.sh` (requires `pwsh`) on Linux/macOS/WSL; `install.cmd` on Windows cmd.exe. See [docs/wiki/cross-platform.md](docs/wiki/cross-platform.md).

---

## Architectural features (1.2)

Four open concerns documented in [docs/wiki/roadmap.md](docs/wiki/roadmap.md) — all four have a working MVP shipped:

| Concern | MVP (1.2) | Where |
|---------|-----------|-------|
| Code graph (no function-to-file call trees) | `scripts/code-graph.ps1` emits JSON call-graph for PowerShell files | [docs/wiki/graph.md](docs/wiki/graph.md) |
| Static markdown prompts (full SKILL.md over-consumes context) | `scripts/skill-fragment.ps1` returns matching `##` sections per request | [docs/wiki/dynamic-skills.md](docs/wiki/dynamic-skills.md) |
| Heavy PowerShell reliance (Linux/macOS friction) | `install.sh` (bash) + `install.cmd` (cmd.exe) + ghcr.io container | [docs/wiki/cross-platform.md](docs/wiki/cross-platform.md) |
| No long-term memory between sessions | `New-MemoryRecall` + `memory/AGENT_PREFERENCES.md` | [docs/wiki/memory.md](docs/wiki/memory.md) |

Full wiki lives at [docs/wiki/index.md](docs/wiki/index.md). Each MVP has a concrete next milestone in the roadmap page.

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

### Backend (9)
`api-design` · `fastapi` · `express` · `graphql` · `database-design` · `postgres` · `mongodb` · `redis` · `sqlite`

### Frontend (10)
`react` · `nextjs` · `typescript` · `css-architecture` · `state-management` · `component-design` · `web-performance` · `testing-frontend` · `accessibility` · `bundling`

### Security (6)
`security` · `authentication` · `cryptography` · `penetration-testing` · `secure-coding` · `security-audit`

### DevOps (8)
`docker` · `kubernetes` · `ci-cd` · `terraform` · `cloud` · `linux` · `networking` · `github-actions`

### Database (10)
`database-design` · `postgres` · `mongodb` · `sqlite` · `query-optimization` · `schema-design` · `redis` · `replication` · `sharding` · `data-migration`

### Testing (6)
`testing` · `unit-testing` · `integration-testing` · `e2e-testing` · `test-driven-development` · `property-based-testing`

### AI (10)
`ai-engineer` · `llm-engineer` · `rag-engineer` · `embedding-engineer` · `evaluation-engineer` · `prompt-engineer` · `mcp-builder` · `agent-builder` · `tool-builder` · `workflow-designer`

### Languages (10)
`python-expert` · `javascript-expert` · `typescript-expert` · `go-expert` · `rust-expert` · `java-expert` · `cpp-expert` · `node-expert` · `react-expert` · `nextjs-expert`

### Core (10)
`architect` · `principal-engineer` · `code-review` · `debugger` · `performance` · `refactor` · `documentation` · `bug-hunter` · `security` · `testing`

### Advanced (7)
`algorithm-expert` · `compiler-design` · `distributed-systems` · `operating-systems` · `optimization` · `reverse-engineering` · `system-design`

---

## 📁 Project Structure

```
GOD-OPENCODE/
├── opencode.json              # OpenCode config (agents, commands)
├── AGENTS.md                  # Project context for OpenCode
├── install.ps1                # Global installer (skills, workflows, agents, commands)
├── .opencode/skills/          # Project-local skills (auto-discovered)
├── agents/                    # 10 agent personas (AGENT.md each)
├── skills/                    # 84 skill definitions (SKILL.md each)
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

Interactive terminal interface with:
- System overview (agents, skills, workflows, global status)
- One-click install/update
- Health check
- Test runner
- Router tester
- **Launch browser dashboard** (option 7)

### Browser Dashboard

```powershell
start ui\index.html
```

Dark-themed, responsive dashboard showing all agents, skills, workflows, commands, and quick start guide. Launch from TUI (option 7) or directly.

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
