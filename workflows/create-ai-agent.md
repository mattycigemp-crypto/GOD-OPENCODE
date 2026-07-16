# create-ai-agent

## Purpose

Design and build a production AI agent with tool use, memory, structured reasoning, and an evaluation harness.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `AGENT_NAME` | Name of the agent being built | yes |
| `GOAL` | What the agent is designed to accomplish | yes |
| `FRAMEWORK` | Agent framework (e.g., LangGraph, AutoGen, custom) | yes |
| `TOOLS` | Comma-separated list of tools the agent should have | no |

## Steps

### Step 1: Requirements and Scope
- Agent: ai-engineer
- Skills: ai-engineer, prompt-engineer
- Action: Define the scope of {{AGENT_NAME}}. Clarify {{GOAL}}, identify required tools, memory strategy, output format, and safety constraints.

### Step 2: Agent Architecture Design
- Agent: ai-engineer
- Skills: agent-builder, workflow-designer, architect
- Action: Design the {{AGENT_NAME}} architecture using {{FRAMEWORK}}. Define the reasoning loop, tool registry, memory system, and state schema.

### Step 3: System Prompt Engineering
- Agent: ai-engineer
- Skills: prompt-engineer, llm-engineer
- Action: Write the system prompt for {{AGENT_NAME}}. Define role, capabilities, output format, and behavioral guardrails. Test against adversarial inputs.

### Step 4: Tool Implementation
- Agent: ai-engineer
- Skills: tool-builder, mcp-builder, api-design
- Action: Implement each tool in {{TOOLS}}. Define input schemas, output formats, error handling, and timeout behavior.

### Step 5: Memory and State Implementation
- Agent: ai-engineer
- Skills: agent-builder, rag-engineer, embedding-engineer
- Action: Implement the memory system for {{AGENT_NAME}}. Wire up conversation history, vector store retrieval, or external memory as appropriate.

### Step 6: Integration and Testing
- Agent: ai-engineer
- Skills: evaluation-engineer, testing
- Action: Integrate all components. Run the agent against a test case suite. Measure tool call accuracy, response quality, and latency.

### Step 7: Evaluation Harness
- Agent: ai-engineer
- Skills: evaluation-engineer
- Action: Build an eval harness for {{AGENT_NAME}} with a golden dataset, evaluation metrics, and a regression runner to catch future degradations.
