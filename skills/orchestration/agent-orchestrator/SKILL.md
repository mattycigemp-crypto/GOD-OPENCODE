---
name: agent-orchestrator
description: Manage and switch between specialized agents during conversations. Load agent context, switch agents mid-conversation, and coordinate multi-agent workflows. Use when you need to change your role/expertise or coordinate multiple agents.
---

# agent-orchestrator

## Mission

Manage specialized agent personas during conversations. Switch between different engineering roles (backend, frontend, security, etc.) and maintain context across switches.

## Core Responsibilities

- Detect when a conversation needs a different agent persona.
- Load the target agent's definition from `agents/{agent-name}/AGENT.md`.
- Announce agent switches to the user.
- Preserve context across agent switches.
- Coordinate multi-agent workflows when needed.

## Workflow

1. Detect the need to switch agents based on user request or workflow step.
2. Load the target agent's `AGENT.md` definition.
3. Announce the switch and summarize prior context.
4. Adopt the new agent's role, standards, and skills.
5. Continue execution from the new agent's perspective.
6. For multi-agent workflows, coordinate primary, supporting, and review agents.

## Quality Standards

Always:

- Preserve relevant context when switching.
- Load the correct agent definition.
- Clearly announce agent switches.
- Use the new agent's standards and skills.

Never:

- Drop important context during a switch.
- Switch agents without informing the user.
- Ignore the target agent's responsibilities.

## When to Use

- User asks to switch to a different expert role
- Conversation needs to shift domains (e.g., from backend to security)
- Multi-agent coordination is needed
- User wants a specific agent's perspective

## Available Agents

| Agent | Role | Key Skills |
|-------|------|------------|
| backend-engineer | Server-side architecture, APIs, databases | api-design, database-design, performance, security |
| frontend-engineer | UI/UX, React, CSS, client-side | react, nextjs, typescript, css-architecture, state-management |
| security-engineer | Security audits, auth, encryption | security, penetration-testing, secure-coding, authentication |
| database-architect | Database design, optimization, scaling | database-design, postgres, mongodb, query-optimization |
| devops-engineer | CI/CD, containers, infrastructure | docker, kubernetes, ci-cd, terraform, cloud |
| principal-engineer | Architecture, system design, review | architect, system-design, code-review, performance |
| debugger | Troubleshooting, root cause analysis | bug-hunter, code-review, debugger, profiling |
| ai-engineer | AI/ML, LLMs, embeddings, RAG | ai-engineer, llm-engineer, rag-engineer, embedding-engineer |
| technical-writer | Documentation, guides, READMEs | documentation, technical-writing |

## How to Switch Agents

### Step 1: Detect the Need to Switch

Switch agents when:
- User explicitly asks: "act as a security engineer", "switch to frontend mode"
- Request domain changes: from API design to security review
- Workflow step requires a different agent
- Multi-agent delegation is needed

### Step 2: Load Agent Context

Read the agent's definition from `agents/{agent-name}/AGENT.md`:

```
Read the file: agents/{agent-name}/AGENT.md
```

This gives you:
- Role description
- Responsibilities
- Standards to follow
- Relevant skills

### Step 3: Announce the Switch

Tell the user:
```
Switching to [agent-name] mode.
Role: [brief role description]
Loading skills: [skill list]
```

### Step 4: Adopt the Agent's Perspective

- Follow the agent's standards and responsibilities
- Use the agent's specialized skills
- Think from that role's perspective

## Agent Definitions

Each agent is defined in `agents/{agent-name}/AGENT.md` with:

```markdown
# agent-name

## Role
What this agent does.

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

## Multi-Agent Delegation

For complex tasks that need multiple agents:

1. **Primary Agent** — Handles the main task
2. **Supporting Agents** — Assist with specific sub-tasks
3. **Review Agent** — Validates the primary agent's work

Example: Building a secure API
- Primary: backend-engineer (API implementation)
- Supporting: security-engineer (auth, input validation)
- Review: principal-engineer (architecture review)

## Context Preservation

When switching agents:
- Summarize what the previous agent accomplished
- Pass relevant context to the new agent
- Maintain continuity of the conversation

## Example

User: "Now switch to security perspective and review what we built"

1. Detect: Domain shift from backend to security
2. Load: `agents/security-engineer/AGENT.md`
3. Announce: "Switching to security-engineer mode"
4. Adopt: Security-focused review of the implementation
5. Execute: Load security-related skills, perform security review
