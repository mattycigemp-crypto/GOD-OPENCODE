---
name: workflow-engine
description: Execute step-by-step workflows from the workflows/ directory. Reads workflow markdown files, extracts steps, and guides execution. Use when you need to run a structured workflow like security-audit, api-design, performance-audit, etc.
---

# workflow-engine

## Mission

Load and execute structured workflows defined in markdown files. Each workflow has parameters, steps with assigned agents and skills, and clear actions.

## Core Responsibilities

- Read workflow markdown files from `workflows/`.
- Extract parameters and prompt for missing required values.
- Substitute `{{PARAM}}` placeholders in step actions.
- Execute steps sequentially with the correct agent and skills.
- Generate a summary report after workflow completion.

## Workflow

1. Load the requested workflow markdown file.
2. Parse the `## Parameters` table.
3. Collect required parameters from the user.
4. Substitute placeholders in each step action.
5. Execute steps sequentially, loading the assigned agent and skills per step.
6. Record findings and report progress.
7. Generate a final summary with key findings and next steps.

## Quality Standards

Always:

- Validate that the workflow file exists before executing.
- Ask for all required parameters before starting.
- Preserve context across steps.
- Report failures clearly without stopping the entire workflow.

Never:

- Skip steps without recording the reason.
- Substitute parameters incorrectly.
- Lose context when switching agents.

## When to Use

- User requests a structured process (security audit, API design, etc.)
- You need to follow a multi-step workflow
- auto-router detected a matching workflow
- User wants to run a specific workflow by name

## Available Workflows

| Workflow | File | Description |
|----------|------|-------------|
| security-audit | `workflows/security-audit.md` | Full security audit with threat modelling, code review, penetration testing |
| api-design | `workflows/api-design.md` | Design RESTful/GraphQL APIs with schemas and documentation |
| frontend-build | `workflows/frontend-build.md` | Build frontend applications with component architecture |
| database-design | `workflows/database-design.md` | Design database schemas, indexes, and data models |
| performance-audit | `workflows/performance-audit.md` | Analyze and optimize application performance |
| code-review | `workflows/code-review.md` | Systematic code review with quality checks |
| debug-session | `workflows/debug-session.md` | Structured debugging with root cause analysis |
| deploy-pipeline | `workflows/deploy-pipeline.md` | Set up CI/CD pipelines and deployment |
| refactor-session | `workflows/refactor-session.md` | Structured refactoring with quality gates |
| testing-strategy | `workflows/testing-strategy.md` | Create comprehensive testing strategies |

## How to Execute a Workflow

### Step 1: Load the Workflow

Read the workflow markdown file from `workflows/`:

```
Read the file: workflows/{workflow-name}.md
```

### Step 2: Extract Parameters

Parse the Parameters table from the workflow. Ask the user for required parameters they haven't provided.

Example from security-audit.md:
```
| Parameter | Description | Required |
|-----------|-------------|----------|
| TARGET    | Application being audited | yes |
| SCOPE     | Audit scope | yes |
| COMPLIANCE | Compliance frameworks | no |
```

### Step 3: Substitute Parameters

Replace `{{PARAM}}` placeholders in each step's action with actual values.

### Step 4: Execute Steps Sequentially

For each step in the workflow:

1. **Announce the step** — Show step number, name, and assigned agent
2. **Load relevant skills** — Use the `skill` tool to load skills listed in the step
3. **Execute the action** — Perform the work described in the step
4. **Record findings** — Save results before moving to next step
5. **Report progress** — Show completion status

### Step 5: Generate Summary

After all steps complete, generate a summary report with:
- Total steps completed
- Key findings per step
- Critical issues found
- Recommendations
- Next steps

## Workflow File Format

Each workflow markdown follows this structure:

```markdown
# workflow-name

## Purpose
Description of what this workflow does.

## Parameters
| Parameter | Description | Required |
|-----------|-------------|----------|
| PARAM     | Description | yes/no   |

## Steps

### Step 1: Step Name
- Agent: agent-name
- Skills: skill1, skill2
- Action: What to do with {{PARAM}} placeholders.

### Step 2: Step Name
- Agent: agent-name
- Skills: skill1, skill2
- Action: What to do.
```

## Example Execution

User: "Run security audit on my API"

1. Load `workflows/security-audit.md`
2. Ask: "What is the TARGET (application name) and SCOPE (e.g., 'API only', 'full-stack')?"
3. User provides: TARGET="my-api", SCOPE="API only"
4. Execute Step 1: Load security-audit + security + architect skills, perform threat modelling
5. Execute Step 2: Load authentication + secure-coding + cryptography skills, audit auth
6. Continue through all 8 steps
7. Generate summary report

## Progress Tracking

Track execution state:

```
WORKFLOW: security-audit
STATUS:   in_progress (5/8 steps)
CURRENT:  Step 5 - Infrastructure Review
FINDINGS: 3 critical, 7 high, 12 medium issues found so far
```

## Error Handling

If a step fails:
1. Record the error
2. Continue with next step if possible
3. Note failures in the summary
4. Suggest remediation

## Multi-Agent Workflows

Some steps require different agents. When switching agents:
1. Note the agent switch
2. Load the new agent's skills
3. Continue execution with the new agent's perspective
