# Contributing to GOD-OPENCODE

## Overview

GOD-OPENCODE is file-based and declarative - contributing means adding or improving Markdown and JSON files. There are no runtime dependencies to install, no builds to run, and no databases to configure.

---

## Adding a Skill

1. Create a directory: `skills/{category}/{skill-name}/`
   - Use lowercase letters and hyphens only (e.g., `skills/backend/graphql-subscriptions/`)
   - Valid categories: `ai`, `backend`, `frontend`, `devops`, `security`, `database`, `advanced`, `testing`

2. Create `skills/{category}/{skill-name}/SKILL.md` with all required sections:

```markdown
---
name: {skill-name}
description: {one-line description}
---

# {skill-name}

## Mission

{What this skill enables. One paragraph.}

## Core Responsibilities

- {Responsibility 1}
- {Responsibility 2}
...

## Workflow

1. {Step 1}
2. {Step 2}
...

## Quality Standards

Always:
- {Standard 1}
- {Standard 2}

Never:
- {Anti-pattern 1}
```

3. Run `.\god-health.ps1` to verify it's detected.
4. Run `.\install.ps1` to install it into OpenCode.

---

## Adding an Agent

1. Create: `agents/{agent-name}/AGENT.md`

2. Required sections:

```markdown
# {agent-name}

## Role

{One paragraph defining this agent's role.}

## Responsibilities

- {Responsibility 1}

## Standards

- {Standard 1}

## Skills

- {skill-name-1}
- {skill-name-2}

## Delegation  ← optional

- {other-agent-name}
```

3. Add keyword-to-agent entries in `router/agent-router.json`.

---

## Adding a Workflow

1. Create: `workflows/{workflow-name}.md`

2. Required structure:

```markdown
# {workflow-name}

## Purpose

{Description of when to use this workflow.}

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PARAM_NAME` | ... | yes/no |

## Steps

### Step 1: {Title}
- Agent: {agent-name}
- Skills: [{skill-name}, ...]
- Action: {What to do, with {{PARAM_NAME}} placeholders.}
```

---

## Adding a Prompt

1. Create: `prompts/{category}/{prompt-name}.md`
2. Valid categories: `coding`, `ai`, `research`, `writing`, `business`, `security`
3. Required sections: `# Title`, `## Purpose`, `## Parameters` (table), `## Prompt` (with `{{PARAM_NAME}}` placeholders), `## Example Usage`

---

## Adding a Template

1. Create: `templates/{template-name}/`
2. Required file: `templates/{template-name}/README.md` with setup instructions
3. All scaffold files must run locally following the README

---

## Adding an MCP

1. Add to `mcps/registry.json`:
```json
"my-mcp": {
  "enabled": true,
  "description": "...",
  "install_command": "npm install -g @org/my-mcp"
}
```

2. Add connection config to `mcps/mcp-config.json`.

---

## Naming Conventions

| Component | Convention |
|-----------|------------|
| Skill directory | `lowercase-with-hyphens` |
| Agent directory | `lowercase-with-hyphens` |
| Workflow file | `lowercase-with-hyphens.md` |
| Prompt file | `lowercase-with-hyphens.md` |
| Template directory | `lowercase-with-hyphens` |
| SKILL.md / AGENT.md | Uppercase |

---

## Before Submitting

Run the health check and confirm all checks pass:

```powershell
.\god-health.ps1
```

