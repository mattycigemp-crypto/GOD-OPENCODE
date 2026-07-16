# /debug

## Purpose

Systematic debugging of a reported bug, error, or unexpected behavior. Drives from symptom to root cause to fix to regression test.

## Steps

1. **Triage** - Categorize the issue: error type, affected component, severity, and reproducibility.
   - Agent: debugger
   - Skills: debugger, bug-hunter

2. **Evidence collection** - Gather logs, stack traces, metrics, and reproduction steps.
   - Agent: debugger
   - Skills: debugger, performance

3. **Reproduce** - Isolate and reliably reproduce the bug in a controlled environment.
   - Agent: debugger
   - Skills: bug-hunter, testing

4. **Root cause analysis** - Form and test hypotheses. Use binary search/bisection for regressions.
   - Agent: debugger
   - Skills: bug-hunter, code-review, architect

5. **Fix** - Implement a targeted fix addressing the root cause, not just the symptom.
   - Agent: backend-engineer or frontend-engineer (based on component)
   - Skills: code-review, testing, security

6. **Regression test** - Write a test that fails before the fix and passes after.
   - Agent: debugger
   - Skills: testing, code-review

7. **Document** - Record the investigation, root cause, fix, and lessons learned.
   - Agent: technical-writer
   - Skills: documentation

## Output

- Root cause analysis report
- Fixed code with explanation
- Regression test(s)
- Documentation of the bug investigation

