# build-project

## Purpose

Alias for build-application. Use this workflow for any full-stack or single-tier project build. See build-application.md for the complete parameterized workflow.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PROJECT_NAME` | Name of the project | yes |
| `STACK` | Technology stack | yes |
| `DESCRIPTION` | Project description | yes |

## Steps

### Step 1: Requirements
- Agent: principal-engineer
- Skills: architect, principal-engineer
- Action: Capture and validate requirements for {{PROJECT_NAME}} using {{STACK}}.

### Step 2: Architecture
- Agent: principal-engineer
- Skills: system-design, architect
- Action: Design system architecture for {{PROJECT_NAME}} given {{DESCRIPTION}}.

### Step 3: Implementation
- Agent: backend-engineer
- Skills: api-design, database-design, testing
- Action: Implement the core of {{PROJECT_NAME}} following the designed architecture.

### Step 4: Testing and Review
- Agent: principal-engineer
- Skills: code-review, testing, security
- Action: Review and test {{PROJECT_NAME}} for correctness, security, and quality.

### Step 5: Documentation
- Agent: technical-writer
- Skills: documentation
- Action: Document {{PROJECT_NAME}} with README, setup guide, and API reference.
