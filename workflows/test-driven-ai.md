# Test-Driven AI Development

## Purpose

Implement features using AI with automatic test generation, execution, and failure remediation. The agent writes code, tests it, fixes failures, and only presents the result when all tests pass.

## Parameters

- `feature`: Description of the feature to implement
- `language`: Target language (python, javascript, typescript, go, rust)
- `framework`: Test framework (pytest, jest, vitest, go test, cargo test)
- `max_retries`: Maximum fix attempts (default: 3)

## Steps

### Step 1: Requirements Analysis
- Agent: principal-engineer
- Skills: architect, code-generation
- Parse the feature description into testable requirements
- Identify edge cases and error scenarios
- Create a test plan document

### Step 2: Test Generation
- Agent: backend-engineer
- Skills: unit-testing, code-generation
- Generate comprehensive test suite covering:
  - Happy path scenarios
  - Edge cases
  - Error handling
  - Boundary conditions
- Save tests to appropriate test directory

### Step 3: Implementation
- Agent: backend-engineer (or frontend-engineer)
- Skills: code-generation, language-specific skill
- Write minimal code to pass all tests
- Follow existing code patterns and conventions
- No premature optimization

### Step 4: Test Execution
- Agent: debugger
- Skills: testing, code-generation
- Run the test suite
- Capture output and failure details
- If all tests pass, proceed to Step 7

### Step 5: Failure Analysis
- Agent: debugger
- Skills: debugger, code-generation
- Analyze each failing test
- Determine root cause:
  - Implementation bug
  - Test bug
  - Missing requirement
  - Environmental issue
- Document findings

### Step 6: Fix and Retry
- Agent: backend-engineer
- Skills: code-generation, debugger
- Fix identified issues
- Re-run tests
- Repeat Steps 4-6 up to max_retries times
- If still failing after max_retries, escalate to human

### Step 7: Validation
- Agent: principal-engineer
- Skills: code-review, testing
- Review implementation against requirements
- Verify test coverage is adequate
- Check for code quality issues
- Generate summary report

## Quality Standards

Always:
- Write tests before implementation
- Run tests after every change
- Fix failures before adding features
- Document test results
- Verify edge cases

Never:
- Skip test execution
- Ignore failing tests
- Merge with broken tests
- Hardcode test data
