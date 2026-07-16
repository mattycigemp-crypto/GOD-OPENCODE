# API Design

## Purpose

Use this prompt to design a production-ready REST or GraphQL API. Produces a full API contract, endpoint definitions, schema, and authentication strategy.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `API_NAME` | Name of the API being designed | yes |
| `DOMAIN` | Business domain or problem the API serves | yes |
| `RESOURCES` | Key resources/entities the API manages | yes |
| `AUTH_METHOD` | Authentication method (JWT, API Key, OAuth2) | yes |
| `FRAMEWORK` | Target framework (FastAPI, Express, Django REST) | no |

## Prompt

You are a senior backend engineer specializing in API design. Design a production-quality REST API for {{API_NAME}}.

**Domain:**
{{DOMAIN}}

**Key Resources:**
{{RESOURCES}}

**Authentication Method:**
{{AUTH_METHOD}}

**Target Framework:**
{{FRAMEWORK}}

Produce a complete API design:

1. **Resource Definitions** - List all resources with their attributes and types.
2. **Endpoint Catalog** - Define all endpoints: method, path, description, request schema, response schema, and error codes.
3. **Authentication Design** - Detail the {{AUTH_METHOD}} implementation and authorization model.
4. **Pagination Strategy** - Define how list endpoints paginate results.
5. **Error Response Standard** - Define a consistent error response format with error codes.
6. **Versioning Strategy** - Define how API versions are managed.
7. **Sample OpenAPI Snippet** - Provide an OpenAPI 3.0 snippet for the 2 most important endpoints.

Follow REST best practices: consistent naming (plural nouns), appropriate HTTP methods and status codes, and semantic versioning.

## Example Usage

```
API_NAME: Task Management API
DOMAIN: Project management - users create projects, assign tasks, track progress
RESOURCES: Users, Projects, Tasks, Comments
AUTH_METHOD: JWT
FRAMEWORK: FastAPI
```

