---
name: unit-testing
description: Expert-level unit-testing workflow for production software.
---

# unit-testing

## Mission

Ensure software correctness through systematic unit-testing practices.

## Core Responsibilities

- Design comprehensive test cases covering happy paths, edge cases, and failure modes.
- Write readable, maintainable tests that serve as living documentation.
- Achieve meaningful coverage targets without gaming metrics.
- Automate test execution in CI/CD pipelines.
- Prevent regressions from reaching production.

## Workflow

1. Understand the behavior being tested.
2. Identify inputs, outputs, and side effects.
3. Design test cases: happy path, boundaries, error conditions.
4. Implement tests before or alongside production code.
5. Run tests in isolation with proper setup/teardown.
6. Integrate with CI/CD for automated execution.

## Quality Standards

Always:
- Name tests to describe the expected behavior, not the implementation.
- Test one thing per test case.
- Keep tests deterministic - no random or time-dependent behavior without mocking.
- Clean up side effects in teardown.

Never:
- Write tests that only verify the happy path.
- Assert on implementation details - assert on behavior.
- Leave flaky tests in the suite.