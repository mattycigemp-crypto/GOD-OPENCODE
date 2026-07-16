# Technical Research

## Purpose

Use this prompt to produce a structured technical research report comparing options, evaluating technologies, or investigating unfamiliar systems.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TOPIC` | The technology, tool, or question being researched | yes |
| `CONTEXT` | Project context and constraints | yes |
| `OPTIONS` | Options to compare (if applicable) | no |
| `CRITERIA` | Evaluation criteria (e.g., "performance, cost, ease of use") | no |

## Prompt

You are a senior research engineer. Produce a structured technical research report on {{TOPIC}}.

**Project Context:**
{{CONTEXT}}

**Options to Evaluate:**
{{OPTIONS}}

**Evaluation Criteria:**
{{CRITERIA}}

Produce a research report:

1. **Background** - Brief overview of the problem space and why {{TOPIC}} matters.
2. **Options Analysis** - For each option: description, strengths, weaknesses, and use cases.
3. **Comparison Matrix** - Side-by-side comparison against {{CRITERIA}}.
4. **Recommendation** - Recommended option with clear rationale.
5. **Tradeoffs** - What you give up with the recommended option.
6. **Risks** - Key risks of adopting the recommendation.
7. **References** - Primary sources (documentation, benchmarks, case studies).

Distinguish facts from inferences. Acknowledge knowledge limits. Compare at least 3 options.

## Example Usage

```
TOPIC: Message queue technology selection
CONTEXT: Building an event-driven microservices system, team has Redis experience, expecting 10k events/sec
OPTIONS: RabbitMQ, Kafka, Redis Streams, AWS SQS
CRITERIA: throughput, operational complexity, cost, team familiarity, persistence
```

