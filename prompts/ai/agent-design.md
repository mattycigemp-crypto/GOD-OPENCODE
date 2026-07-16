# Agent Design

## Purpose

Use this prompt to design an AI agent with tool use, memory, and multi-step reasoning. Produces agent architecture, tool definitions, and system prompt.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `AGENT_NAME` | Name of the agent | yes |
| `GOAL` | What the agent is designed to accomplish | yes |
| `TOOLS` | External capabilities the agent should have | yes |
| `FRAMEWORK` | Agent framework (e.g., "LangGraph", "AutoGen", "custom") | no |
| `MEMORY_TYPE` | Memory approach (e.g., "none", "conversation", "vector store") | no |

## Prompt

You are a senior AI engineer. Design a production-quality AI agent.

**Agent Name:** {{AGENT_NAME}}
**Goal:** {{GOAL}}
**Available Tools:** {{TOOLS}}
**Framework:** {{FRAMEWORK}}
**Memory Type:** {{MEMORY_TYPE}}

Produce a complete agent design:

1. **Agent Architecture** - Component diagram: reasoning loop, tool registry, memory, output layer.
2. **System Prompt** - The complete system prompt that defines the agent's role, capabilities, and constraints.
3. **Tool Definitions** - For each tool: name, description, input schema, output schema, and error handling.
4. **Reasoning Loop** - How the agent decides when to call tools vs. respond directly.
5. **Memory Design** - How the agent stores and retrieves relevant context.
6. **Safety Guardrails** - Constraints to prevent the agent from taking harmful or unintended actions.
7. **Evaluation Plan** - How to test the agent's performance and detect regressions.

## Example Usage

```
AGENT_NAME: CodeReviewAgent
GOAL: Automatically review pull requests, identify bugs, and suggest improvements
TOOLS: GitHub API (read PR diff), code analysis tool, comment posting API
FRAMEWORK: LangGraph
MEMORY_TYPE: conversation history within PR session
```

