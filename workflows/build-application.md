# build-application

## Purpose

End-to-end workflow for building a full-stack application from requirements through deployment and documentation. Covers architecture, database design, backend and frontend implementation, security, testing, and release.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PROJECT_NAME` | Name of the application being built | yes |
| `STACK` | Technology stack (e.g., "FastAPI + React", "Express + Next.js") | yes |
| `DESCRIPTION` | Brief description of the application and its goals | yes |
| `DEPLOY_TARGET` | Deployment target (e.g., "Docker", "Kubernetes", "Azure App Service") | yes |

## Steps

### Step 1: Requirements Analysis
- Agent: principal-engineer
- Skills: architect, documentation, research
- Action: Clarify requirements for {{PROJECT_NAME}} - {{DESCRIPTION}}. Define user stories, acceptance criteria, non-functional requirements, and success metrics.

### Step 2: Architecture Design
- Agent: principal-engineer
- Skills: architect, system-design, api-design
- Action: Design the system architecture for {{PROJECT_NAME}} using {{STACK}}. Define component boundaries, data flow, integration points, and deployment topology for {{DEPLOY_TARGET}}.

### Step 3: Database Design
- Agent: database-architect
- Skills: database-design, postgres, mongodb
- Action: Design the data model for {{PROJECT_NAME}}. Define schemas, indexes, relationships, migrations, and data access patterns.

### Step 4: Backend Implementation
- Agent: backend-engineer
- Skills: fastapi, express, django, graphql, testing
- Action: Implement the backend services for {{PROJECT_NAME}} using {{STACK}}. Build APIs, business logic, persistence layer, and error handling.

### Step 5: Frontend Implementation
- Agent: frontend-engineer
- Skills: react, nextjs, vue, typescript, css
- Action: Build the user interface for {{PROJECT_NAME}}. Implement pages, components, state management, and API integration against the backend.

### Step 6: Security Hardening
- Agent: security-engineer
- Skills: security-audit, authentication, secure-coding
- Action: Review and harden {{PROJECT_NAME}} for OWASP Top 10 risks. Implement authentication, authorization, input validation, and secrets management.

### Step 7: Testing
- Agent: backend-engineer
- Skills: testing, e2e-testing, integration-testing
- Action: Write unit, integration, and end-to-end tests for {{PROJECT_NAME}}. Verify critical user flows, API contracts, and regression coverage.

### Step 8: Deployment
- Agent: devops-engineer
- Skills: docker, kubernetes, ci-cd, linux
- Action: Prepare {{PROJECT_NAME}} for deployment to {{DEPLOY_TARGET}}. Configure containers, CI/CD pipelines, environment variables, and health checks.

### Step 9: Documentation
- Agent: technical-writer
- Skills: documentation, api-design
- Action: Produce project documentation for {{PROJECT_NAME}}: setup guide, architecture overview, API reference, and runbook for {{DEPLOY_TARGET}} deployment.

