# Security Policy

## Supply-Chain Security for Skills

GOD-OPENCODE includes a built-in **Skill Security Auditor** (`scripts/audit-skills.ps1`) that scans all `SKILL.md` files for malicious patterns before installation or distribution. Skills are the new npm — supply-chain security matters.

## Reporting Vulnerabilities

If you discover a security vulnerability in a GOD-OPENCODE skill:

1. **Do NOT open a public issue** for security vulnerabilities
2. **GitHub:** Use [Private Vulnerability Reporting](https://github.com/mattycigemp-crypto/GOD-OPENCODE/settings/security) (Settings → Security → "Private vulnerability reporting")
3. **Include:** Skill name, path, the malicious pattern, and severity assessment
4. **Response time:** We aim to acknowledge within 48 hours

## Skill Security Auditor

Run the auditor at any time:

```powershell
.\scripts\audit-skills.ps1                    # audit all skills
.\scripts\audit-skills.ps1 -Skill backend/fastapi  # audit specific skill
.\scripts\audit-skills.ps1 -Severity High          # filter by severity
.\scripts\audit-skills.ps1 -Report report.json     # export JSON report
```

### Detection Patterns (44 rules across 5 categories)

#### 1. Command Injection (11 patterns)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `eval()` call | Critical | Dynamic code evaluation |
| `exec()` call | Critical | Code execution |
| `subprocess.call/run/Popen` | High | Python subprocess execution |
| `os.system()` call | Critical | OS command execution |
| `os.popen()` call | Critical | OS command execution |
| `__import__()` | High | Dynamic module import |
| `compile+exec` | Critical | Compile then execute |
| Node `child_process` | High | Node.js child process |
| `spawn()` call | High | Process spawning |
| `ShellExecute` API | Critical | Windows shell execution |
| `Invoke-Expression` / `IEX` | Critical | PowerShell code execution |

#### 2. Data Exfiltration (10 patterns)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `curl` to external URL | High | HTTP client exfiltration |
| `wget` to external URL | High | HTTP client exfiltration |
| `requests.get/post/put` | High | Python HTTP requests |
| `fetch()` to external URL | Medium | JavaScript fetch calls |
| `axios.get/post` | Medium | Axios HTTP calls |
| `Invoke-WebRequest` | High | PowerShell web request |
| `Invoke-RestMethod` | High | PowerShell REST call |
| Base64 + HTTP | Critical | Encoded data exfiltration |
| Netcat listener (`nc -el`) | Critical | Reverse shell |
| Raw socket connect | High | Direct network connection |

#### 3. Hardcoded Secrets (10 patterns)

| Pattern | Severity | Description |
|---------|----------|-------------|
| API key assignment | Critical | Hardcoded API keys |
| Password assignment | Critical | Hardcoded passwords |
| Token assignment | Critical | Hardcoded auth tokens |
| GitHub PAT (`ghp_`) | Critical | GitHub personal access tokens |
| OpenAI API Key (`sk-`) | Critical | OpenAI API keys |
| Slack Token (`xox*`) | Critical | Slack tokens |
| AWS Access Key ID (`AKIA`) | High | AWS credentials |
| Private Key headers | Critical | RSA/EC private keys |
| MongoDB URI with creds | Critical | Database connection strings |
| PostgreSQL URI with creds | Critical | Database connection strings |

#### 4. File System Attacks (8 patterns)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `rm -rf /` | Critical | Recursive root deletion |
| `Remove-Item -Recurse -Force` | High | PowerShell force delete |
| `chmod 777` | Medium | Overly permissive permissions |
| `chown root` | Medium | Ownership escalation |
| `/etc/passwd` access | High | User database access |
| `/etc/shadow` access | Critical | Password hash access |
| Path traversal (`../../`) | High | Directory traversal |
| `format` disk | Critical | Disk destruction |

#### 5. Network Attacks (4 patterns)

| Pattern | Severity | Description |
|---------|----------|-------------|
| `0.0.0.0` bind | Medium | Listen on all interfaces |
| `iptables -F` | High | Flush firewall rules |
| `netsh advfirewall` | High | Modify Windows firewall |
| `Set-NetFirewallRule` | High | Modify firewall rules |

### Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Immediate security risk | Blocks pipeline, requires fix |
| **High** | Significant risk | Warning, review required |
| **Medium** | Potential risk | Informational |

### Security Grades

| Grade | Criteria |
|-------|----------|
| A+ | No issues found |
| A | Only medium issues (≤3) |
| B | Medium issues (>3) |
| C | High issues (1-3) or many medium |
| D | High issues (>3) |
| F | Any critical issue |

### Allowlisted Skills

Some skills (e.g., `security/security-scanner`, `security/security-audit`) legitimately contain detection patterns as part of their security scanning rules. These are allowlisted and only secrets-category patterns trigger alerts for them.

## CI Integration

The skill security auditor runs automatically in GitHub Actions on every push that modifies `skills/` or `scripts/`. See `.github/workflows/publish-skills.yml`.

## Best Practices

1. **Always run the auditor** before publishing skills: `.\scripts\publish-skills.ps1`
2. **Review findings** — even medium-severity issues deserve attention
3. **Never hardcode secrets** in SKILL.md files — use environment variables
4. **Use the allowlist sparingly** — only for legitimate security scanning tools
5. **Report suspicious patterns** — if you find a pattern not covered by the auditor, open an issue
