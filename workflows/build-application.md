# build-application

## Purpose

Structured workflow for building a complete production application from scratch, including planning, architecture, frontend/backend implementation, and final review.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PROJECT_NAME` | Name of the application | yes |
| `TECH_STACK` | Languages, frameworks, and tools to use | yes |

## Steps

### Step 1: Requirements and Architecture
- Agent: principal-engineer
- Skills: system-design, architect, documentation
- Action: Analyze requirements for {{PROJECT_NAME}} and design the high-level architecture using {{TECH_STACK}}. Output an architectural decision record (ADR).

### Step 2: Backend Foundation
- Agent: backend-engineer
- Skills: api-design, database-design, testing
- Action: Scaffold the backend for {{PROJECT_NAME}}, including database schemas, API routes, and core business logic.

### Step 3: Frontend Foundation
- Agent: frontend-engineer
- Skills: react-expert, typescript-expert, performance
- Action: Scaffold the frontend for {{PROJECT_NAME}}, set up state management, routing, and component library based on {{TECH_STACK}}.

### Step 4: Integration
- Agent: principal-engineer
- Skills: system-design, code-review
- Action: Integrate frontend and backend components. Ensure API calls and data flow correctly between the layers.

### Step 5: Security Review
- Agent: security-engineer
- Skills: security-audit, secure-coding
- Action: Review {{PROJECT_NAME}} for vulnerabilities, check authentication implementation, and ensure data privacy.

### Step 6: Testing and Quality Assurance
- Agent: debugger
- Skills: debugger, bug-hunter, testing
- Action: Run unit and integration tests. Identify edge cases, fix bugs, and ensure the application is stable.
