# api-development

## Purpose

Structured workflow for designing and implementing a production-quality API from scratch or evolving an existing one. Covers design, implementation, security, testing, and documentation.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `API_NAME` | Name of the API being built | yes |
| `FRAMEWORK` | Backend framework (e.g., "FastAPI", "Express", "Django REST") | yes |
| `AUTH_METHOD` | Authentication method (e.g., "JWT", "API Key", "OAuth2") | yes |
| `DATABASE` | Database technology (e.g., "PostgreSQL", "MongoDB") | no |

## Steps

### Step 1: API Design
- Agent: backend-engineer
- Skills: api-design, documentation
- Action: Design the API contract for {{API_NAME}}. Define resources, endpoints, HTTP methods, request/response schemas, error codes, pagination, and versioning strategy. Produce an OpenAPI spec.

### Step 2: Database Schema
- Agent: database-architect
- Skills: database-design, postgres, mongodb
- Action: Design the data model supporting {{API_NAME}}. Define tables/collections, indexes, relationships, and migration plan.

### Step 3: Implementation
- Agent: backend-engineer
- Skills: fastapi, express, django, graphql, testing
- Action: Implement {{API_NAME}} using {{FRAMEWORK}}. Build route handlers, service layer, data access layer, and middleware.

### Step 4: Authentication and Authorization
- Agent: security-engineer
- Skills: authentication, secure-coding, cryptography
- Action: Implement {{AUTH_METHOD}} authentication for {{API_NAME}}. Add role-based authorization, token validation, rate limiting, and session management.

### Step 5: Input Validation and Error Handling
- Agent: backend-engineer
- Skills: api-design, secure-coding, testing
- Action: Add comprehensive input validation schemas, sanitization, consistent error response format, and global exception handling.

### Step 6: Testing
- Agent: backend-engineer
- Skills: testing, code-review
- Action: Write unit tests for service logic, integration tests for all endpoints, and contract tests. Verify auth flows, edge cases, and error conditions.

### Step 7: Security Audit
- Agent: security-engineer
- Skills: security-audit, penetration-testing
- Action: Audit {{API_NAME}} for OWASP API Security Top 10 vulnerabilities. Test for injection, broken auth, excessive data exposure, and rate limiting gaps.

### Step 8: Documentation
- Agent: technical-writer
- Skills: documentation, api-design
- Action: Produce API reference documentation for {{API_NAME}}: endpoint descriptions, request/response examples, authentication guide, and error code reference.
