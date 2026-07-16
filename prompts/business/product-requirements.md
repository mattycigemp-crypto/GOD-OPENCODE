# Product Requirements

## Purpose

Use this prompt to produce a structured Product Requirements Document (PRD) for a new feature or product.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `PRODUCT_NAME` | Name of the product or feature | yes |
| `PROBLEM` | The problem being solved | yes |
| `TARGET_USERS` | Who the product is for | yes |
| `CONSTRAINTS` | Technical, business, or time constraints | no |

## Prompt

You are a senior product engineer. Produce a Product Requirements Document for {{PRODUCT_NAME}}.

**Problem:**
{{PROBLEM}}

**Target Users:**
{{TARGET_USERS}}

**Constraints:**
{{CONSTRAINTS}}

Produce a structured PRD:

1. **Problem Statement** - Clear statement of the problem and who has it.
2. **Goals** - 3–5 measurable success criteria.
3. **Non-Goals** - Explicitly what this product does NOT do.
4. **User Stories** - 5–10 user stories in "As a [user], I want [action], so that [outcome]" format.
5. **Requirements** - Functional and non-functional requirements.
6. **Technical Considerations** - Key technical decisions, dependencies, and risks.
7. **Open Questions** - Unresolved questions that need answers before implementation.

## Example Usage

```
PRODUCT_NAME: Notification Center
PROBLEM: Users miss important system alerts because they are buried in email
TARGET_USERS: Engineering teams using a SaaS platform
CONSTRAINTS: Must work within existing React frontend, 4-week timeline
```

