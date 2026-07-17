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

That's it. You now have 10 expert agents, 84 skills, 15 workflows, and 6 slash commands ready to use in OpenCode.

### How OpenCode Discovers Everything

When you run `opencode` in the GOD-OPENCODE directory, OpenCode **automatically** discovers:

| What | Where | How |
|------|-------|-----|
| Project context | `AGENTS.md` | OpenCode reads it on startup |
| Agent configs | `opencode.json` | OpenCode loads custom agents and commands |
| Project-local skills | `.opencode/skills/` | OpenCode discovers from `.opencode/skills/*/SKILL.md` |
| Global skills | `~/.config/opencode/skills/` | OpenCode discovers from `~/.config/opencode/skills/*/SKILL.md` |

**No manual setup required** — just `opencode` in the repo directory.

For **global access** (skills available from any directory):

```powershell
.\install.ps1
```

This copies skills, workflows, agents, and commands to `~/.config/opencode/`.

---

## Architecture

GOD-OPENCODE extends OpenCode with three layers:

```
┌─────────────────────────────────────────────────────┐
│  Orchestration Layer                                │
│  auto-router → workflow-engine → agent-orchestrator │
├─────────────────────────────────────────────────────┤
│  Skills System                                       │
│  84 SKILL.md files across 11 categories              │
├─────────────────────────────────────────────────────┤
│  Agents                                              │
│  10 engineering personas with custom prompts         │
├─────────────────────────────────────────────────────┤
│  Workflows                                           │
│  15 parameterized step-by-step processes             │
├─────────────────────────────────────────────────────┤
│  Commands                                            │
│  6 slash commands for common tasks                   │
└─────────────────────────────────────────────────────┘
                       ↕
┌─────────────────────────────────────────────────────┐
│  OpenCode — reads .opencode/ and ~/.config/opencode/│
└─────────────────────────────────────────────────────┘
```

### How Routing Works

1. You type: `"security audit the auth flow"`
2. **auto-router** skill detects intent: `secure` (confidence: high)
3. **auto-router** matches workflow: `security-audit`
4. **workflow-engine** skill loads `workflows/security-audit.md`
5. Executes 8 steps sequentially, loading skills per step
6. **agent-orchestrator** switches agents when needed

---

## Orchestration Skills

These skills power the intelligent routing system:

| Skill | Purpose |
|-------|---------|
| `auto-router` | Intent detection → agent/skill/workflow routing |
| `workflow-engine` | Execute step-by-step workflows from markdown files |
| `agent-orchestrator` | Switch between specialist agents mid-conversation |
| `command-builder` | Scaffold agents, skills, workflows, commands |

---

## Slash Commands

| Command | Description | Agent |
|---------|-------------|-------|
| `/security-audit` | Full security audit with threat modelling and OWASP checks | security-engineer |
| `/api-design` | Design RESTful/GraphQL APIs with schemas and documentation | backend-engineer |
| `/debug` | Systematic bug investigation from symptom to fix | debugger |
| `/review` | Senior-level code review across correctness, security, performance | principal-engineer |
| `/optimize` | Measurement-driven performance optimization | principal-engineer |
| `/build` | Scaffold new agents, skills, workflows, commands | backend-engineer |

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

Invoke agents with `@agent-name` in OpenCode, or switch between primary agents with Tab.

---

## Skills

84 skills across 11 categories:

| Category | Skills |
|----------|--------|
| `orchestration` | auto-router, workflow-engine, agent-orchestrator, command-builder |
| `backend` | api-design, fastapi, express, graphql, database-design, postgres, mongodb, redis, sqlite |
| `frontend` | react, nextjs, typescript, css-architecture, state-management, component-design, web-performance, testing-frontend, accessibility, bundling |
| `security` | security, authentication, cryptography, penetration-testing, secure-coding, security-audit |
| `devops` | docker, kubernetes, ci-cd, terraform, cloud, linux, networking, github-actions |
| `database` | database-design, postgres, mongodb, sqlite, query-optimization, schema-design, redis, replication, sharding, data-migration |
| `testing` | testing, unit-testing, integration-testing, e2e-testing, test-driven-development, property-based-testing |
| `ai` | ai-engineer, llm-engineer, rag-engineer, embedding-engineer, evaluation-engineer, prompt-engineer, mcp-builder, agent-builder, tool-builder, workflow-designer |
| `languages` | python-expert, javascript-expert, typescript-expert, go-expert, rust-expert, java-expert, cpp-expert, node-expert, react-expert, nextjs-expert |
| `core` | architect, principal-engineer, code-review, debugger, performance, refactor, documentation, bug-hunter, security, testing |
| `advanced` | algorithm-expert, compiler-design, distributed-systems, operating-systems, optimization, reverse-engineering, system-design |

---

## Project Structure

```
GOD-OPENCODE/
├── opencode.json              # OpenCode config (agents, commands, MCPs)
├── AGENTS.md                  # Project context for OpenCode
├── god-install.ps1            # One-command installer
├── install.ps1                # Smart installer (skills, workflows, agents, commands)
├── .opencode/skills/          # Project-local skills (auto-discovered)
├── agents/                    # 10 agent personas
├── skills/                    # 84 skill definitions
├── workflows/                 # 15 parameterized workflows
├── commands/                  # 6 slash command definitions
├── router/                    # Intent detection and routing config
├── scripts/                   # Core engine scripts
├── mcps/                      # MCP server configs
├── templates/                 # Project scaffolds
├── tests/                     # Pester test suite
└── ui/                        # Browser dashboard
```

---

## Running Tests

```powershell
# Run all tests (excluding integration)
.\tests\run-tests.ps1

# Run with integration tests
.\tests\run-tests.ps1 -All

# Run specific test suite
Invoke-Pester -Path .\tests\unit\ -Output Detailed
```

---

## Health Check

```powershell
.\god-health.ps1
```

Verifies:
- All required directories exist
- SKILL.md files present in repo
- Skills installed in `~/.config/opencode/skills/`
- Workflows, agents, commands installed in `~/.config/opencode/god-opencode/`
- Router config is valid JSON
- All agents have valid AGENT.md

---

## Browser Dashboard

Open the visual dashboard:

```powershell
start ui\index.html
```

A dark-themed, responsive dashboard showing all agents, skills, workflows, and commands.

---

## Contribution Guidelines

**Quick rules:**
- Skill directories: `skills/{category}/{skill-name}/SKILL.md`
- Agent directories: `agents/{agent-name}/AGENT.md`
- Workflow files: `workflows/{workflow-name}.md`
- All names: lowercase with hyphens only
- Skills must have YAML frontmatter with `name` and `description`
- Test with `.\god-health.ps1` before submitting

---

## License

MIT
