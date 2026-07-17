<p align="center">
  <img src="brand/wordmark.png" alt="GOD-OPENCODE" width="600">
</p>

<h3 align="center">An AI engineering operating system built on top of OpenCode.</h3>

<p align="center">
  One command bootstraps a complete, production-grade AI engineering environment — with the right experts, skills, workflows, and tools already loaded.
</p>

---

## What It Does

GOD-OPENCODE wraps OpenCode with a modular framework that gives every request the right context: the expert agent persona, the domain-specific skill knowledge, and the proven workflow step sequence. Instead of getting a generic AI assistant, you get a senior principal engineer, a security auditor, a database architect, or a full-stack team — whichever the task calls for.

**The system is entirely file-based and transparent.** Skills are Markdown files. Agents are Markdown files. Workflows are Markdown files. The router is a JSON config. PowerShell drives orchestration. Nothing is hidden.

---

## Quick Start

```powershell
# Clone and enter the directory
git clone https://github.com/mattycigemp-crypto/GOD-OPENCODE
cd GOD-OPENCODE

# Bootstrap everything in one command
.\god-install.ps1

# Verify the installation
.\god-health.ps1
```

That's it. You now have 10 expert agents, 70+ skills, 15 workflows, and 6 slash commands ready to use in OpenCode.

---

## Architecture

GOD-OPENCODE is organized as a layered stack:

```
┌─────────────────────────────────────────────────────┐
│  Intelligence Engine                                 │
│  Scans repos, detects project type, generates plans  │
├─────────────────────────────────────────────────────┤
│  Router                                              │
│  Keyword → Agent + Skills selection                  │
├─────────────────────────────────────────────────────┤
│  Command System                                      │
│  /build  /architect  /debug  /review  /secure  /optimize
├──────────────────────┬──────────────────────────────┤
│  MCP System           │  Prompt Library              │
│  5 MCP servers        │  50+ prompt templates        │
├──────────────────────┴──────────────────────────────┤
│  Workflow System                                     │
│  15 parameterized workflow definitions               │
├──────────────────────┬──────────────────────────────┤
│  Agents              │  Templates                    │
│  10 personas         │  9 project scaffolds          │
├──────────────────────┴──────────────────────────────┤
│  Skills System                                       │
│  70+ SKILL.md files across 10 categories             │
├─────────────────────────────────────────────────────┤
│  Memory System                                       │
│  ADRs, TODOs, conventions, changelogs                │
├─────────────────────────────────────────────────────┤
│  Installer Engine                                    │
│  god-install.ps1 — fully idempotent one-command setup│
└─────────────────────────────────────────────────────┘
                       ↕
┌─────────────────────────────────────────────────────┐
│  OpenCode — reads ~/.config/opencode/skills/ at runtime
└─────────────────────────────────────────────────────┘
```

| Layer | Directory | Purpose |
|-------|-----------|---------|
| Installer | `god-install.ps1` | Bootstraps everything |
| Skills | `skills/` | 70+ expert knowledge docs |
| Agents | `agents/` | 10 engineering personas |
| Workflows | `workflows/` | 15 step-by-step processes |
| MCPs | `mcps/` | 5 MCP server configs |
| Prompts | `prompts/` | 15+ reusable prompt templates |
| Templates | `templates/` | 9 project scaffolds |
| Memory | `memory/` | Persistent ADRs and decisions |
| Router | `router/` | Keyword-to-agent dispatch |
| Commands | `commands/` | Slash command definitions |
| Intelligence | `scripts/god-intelligence.ps1` | Repo scanner + plan generator |

---

## Slash Commands

| Command | Description | Agent |
|---------|-------------|-------|
| `/build` | Build a complete application from description to deployment | principal-engineer + all |
| `/architect` | Design or review system architecture | principal-engineer |
| `/debug` | Systematic bug investigation from symptom to fix | debugger |
| `/review` | Senior-level code review across correctness, security, performance | principal-engineer + security |
| `/secure` | Full security audit with threat modelling and OWASP checks | security-engineer |
| `/optimize` | Measurement-driven performance optimization | principal-engineer + database-architect |

---

## Agents

