---
name: command-builder
description: Build, scaffold, and manage GOD-OPENCODE components. Create new agents, skills, workflows, and commands. Use when you need to generate or modify GOD-OPENCODE infrastructure.
---

# command-builder

## Purpose

Scaffold and manage GOD-OPENCODE components: agents, skills, workflows, and commands. Generate boilerplate, validate structure, and maintain consistency.

## When to Use

- User wants to create a new agent, skill, workflow, or command
- User wants to modify existing components
- User wants to validate GOD-OPENCODE structure
- User wants to run the build/expansion engines

## Available Commands

| Command | Description | File |
|---------|-------------|------|
| build | Build/scaffold components | `commands/build.md` |
| debug | Debug issues and bugs | `commands/debug.md` |
| review | Code review workflows | `commands/review.md` |
| architect | Architecture decisions | `commands/architect.md` |
| secure | Security analysis | `commands/secure.md` |
| optimize | Performance optimization | `commands/optimize.md` |

## Component Types

### Agents

Location: `agents/{agent-name}/AGENT.md`

Structure:
```markdown
# agent-name

## Role
One-paragraph description of the agent's role.

## Responsibilities
- Responsibility 1
- Responsibility 2

## Standards
- Standard 1
- Standard 2

## Skills
- skill1
- skill2
```

To create a new agent:
1. Create directory: `agents/{agent-name}/`
2. Create `AGENT.md` with the structure above
3. List relevant skills from `skills/` directory

### Skills

Location: `skills/{category}/{skill-name}/SKILL.md`

Structure:
```markdown
---
name: skill-name
description: Brief description for OpenCode to match against user requests.
---

# skill-name

## Purpose
What this skill does.

## When to Use
- Trigger condition 1
- Trigger condition 2

## How to Execute
Step-by-step instructions.

## Quality Standards
- Standard 1
- Standard 2
```

To create a new skill:
1. Create directory: `skills/{category}/{skill-name}/`
2. Create `SKILL.md` with frontmatter (name, description)
3. Include purpose, triggers, execution steps, quality standards

### Workflows

Location: `workflows/{workflow-name}.md`

Structure:
```markdown
# workflow-name

## Purpose
What this workflow accomplishes.

## Parameters
| Parameter | Description | Required |
|-----------|-------------|----------|
| PARAM     | Description | yes/no   |

## Steps

### Step 1: Step Name
- Agent: agent-name
- Skills: skill1, skill2
- Action: What to do with {{PARAM}} placeholders.
```

To create a new workflow:
1. Create file: `workflows/{workflow-name}.md`
2. Define parameters with placeholders
3. List steps with assigned agents and skills
4. Use `{{PARAM}}` syntax for substitution

### Commands

Location: `commands/{command-name}.md`

Structure:
```markdown
# command-name

## Purpose
What this command does.

## Usage
How to invoke it.

## Steps
What it executes.
```

## Build Engine

The build engine (`scripts/god-builder.ps1`) generates components:
- Creates directory structure
- Generates boilerplate files
- Validates consistency

To run the build engine:
```powershell
.\scripts\god-builder.ps1
```

## Expansion Engine

The expansion engine (`scripts/god-expansion.ps1`) extends existing components:
- Adds new skills to agents
- Updates workflow steps
- Expands command capabilities

To run the expansion engine:
```powershell
.\scripts\god-expansion.ps1
```

## Validation

When creating components, validate:
1. SKILL.md has frontmatter with `name` and `description`
2. Agent files have Role, Responsibilities, Standards, Skills sections
3. Workflow files have Purpose, Parameters, Steps sections
4. Skill names match directory names
5. Agent skill lists reference existing skills

## Example: Create a New Agent

User: "Create a mobile-engineer agent"

1. Create directory: `agents/mobile-engineer/`
2. Create `AGENT.md`:
```markdown
# mobile-engineer

## Role
Senior mobile engineer specializing in iOS and Android development.

## Responsibilities
- Design and build mobile applications
- Implement offline-first architecture
- Optimize battery and memory usage
- Handle push notifications and deep linking

## Standards
- Follow platform-specific design guidelines
- Implement proper error handling
- Write unit and integration tests

## Skills
- mobile-development
- ios
- android
- react-native
- flutter
```
