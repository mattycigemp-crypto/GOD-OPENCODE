# Workflow Authoring Guide

## What Is a Workflow?

A workflow is a Markdown file in `workflows/` that defines a repeatable, multi-step process. Workflows orchestrate agents and skills to complete complex engineering tasks.

## File Location and Naming

- Location: `workflows/<workflow-name>.md`
- Filename: lowercase, hyphen-separated (e.g., `api-development.md`)

## Structure

A workflow file has four main parts:

1. **Title** — H1 heading with the workflow name.
2. **Purpose** — Short description of what the workflow does.
3. **Parameters** — Table of `{{PARAM}}` placeholders.
4. **Steps** — Numbered or named steps with agent, skills, and action.

## Minimal Example

```markdown
# deploy-service

## Purpose

Deploy a service to a target environment.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SERVICE` | Name of the service | yes |
| `ENV` | Target environment | yes |

## Steps

### Step 1: Validate Configuration

- Agent: devops-engineer
- Skills: ci-cd, docker
- Action: Verify that {{SERVICE}} has a valid Dockerfile and CI pipeline for {{ENV}}.

### Step 2: Build Image

- Agent: devops-engineer
- Skills: docker
- Action: Build the container image for {{SERVICE}} tagged for {{ENV}}.

### Step 3: Deploy

- Agent: devops-engineer
- Skills: kubernetes
- Action: Deploy {{SERVICE}} to the {{ENV}} cluster and verify health checks.
```

## Parameter Substitution Syntax

Use `{{PARAM_NAME}}` anywhere in a step action.

```markdown
- Action: Implement {{API_NAME}} using {{FRAMEWORK}}.
```

### Rules

- Parameter names must be UPPER_SNAKE_CASE.
- Declare every parameter in the `## Parameters` table.
- Mark required parameters with `yes`.
- Optional parameters should have a default or be clearly optional in the action.

## Step Definitions

Each step should include:

| Field | Description |
|-------|-------------|
| `Agent` | The agent responsible for the step |
| `Skills` | Comma-separated list of relevant skills |
| `Action` | Detailed description of what to do |

### Example

```markdown
### Step 4: Security Audit

- Agent: security-engineer
- Skills: security-audit, penetration-testing
- Action: Audit {{TARGET}} for OWASP Top 10 issues within {{SCOPE}}.
```

## Workflow Engine Behavior

The workflow engine (`scripts/workflow-engine.ps1`) performs the following:

1. Parses the workflow Markdown.
2. Extracts declared parameters.
3. Prompts for missing required parameters.
4. Substitutes `{{PARAM}}` placeholders.
5. Executes each step in order, loading the specified agent and skills.
6. Reports unresolved placeholders after execution.

## Best Practices

- Keep steps focused and actionable.
- Use the most specific agent for each step.
- List only skills that are directly relevant.
- Order steps logically (design → implement → test → deploy).
- Include a final documentation or review step.

## Full Example: API Development

See `workflows/api-development.md` for a complete, production-ready workflow covering design, schema, implementation, auth, validation, testing, security, and documentation.
