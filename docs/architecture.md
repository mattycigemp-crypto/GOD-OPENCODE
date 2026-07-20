# GOD-OPENCODE Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         OpenCode Editor                         │
│                    (Chat, Commands, Agents)                     │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       │  skill(name="...") / @agent-name / /command
                       │
┌──────────────────────▼──────────────────────────────────────────┐
│                      GOD-OPENCODE Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │    Agents    │  │    Skills    │  │      Workflows       │   │
│  │  (10 roles)  │  │  (88 skills) │  │     (16 processes)   │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │
│         │                │                     │               │
│         └────────────────┴─────────────────────┘               │
│                            │                                   │
│                   ┌─────────▼──────────┐                       │
│                   │   Router / Commands  │                       │
│                   └──────────┬───────────┘                       │
└──────────────────────────────┼──────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                     Project Repository                          │
│   skills/  workflows/  agents/  commands/  scripts/  docs/      │
└─────────────────────────────────────────────────────────────────┘
```

## Three-Layer Architecture

GOD-OPENCODE extends OpenCode with three layers:

### 1. Agents

Specialized AI personas that handle specific engineering domains.

| Agent | Responsibility |
|-------|----------------|
| `principal-engineer` | Architecture, code review, technical leadership |
| `backend-engineer` | Server-side architecture, APIs, databases |
| `frontend-engineer` | React, Next.js, TypeScript, CSS |
| `ai-engineer` | LLMs, embeddings, RAG, ML pipelines |
| `security-engineer` | Application security, audits, pentesting |
| `database-architect` | Schema design, query optimization |
| `devops-engineer` | CI/CD, containers, infrastructure |
| `debugger` | Root cause analysis, bug fixing |
| `researcher` | Technical research and documentation |
| `technical-writer` | Documentation and communication |

### 2. Skills

Domain knowledge modules loaded on-demand via `skill(name="...")`.

- Stored as `SKILL.md` files under `skills/<category>/<name>/`
- YAML frontmatter with `name` and `description`
- Provide standards, workflows, and expert guidance for a domain
- 12 categories: ai, backend, frontend, devops, security, database, advanced, testing, languages, core, orchestration, writing

### 3. Workflows

Step-by-step processes that orchestrate agents and skills.

- Stored as Markdown files under `workflows/`
- Use `{{PARAM}}` syntax for parameter substitution
- Define which agent runs each step and which skills are required

## How Components Connect

```
User Request
    │
    ▼
┌─────────────────┐
│ Intent Detection│  ← router/agent-router.json
│  (auto-router)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Command / Agent │  ← commands/*.md + opencode.json agent map
│   Selection     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Skill Loading   │  ← skills/**/*.md
│   & Context     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Workflow Engine │  ← scripts/workflow-engine.ps1
│ Step Execution  │
└─────────────────┘
```

## OpenCode Integration Points

| Integration | Location | Purpose |
|-------------|----------|---------|
| `opencode.json` | Repository root | Declares agents, commands, permissions, and instructions |
| `~/.config/opencode/skills/` | User machine | Installed skills directory |
| `~/.config/opencode/god-opencode/` | User machine | Installed workflows, agents, commands |
| `skill` tool | Runtime | Loads a skill by name into context |
| `@agent-name` | Runtime | Invokes a subagent |
| `/command` | Runtime | Runs a registered command |

## Data Flow

1. OpenCode reads `opencode.json` at startup.
2. User input is routed via `auto-router` to the best agent or command.
3. The selected agent loads relevant skills and executes the appropriate workflow.
4. Each workflow step delegates to the correct agent with the right skills.
5. Results are returned to the user with citations and next-step suggestions.

## Extension Points

- **Add an agent**: Create `agents/<name>/AGENT.md` and register in `opencode.json`.
- **Add a skill**: Create `skills/<category>/<name>/SKILL.md`.
- **Add a workflow**: Create `workflows/<name>.md` with `{{PARAM}}` placeholders.
- **Add a command**: Create `commands/<name>.md` and map it in `opencode.json`.
