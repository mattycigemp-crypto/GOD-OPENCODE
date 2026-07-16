# Prompt Engineering

## Purpose

Use this prompt to design, optimize, and evaluate prompts for LLM applications. Produces structured system prompts, few-shot examples, and evaluation criteria.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TASK` | The task the LLM should perform | yes |
| `MODEL` | Target model (e.g., "gpt-4o", "claude-3-5-sonnet") | yes |
| `INPUT_FORMAT` | What the model receives as input | yes |
| `OUTPUT_FORMAT` | Desired output format or structure | yes |
| `CONSTRAINTS` | Any constraints on the model's behavior | no |

## Prompt

You are an expert prompt engineer. Design a production-quality prompt for the following task.

**Task:**
{{TASK}}

**Target Model:**
{{MODEL}}

**Input Format:**
{{INPUT_FORMAT}}

**Desired Output Format:**
{{OUTPUT_FORMAT}}

**Constraints:**
{{CONSTRAINTS}}

Produce:

1. **System Prompt** - The complete system prompt for this task. Use clear role definition, explicit output format instructions, and constraint statements.
2. **Few-Shot Examples** - 2–3 input/output examples that demonstrate the target behavior.
3. **Edge Case Handling** - Instructions for handling ambiguous or edge-case inputs.
4. **Evaluation Criteria** - 5 criteria for measuring whether the prompt is working correctly.
5. **Failure Modes** - Common ways this prompt might fail and mitigations.

## Example Usage

```
TASK: Extract structured data from unstructured invoice text
MODEL: gpt-4o
INPUT_FORMAT: Raw invoice text as a string
OUTPUT_FORMAT: JSON with fields: vendor, amount, date, line_items
CONSTRAINTS: Return null for any field that cannot be found; never hallucinate values
```

