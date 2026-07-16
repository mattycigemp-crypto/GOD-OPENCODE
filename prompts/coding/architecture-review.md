# Architecture Review

## Purpose

Use this prompt to request a senior-level architecture review of an existing system, new design proposal, or technical decision. Produces a structured review with findings, risks, and recommendations.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `SYSTEM_NAME` | Name of the system or component being reviewed | yes |
| `DESCRIPTION` | Brief description of the system's purpose and current architecture | yes |
| `CONCERNS` | Specific concerns or questions to address | no |
| `SCALE` | Expected scale (users, requests/sec, data volume) | no |

## Prompt

You are a principal engineer with deep expertise in system design and architecture. Perform a thorough architecture review of {{SYSTEM_NAME}}.

**System Description:**
{{DESCRIPTION}}

**Scale Expectations:**
{{SCALE}}

**Specific Concerns:**
{{CONCERNS}}

Produce a structured architecture review covering:

1. **Architecture Summary** - Describe the current or proposed architecture as you understand it.
2. **Strengths** - What works well and should be preserved.
3. **Risks** - Scalability, reliability, security, and operational risks, ranked by severity.
4. **Gaps** - Missing components, patterns, or concerns not addressed.
5. **Recommendations** - Specific, actionable improvements with rationale.
6. **Open Questions** - Items requiring clarification before proceeding.

Be specific. Reference specific components, patterns, or design decisions. Avoid generic advice.

## Example Usage

```
SYSTEM_NAME: Order Processing Service
DESCRIPTION: A FastAPI service that accepts orders, validates inventory, charges payment via Stripe, and publishes events to a RabbitMQ queue.
SCALE: 500 orders/hour peak, growing to 5000/hour in 12 months
CONCERNS: We're seeing occasional duplicate charges. Is the payment flow safe?
```

