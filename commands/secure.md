# /secure

## Purpose

Full security audit of an application, API, or infrastructure component. Produces a prioritized findings report with remediation guidance.

## Steps

1. **Threat modelling** - Identify attack surfaces, trust boundaries, and threat actors for the target.
   - Agent: security-engineer
   - Skills: security-audit, architect

2. **Authentication and authorization audit** - Review token handling, session management, RBAC, and privilege escalation paths.
   - Agent: security-engineer
   - Skills: authentication, secure-coding, cryptography

3. **Code security scan** - Check for injection vulnerabilities, insecure deserialization, path traversal, and hardcoded secrets.
   - Agent: security-engineer
   - Skills: secure-coding, penetration-testing, code-review

4. **Dependency vulnerability scan** - Audit all dependencies for known CVEs.
   - Agent: security-engineer
   - Skills: security-audit

5. **Infrastructure review** - Review container security, network policies, secrets management, and TLS configuration.
   - Agent: devops-engineer
   - Skills: docker, kubernetes, linux, networking

6. **Data security review** - Audit encryption at rest/transit, PII handling, and logging practices.
   - Agent: security-engineer
   - Skills: cryptography, database-design

7. **Penetration testing** - Attempt to exploit identified vulnerabilities to confirm exploitability.
   - Agent: security-engineer
   - Skills: penetration-testing, security-audit

8. **Findings report** - Produce a security report with CVSS-ranked findings, reproduction steps, and remediation.
   - Agent: technical-writer
   - Skills: documentation, security-audit

## Output

- Security findings report with CVSS severity ratings
- Threat model diagram
- Prioritized remediation plan
- Dependency vulnerability list with upgrade guidance

