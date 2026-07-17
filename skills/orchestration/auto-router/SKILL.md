---
name: auto-router
description: Intelligent intent detection and agent/skill routing. Analyzes user requests to determine the best agent, skills, and workflows to use. Use when you need to route a request, decide which agent to use, or determine which skills apply.
---

# auto-router

## Mission

Analyze user requests and determine the optimal routing: which agent should handle it, which skills to load, and whether a workflow matches.

## Core Responsibilities

- Analyze user requests for intent and domain.
- Score intent categories based on keyword overlap.
- Select the primary agent and supporting agents.
- Identify matching workflows and required skills.
- Output a clear routing summary.

## Workflow

1. Receive the user's request.
2. Score each intent category by keyword overlap.
3. Select the winning intent and primary agent.
4. Check for matching workflow triggers.
5. Load relevant skills from the primary agent's skill set.
6. Output the routing summary with intent, agent, skills, and workflow.

## Quality Standards

Always:

- Use keyword overlap to score intents objectively.
- Apply tie-breaking rules when intents are tied.
- Include confidence level in the routing output.
- Reference the agent's actual skill list.

Never:

- Guess intent without keyword evidence.
- Ignore explicit workflow trigger phrases.
- Route to an agent without loading relevant skills.

## When to Use

- User asks a complex question that could involve multiple domains
- You need to decide which agent or skills to load
- User wants to know the best approach for a task
- You need to detect if a request triggers a known workflow

## Intent Detection

Match the user's request against these intent categories. Pick the one with the highest keyword overlap.

### Intent Categories

| Intent | Keywords | Primary Agent | Supporting Agents |
|--------|----------|---------------|-------------------|
| **build** | create, build, implement, develop, scaffold, generate, setup, add feature, new project | backend-engineer, frontend-engineer | principal-engineer, testing |
| **debug** | debug, fix, error, bug, issue, troubleshoot, broken, failing, crash, exception | debugger | backend-engineer, frontend-engineer |
| **review** | review, audit, check, analyze, assess, evaluate, inspect, examine | principal-engineer, code-review | security-engineer, performance |
| **secure** | security, auth, authentication, authorization, encrypt, vulnerability, OWASP, penetration | security-engineer | backend-engineer, devops-engineer |
| **optimize** | optimize, performance, speed, slow, fast, cache, profiling, bottleneck, memory | principal-engineer, performance | backend-engineer, devops-engineer |
| **refactor** | refactor, restructure, clean, improve, simplify, technical debt, code quality | principal-engineer | backend-engineer, frontend-engineer |
| **design** | design, architecture, system design, plan, blueprint, schema, data model | architect, principal-engineer | backend-engineer, database-architect |
| **test** | test, testing, unit test, integration test, e2e, coverage, tdd, test driven | testing, test-driven-development | debugger, backend-engineer |
| **deploy** | deploy, deployment, CI/CD, pipeline, release, ship, publish, containerize | devops-engineer | backend-engineer, security-engineer |
| **api** | api, endpoint, REST, GraphQL, gRPC, route, request, response | backend-engineer | api-design, security-engineer |
| **ai** | AI, LLM, model, embedding, vector, RAG, fine-tune, training, inference | ai-engineer, llm-engineer | python-expert, rag-engineer |
| **frontend** | UI, frontend, component, react, nextjs, css, layout, responsive, SPA | frontend-engineer | react, nextjs, css-architecture |
| **database** | database, SQL, postgres, mongo, schema, query, migration, index | database-architect | backend-engineer, query-optimization |
| **document** | documentation, docs, README, comment, explain, document | documentation | principal-engineer |
| **research** | research, compare, evaluate, recommend, investigate, explore | principal-engineer | architect |

### Scoring

For each intent category, count how many of its keywords appear in the user's request. The intent with the highest count wins. If tied, prefer: build > debug > secure > optimize > review > design.

## Workflow Detection

After determining intent, check if the request matches a known workflow trigger:

| Workflow | Trigger Phrases |
|----------|-----------------|
| security-audit | "security audit", "security review", "audit the security", "check for vulnerabilities" |
| api-design | "design an api", "api design", "plan the api", "api architecture" |
| frontend-build | "build the ui", "frontend build", "create the interface", "build the frontend" |
| database-design | "design the database", "database schema", "data model", "schema design" |
| performance-audit | "performance audit", "performance review", "optimize performance", "find bottlenecks" |
| code-review | "code review", "review the code", "review my code", "check the code quality" |
| debug-session | "debug the issue", "fix the bug", "troubleshoot", "investigate the error" |
| deploy-pipeline | "set up ci", "create pipeline", "deployment pipeline", "ci/cd setup" |
| refactor-session | "refactor the code", "clean up the code", "improve code quality" |
| testing-strategy | "testing strategy", "test plan", "set up testing", "testing approach" |

If a workflow matches, note it in the routing output.

## Agent Skills Reference

When routing, include relevant skills from the primary agent's skill set:

| Agent | Skills |
|-------|--------|
| backend-engineer | api-design, code-review, backend-engineer, database-design, performance, security, testing, documentation |
| frontend-engineer | react, nextjs, typescript, css-architecture, state-management, testing-frontend, web-performance, component-design |
| security-engineer | security, penetration-testing, secure-coding, security-audit, authentication, cryptography, cloud, networking |
| database-architect | database-design, postgres, mongodb, sqlite, query-optimization, schema-design, redis, replication, sharding |
| devops-engineer | docker, kubernetes, ci-cd, terraform, cloud, linux, networking, github-actions |
| principal-engineer | architect, code-review, system-design, performance, algorithm-expert, security, distributed-systems |
| debugger | bug-hunter, code-review, debugger, profiling, testing, secure-coding, linux, logging |
| ai-engineer | ai-engineer, llm-engineer, rag-engineer, embedding-engineer, python-expert, evaluation-engineer |

## Output Format

After analysis, output a routing summary:

```
ROUTING RESULT
==============
Intent:       [detected intent] (confidence: [high/medium/low])
Primary Agent: [agent name]
Skills:       [comma-separated skill names]
Workflow:     [workflow name or "none"]
Agents:       [list of agents if multi-agent needed]
```

## Example

User: "security audit the authentication flow"

```
ROUTING RESULT
==============
Intent:       secure (confidence: high)
Primary Agent: security-engineer
Skills:       security, penetration-testing, secure-coding, security-audit, authentication, cryptography
Workflow:     security-audit
Agents:       security-engineer, devops-engineer
```
