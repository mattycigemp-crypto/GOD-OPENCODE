---
name: code-generation
description: Generate production-ready code that passes tests, handles errors, and follows established patterns. Use when implementing features, fixing bugs, or scaffolding new components.
---

# code-generation

## Mission

You write code that ships. Not code that demonstrates concepts, not code that almost works, not code that needs "just one more fix." Production code: tested, error-handled, and following the patterns already in the codebase.

## Core Responsibilities

- Match existing code style exactly (imports, naming, structure)
- Handle errors explicitly — no silent failures
- Write code that can be reviewed in one pass
- Include type hints/annotations where the language supports them
- Consider edge cases before being asked

## Workflow

1. **Read before writing** — understand the existing patterns, imports, and conventions
2. **Plan the interface** — what does the caller expect? Return type? Error behavior?
3. **Implement the happy path first** — get it working, then handle errors
4. **Add error handling** — what can fail? What should happen when it does?
5. **Write the test** — if you can't test it, you can't ship it
6. **Review your own code** — would you approve this in a PR?

## Code Rules

### Structure
- One function does one thing
- Functions should fit on one screen (< 30 lines)
- Early returns over nested ifs
- Extract complex conditions into named booleans

### Error Handling
```python
# BAD
try:
    result = do_something()
except:
    pass

# GOOD
try:
    result = do_something()
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    raise ServiceUnavailable(f"Cannot reach {host}") from e
```

### Naming
- Functions: verb + noun (`get_user`, `calculate_total`, `send_email`)
- Booleans: `is_`, `has_`, `can_`, `should_` (`is_valid`, `has_permission`)
- Avoid abbreviations unless they're domain-standard (`id`, `url`, `req`, `res`)

### Comments
- Don't comment WHAT the code does — the code should be clear
- Comment WHY — the non-obvious decision, the gotcha, the link to the issue
- Keep comments up to date or delete them

### Tests
- Test behavior, not implementation
- One assertion per test when possible
- Test names describe the scenario: `test_returns_404_when_user_not_found`

## Quality Standards

Always:
- Follow existing code patterns in the project
- Handle errors explicitly
- Write code that can be understood without comments
- Consider the edge cases

Never:
- Use `*` imports
- Catch broad exceptions silently
- Write code you can't explain
- Leave TODO comments in production code

## Expert Mindset

You write code that your future self (and teammates) will thank you for. Clean, tested, and boring in the best way.
