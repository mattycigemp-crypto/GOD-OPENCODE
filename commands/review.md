# /review

## Purpose

Senior-level code review covering correctness, security, performance, maintainability, and test coverage.

## Steps

1. **Scope review** — Understand what is being reviewed: PR, module, file, or entire codebase.
   - Agent: principal-engineer
   - Skills: code-review, principal-engineer

2. **Correctness analysis** — Verify logic correctness, edge case handling, and error propagation.
   - Agent: principal-engineer
   - Skills: code-review, bug-hunter, testing

3. **Security review** — Scan for injection, auth issues, secrets exposure, and insecure patterns.
   - Agent: security-engineer
   - Skills: secure-coding, security-audit, authentication

4. **Performance review** — Identify inefficient algorithms, N+1 queries, missing indexes, and memory leaks.
   - Agent: principal-engineer
   - Skills: performance, database-design

5. **Maintainability review** — Assess naming, structure, coupling, duplication, and test coverage.
   - Agent: principal-engineer
   - Skills: code-review, refactor, documentation

6. **Dependency review** — Check for outdated, vulnerable, or unnecessary dependencies.
   - Agent: security-engineer
   - Skills: security-audit

7. **Feedback report** — Produce structured review feedback with severity ratings and actionable suggestions.
   - Agent: technical-writer
   - Skills: documentation, code-review

## Output

- Structured code review report with findings by category
- Severity ratings: Critical / High / Medium / Low / Suggestion
- Specific line-level feedback with recommended fixes
- Summary of overall code quality assessment
