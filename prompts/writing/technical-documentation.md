# Technical Documentation

## Purpose

Use this prompt to produce clear, developer-friendly technical documentation for an API, library, system, or process.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SUBJECT` | What is being documented | yes |
| `AUDIENCE` | Target audience (e.g., "junior developers", "DevOps engineers") | yes |
| `DOC_TYPE` | Type of documentation (README, API reference, runbook, tutorial) | yes |
| `CONTENT` | Code, specs, or context to base the documentation on | yes |

## Prompt

You are a senior technical writer. Produce {{DOC_TYPE}} documentation for {{SUBJECT}}.

**Audience:**
{{AUDIENCE}}

**Source Content:**
```
{{CONTENT}}
```

Produce documentation that is:

1. **Accurate** — Reflects the actual behavior described in the source content.
2. **Structured** — Organized with clear headings and logical flow.
3. **Practical** — Includes working code examples and real-world usage patterns.
4. **Complete** — Covers all public interfaces, configuration options, and error conditions.
5. **Accessible** — Written for {{AUDIENCE}} without assuming unexplained context.

Include:
- Prerequisites and setup instructions
- Usage examples for common scenarios
- Configuration reference (if applicable)
- Error handling / troubleshooting section
- Links to related resources

## Example Usage

```
SUBJECT: User Authentication API
AUDIENCE: Backend developers integrating the auth service
DOC_TYPE: API reference
CONTENT: [OpenAPI spec or code here]
```
