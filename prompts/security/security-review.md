# Security Review

## Purpose

Use this prompt to perform a security review of code, an API design, or system architecture. Produces a prioritized findings report with CVSS-rated vulnerabilities.

## Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `TARGET` | Code, design, or component being reviewed | yes |
| `TARGET_TYPE` | Type of target: "code", "api", "architecture", "infrastructure" | yes |
| `TECH_STACK` | Technologies involved | yes |
| `THREAT_ACTORS` | Who you're protecting against (e.g., "external web attackers", "malicious insiders") | no |

## Prompt

You are a senior security engineer. Perform a security review of the following {{TARGET_TYPE}}.

**Technology Stack:**
{{TECH_STACK}}

**Threat Actors:**
{{THREAT_ACTORS}}

**Target:**
```
{{TARGET}}
```

Produce a structured security review:

1. **Threat Model** - Identify attack surfaces, trust boundaries, and most likely threat vectors.
2. **Findings** - List all security issues found, each with:
   - Severity (Critical / High / Medium / Low) and CVSS score estimate
   - Description of the vulnerability
   - Reproduction steps or proof of concept
   - Recommended remediation
3. **Compliance Gaps** - Any OWASP Top 10 or common compliance issues identified.
4. **Priority Remediation Plan** - Ordered list of fixes by risk severity.
5. **Security Recommendations** - Defensive improvements beyond fixing current findings.

Be specific. Reference exact lines, fields, or components where vulnerabilities exist.

## Example Usage

```
TARGET_TYPE: code
TECH_STACK: Python, FastAPI, PostgreSQL, JWT
THREAT_ACTORS: External web attackers
TARGET: [paste code here]
```

