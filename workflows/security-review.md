# security-review

## Purpose

Focused security review of a specific code component, API endpoint, or design decision. Faster than a full security audit — targeted at a specific concern.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Code, endpoint, or design being reviewed | yes |
| `CONCERN` | Specific security concern (e.g., "SQL injection", "auth bypass") | yes |
| `TECH_STACK` | Technologies involved | yes |

## Steps

### Step 1: Threat Analysis
- Agent: security-engineer
- Skills: security-audit, architect
- Action: Identify the attack vectors relevant to {{CONCERN}} in {{TARGET}} using {{TECH_STACK}}.

### Step 2: Code Security Scan
- Agent: security-engineer
- Skills: secure-coding, penetration-testing, code-review
- Action: Audit {{TARGET}} specifically for {{CONCERN}}. Check input validation, output encoding, access controls, and data handling.

### Step 3: Exploit Validation
- Agent: security-engineer
- Skills: penetration-testing, security-audit
- Action: Attempt to exploit the identified vulnerability in {{TARGET}} to confirm exploitability and assess severity.

### Step 4: Remediation Guidance
- Agent: security-engineer
- Skills: secure-coding, authentication, cryptography
- Action: Provide specific remediation code and recommendations for {{TARGET}} addressing {{CONCERN}}.

### Step 5: Verification
- Agent: security-engineer
- Skills: testing, security-audit
- Action: Write a security test that verifies {{CONCERN}} is remediated in {{TARGET}} and cannot regress.
