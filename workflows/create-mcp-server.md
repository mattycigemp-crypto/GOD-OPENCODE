# create-mcp-server

## Purpose

Design and implement a production Model Context Protocol (MCP) server that exposes tools and resources to AI assistants.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SERVER_NAME` | Name of the MCP server | yes |
| `TOOLS` | Tools to expose (comma-separated) | yes |
| `LANGUAGE` | Implementation language (Python, TypeScript) | yes |
| `TRANSPORT` | Transport type (stdio, HTTP/SSE) | no |

## Steps

### Step 1: Design Tool Contracts
- Agent: ai-engineer
- Skills: mcp-builder, api-design, tool-builder
- Action: Design the tool contracts for {{SERVER_NAME}}. Define tool names, descriptions, input schemas (JSON Schema), output formats, and error responses for each tool in {{TOOLS}}.

### Step 2: Server Scaffold
- Agent: ai-engineer
- Skills: mcp-builder, fastapi, express
- Action: Scaffold the {{SERVER_NAME}} MCP server using the MCP SDK for {{LANGUAGE}}. Set up the server entry point, tool registry, and {{TRANSPORT}} transport.

### Step 3: Tool Implementation
- Agent: backend-engineer
- Skills: tool-builder, api-design, testing
- Action: Implement each tool in {{TOOLS}}. Add input validation, error handling, timeouts, and logging. Each tool should be independently testable.

### Step 4: Security Hardening
- Agent: security-engineer
- Skills: secure-coding, authentication
- Action: Audit {{SERVER_NAME}} for input injection, resource exhaustion, and unauthorized capability exposure. Add rate limiting and input sanitization.

### Step 5: Testing
- Agent: backend-engineer
- Skills: testing, mcp-builder
- Action: Write unit tests for all tools in {{SERVER_NAME}}. Test happy paths, invalid inputs, and timeout/error conditions.

### Step 6: Documentation
- Agent: technical-writer
- Skills: documentation, api-design
- Action: Document {{SERVER_NAME}}: installation guide, tool reference, configuration options, and integration examples for OpenCode and Claude.
