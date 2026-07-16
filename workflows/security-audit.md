# security-audit

## Purpose

Comprehensive security audit workflow covering code review, dependency scanning, infrastructure review, and threat modelling for an existing application.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Application or component being audited | yes |
| `SCOPE` | Audit scope (e.g., "full-stack", "API only", "infrastructure") | yes |
| `COMPLIANCE` | Compliance frameworks to assess against (e.g., "OWASP", "SOC2", "PCI") | no |

## Steps

### Step 1: Threat Modelling
- Agent: security-engineer
- Skills: security-audit, security, architect
- Action: Build a threat model for {{TARGET}} within {{SCOPE}}. Identify trust boundaries, attack surfaces, threat actors, and high-risk scenarios using STRIDE methodology.

### Step 2: Authentication and Authorization Review
- Agent: security-engineer
- Skills: authentication, secure-coding, cryptography
- Action: Audit the authentication and authorization implementation of {{TARGET}}. Check token handling, session management, password storage, privilege escalation paths, and RBAC correctness.

### Step 3: Code Security Review
- Agent: security-engineer
- Skills: secure-coding, code-review, penetration-testing
- Action: Review source code for injection vulnerabilities (SQLi, XSS, command injection), insecure deserialization, path traversal, hardcoded secrets, and unsafe dependencies.

### Step 4: Dependency Audit
- Agent: security-engineer
- Skills: security-audit, devops
- Action: Scan all dependencies in {{TARGET}} for known CVEs. Flag critical/high severity vulnerabilities and provide upgrade or mitigation recommendations.

### Step 5: Infrastructure and Configuration Review
- Agent: devops-engineer
- Skills: docker, kubernetes, linux, networking, ci-cd
- Action: Review infrastructure configuration for {{TARGET}}: exposed ports, network policies, secrets management, container security, IAM policies, and TLS configuration.

### Step 6: Data Security Review
- Agent: security-engineer
- Skills: cryptography, database-design, secure-coding
- Action: Audit how {{TARGET}} handles sensitive data: encryption at rest/transit, PII exposure in logs, data retention policies, and backup security.

### Step 7: Penetration Testing
- Agent: security-engineer
- Skills: penetration-testing, security-audit
- Action: Perform targeted penetration testing against {{TARGET}} within {{SCOPE}}. Test identified attack vectors, attempt privilege escalation, and validate exploitability of findings.

### Step 8: Findings Report
- Agent: technical-writer
- Skills: documentation, security-audit
- Action: Produce a structured security findings report for {{TARGET}}: executive summary, findings ranked by severity (CVSS), reproduction steps, and remediation recommendations.