| Agent | Specialty |
|-------|-----------|
| `principal-engineer` | System design, architecture, technical strategy |
| `backend-engineer` | APIs, server architecture, database integration |
| `frontend-engineer` | React, Next.js, UI/UX, accessibility |
| `ai-engineer` | LLMs, RAG, embeddings, prompt engineering |
| `security-engineer` | Threat modelling, OWASP, pentesting, crypto |
| `database-architect` | Schema design, query optimization, migrations |
| `devops-engineer` | CI/CD, Docker, Kubernetes, Terraform |
| `debugger` | Root cause analysis, profiling, log analysis |
| `researcher` | Technology evaluation, comparative analysis |
| `technical-writer` | Documentation, ADRs, runbooks, changelogs |

---

## Project Structure

```
GOD-OPENCODE/
├── god-install.ps1          # One-command installer
├── god-health.ps1           # System health check
├── god-ui.ps1               # Terminal UI
├── install.ps1              # Smart skill installer
├── agents/                  # 10 agent personas
│   ├── principal-engineer/
│   │   └── AGENT.md
│   └── ...
├── skills/                  # 70+ skill definitions
│   ├── ai/
│   ├── backend/
│   ├── frontend/
│   ├── devops/
│   ├── security/
│   ├── database/
│   ├── testing/
│   └── advanced/
├── workflows/               # 15 parameterized workflows
├── commands/                # 6 slash command definitions
├── prompts/                 # 15+ prompt templates
├── templates/               # 9 project scaffolds
├── mcps/                    # MCP server configs
├── router/                  # Keyword-to-agent routing
├── scripts/                 # Core engine scripts
│   ├── shared-utils.ps1     # Shared utility functions
│   ├── router.ps1           # Router engine
│   ├── god-builder.ps1      # Builder engine
│   ├── god-expansion.ps1    # Expansion engine
│   ├── memory.ps1           # Memory system
│   └── workflow-engine.ps1  # Workflow engine
├── tools/                   # Intelligence tools
├── tests/                   # Pester test suite
│   ├── unit/
│   ├── property/
│   ├── smoke/
│   └── integration/
└── ui/                      # Browser dashboard
    └── index.html
```

---

## Terminal UI

Launch the interactive terminal interface:

```powershell
.\god-ui.ps1
```

Features:
- Dashboard with system overview
- Health check visualization
- Project scan with intelligence engine
- Test runner with suite selection
- Memory viewer
- Router keyword tester

---

## Browser Dashboard

Open the visual dashboard:

```powershell
start ui\index.html
```

A dark-themed, responsive dashboard showing all agents, skills, workflows, commands, prompts, templates, router mappings, and MCP integrations.

---

## How the Router Works

The router tokenizes your request, matches keywords against `router/agent-router.json`, and returns the top-3 agent candidates by match score.

```powershell
.\scripts\router.ps1 -Request "build a fastapi api with postgres authentication"
```

Output:
```
Selected Agent : backend-engineer
Fallback       : False
Top Candidates:
  backend-engineer (score: 3)
  database-architect (score: 1)
  security-engineer (score: 1)
Skills Loaded:
  - api-design
  - code-review
  - backend-engineer
  ...
```

Edit `router/agent-router.json` to add custom keyword mappings — no script changes needed.

---

## Running Tests

```powershell
# Run all tests (excluding integration)
.\tests\run-tests.ps1

# Run with integration tests
.\tests\run-tests.ps1 -All

# Run specific test suite
Invoke-Pester -Path .\tests\unit\ -Output Detailed
Invoke-Pester -Path .\tests\property\ -Output Detailed
Invoke-Pester -Path .\tests\smoke\ -Output Detailed
```

---

## Health Check

```powershell
.\god-health.ps1
```

Verifies:
- All 15 required directories exist
- 70+ SKILL.md files present in repo
- Skills installed in `~/.config/opencode/skills/`
- MCP registry is valid JSON with 5 enabled MCPs
- Router config is valid JSON with routing rules
- 12 key scripts exist
- All 10 agents have valid AGENT.md with required sections
- 4 required workflows present
- 6 required commands present

---

## Contribution Guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process.

**Quick rules:**
- Skill directories: `skills/{category}/{skill-name}/SKILL.md`
- Agent directories: `agents/{agent-name}/AGENT.md`
- All names: lowercase with hyphens only
- New components require all mandatory sections (see CONTRIBUTING.md)
- Test with `.\god-health.ps1` before submitting

---

## License

MIT
