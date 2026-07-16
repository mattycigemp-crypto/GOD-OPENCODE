# GOD-OPENCODE

**An AI engineering operating system built on top of OpenCode.**

One command bootstraps a complete, production-grade AI engineering environment - with the right experts, skills, workflows, and tools already loaded.

---

## Project Purpose

GOD-OPENCODE wraps OpenCode with a modular framework that gives every request the right context: the expert agent persona, the domain-specific skill knowledge, and the proven workflow step sequence. Instead of getting a generic AI assistant, you get a senior principal engineer, a security auditor, a database architect, or a full-stack team - whichever the task calls for.

The system is entirely file-based and transparent. Skills are Markdown files. Agents are Markdown files. Workflows are Markdown files. The router is a JSON config. PowerShell drives orchestration. Nothing is hidden.

---

## Architecture Overview

GOD-OPENCODE is organized as a 10-layer stack:

```
┌─────────────────────────────────────────────────────────┐
│  Layer 10: Intelligence Engine                           │
│  (Scans repos, detects project type, generates plans)   │
├─────────────────────────────────────────────────────────┤
│  Layer 9:  Router                                        │
│  (Keyword → Agent + Skills selection)                   │
├─────────────────────────────────────────────────────────┤
│  Layer 8:  Command System                                │
│  (/build /architect /debug /review /secure /optimize)   │
├──────────────────────┬──────────────────────────────────┤
│  Layer 5: MCP System │  Layer 6: Prompt Library         │
│  (5 MCP servers)     │  (50+ prompt templates)          │
├──────────────────────┴──────────────────────────────────┤
│  Layer 4: Workflow System                                │
│  (10+ parameterized workflow definitions)               │
├──────────────────────┬──────────────────────────────────┤
│  Layer 3: Agents     │  Layer 7: Templates              │
│  (10 agent personas) │  (6 project scaffolds)           │
├──────────────────────┴──────────────────────────────────┤
│  Layer 2: Skills System                                  │
│  (70+ SKILL.md files across 8 categories)               │
├─────────────────────────────────────────────────────────┤
│  Layer 8b: Memory System                                 │
│  (ADRs, TODOs, conventions, changelogs, assumptions)    │
├─────────────────────────────────────────────────────────┤
│  Layer 1: Core Installer Engine                          │
│  (god-install.ps1 - fully idempotent one-command setup) │
└─────────────────────────────────────────────────────────┘
                       ↕
┌─────────────────────────────────────────────────────────┐
│  OpenCode - reads ~/.config/opencode/skills/ at runtime │
└─────────────────────────────────────────────────────────┘
```

| Layer | Directory | Purpose |
|-------|-----------|---------|
| Installer | `god-install.ps1` | Bootstraps everything |
| Skills | `skills/` | 70+ expert knowledge docs |
| Agents | `agents/` | 10 engineering personas |
| Workflows | `workflows/` | 10+ step-by-step processes |
| MCPs | `mcps/` | 5 MCP server configs |
| Prompts | `prompts/` | 15+ reusable prompt templates |
| Templates | `templates/` | 6 project scaffolds |
| Memory | `memory/` | Persistent ADRs and decisions |
| Router | `router/` | Keyword-to-agent dispatch |
| Commands | `commands/` | Slash command definitions |
| Intelligence | `scripts/god-intelligence.ps1` | Repo scanner + plan generator |

---

## Installation

### Prerequisites

- Windows with PowerShell 5.1+
- [OpenCode](https://opencode.ai) installed

### One-command setup

```powershell
cd C:\path\to\GOD-OPENCODE
.\god-install.ps1
```

This will:
1. Create all required directories
2. Generate all agents, skills, workflows, prompts, and templates
3. Copy skills to `~/.config/opencode/skills/` (where OpenCode loads them)
4. Process the MCP registry
5. Print an installation summary

Re-run any time - the installer is fully idempotent and will not overwrite your custom content.

---

## Quick Start

After installation, open OpenCode in any project directory and use slash commands:

### Build a new application
```
/build a FastAPI REST API with JWT auth and PostgreSQL
```

### Debug a problem
```
/debug users are getting duplicate emails on registration
```

### Security audit
```
/secure review the authentication flow
```

### Architecture review
```
/architect should I use PostgreSQL or MongoDB for this use case?
```

### Code review
```
/review [paste code here]
```

### Performance optimization
```
/optimize the user search endpoint is slow at 1000+ users
```

The Router automatically selects the right agent and skills. You can also invoke agents directly:

```
As the database-architect, design a schema for a multi-tenant SaaS application.
```

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

## Running the Health Check

```powershell
.\god-health.ps1
```

This verifies all directories, skills, agents, MCPs, workflows, and commands are correctly installed.

---

## UI Dashboard

Open `ui/index.html` in a browser to view a local dashboard showing all installed components, routing rules, and system status.

