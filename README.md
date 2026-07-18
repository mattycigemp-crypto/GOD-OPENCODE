<p align="center">
  <img src="brand/wordmark.png" alt="CogniVect" width="120">
</p>

<h1 align="center">CogniVect</h1>

<p align="center">
  <strong>The AI engineering OS that thinks in vectors.</strong>
</p>

<p align="center">
  10 specialist agents, 88 domain skills, 16 automated workflows — one command bootstraps a production-grade AI engineering environment.
</p>

<p align="center">
  <a href="https://github.com/mattycigemp-crypto/GOD-OPENCODE/releases/tag/v1.6.0"><img alt="v1.6.0" src="https://img.shields.io/badge/release-v1.6.0-8b5cf6?style=for-the-badge"/></a>
</p>

---

## Animated Demo

<p align="center">
  <img src="brand/terminal-demo.svg" alt="CogniVect Terminal Demo" width="700">
</p>

<p align="center">
  <img src="brand/pipeline-graph.svg" alt="CogniVect Pipeline" width="800">
</p>

---

## What is CogniVect?

CogniVect wraps OpenCode with a three-layer architecture that gives every request the right context:

- **10 Specialist Agents** — senior principal engineers, security auditors, database architects, and more
- **88 Domain Skills** — production-grade knowledge for fastapi, react, postgres, kubernetes, and 84 other domains
- **16 Automated Workflows** — step-by-step processes for API development, security audits, debugging, and deployment

Instead of getting a generic AI assistant, you get the right expert for the job. Everything is file-based, transparent, and extensible.

---

## Quick Start

```powershell
# Clone and enter the directory
git clone https://github.com/mattycigemp-crypto/GOD-OPENCODE
cd GOD-OPENCODE

# Launch the terminal UI (main command)
.\god-ui.ps1
```

Press Enter to install globally — installs skills/agents/workflows into `~/.config/opencode/`.

---

## What's New in v1.6.0

| Feature | Command | Purpose |
|---------|---------|---------|
| Security Scanner | `T` in TUI / `.\god-cli.ps1 security-scan` | Pre-commit secret/vulnerability scan |
| Agent Orchestrator | `A` in TUI / `.\god-cli.ps1 agent-orch` | Multi-agent task delegation |
| MCP Connectors | `M` in TUI / `.\god-cli.ps1 mcp-connect` | Chrome/DB/Jira/Monitoring integration |
| Smart Git | `G` in TUI / `.\god-cli.ps1 smart-git` | Atomic commits, save points, rollback |
| Test-Driven AI | `workflows/test-driven-ai.md` | Generate tests before code |

---

## What You Get

| Component | Count | Purpose |
|-----------|-------|---------|
| Agents | 10 | Specialized AI personas |
| Skills | 88 | Domain knowledge loaded on-demand |
| Workflows | 16 | Step-by-step processes |
| Commands | 6 | Slash commands for common tasks |
| CLI | 1 | Non-interactive command-line interface |

---

## TUI Menu

| Key | Action |
|-----|--------|
| Enter / 1 | Install Globally (default) |
| 2 | Health Check |
| 3 | Code Graph |
| 4 | Skill Fragment |
| 5 | Memory |
| 6 | Cross-Platform |
| 7 | Tests |
| 8 | Wiki |
| 9 | Dashboard |
| S | Session Memory |
| W | Wiki Builder |
| L | Live Architecture |
| R | Skills Registry |
| C | Cursor Export |
| T | Security Scanner |
| A | Agent Orchestrator |
| M | MCP Connectors |
| G | Smart Git |
| N | What's New |
| Q | Exit |

---

## CLI Commands

```powershell
.\god-cli.ps1 status              # show install status
.\god-cli.ps1 health              # health check
.\god-cli.ps1 test                # run tests
.\god-cli.ps1 security-scan       # scan for secrets/vulns
.\god-cli.ps1 agent-orch -Task "Build API"  # multi-agent task
.\god-cli.ps1 mcp-connect -Tool chrome -Action screenshot
.\god-cli.ps1 smart-git commit    # smart commit staged
.\god-cli.ps1 -Help               # show all commands
```

---

## Architecture

```
User Request
    |
    v
+------------------+
| Intent Detection |  <- auto-router
+--------+---------+
         |
         v
+------------------+
| Agent Selection  |  <- orchestrator
+--------+---------+
         |
         v
+------------------+
| Skill Loading    |  <- 88 domain skills
+--------+---------+
         |
         v
+------------------+
| Workflow Engine  |  <- 16 workflows
+--------+---------+
         |
         v
+------------------+
| Verification     |  <- security scanner
+------------------+
```

---

## Project Structure

```
CogniVect/
├── god-ui.ps1                 # Interactive terminal UI (TUI)
├── god-cli.ps1                # Non-interactive CLI
├── install.ps1                # Global installer
├── agents/                    # 10 agent personas
├── skills/                    # 88 skill definitions
├── workflows/                 # 16 parameterized workflows
├── commands/                  # 6 slash command definitions
├── scripts/                   # PowerShell engines
├── brand/                     # Logo assets and SVG demos
├── docs/wiki/                 # Markdown wiki
├── memory/                    # Long-term memory store
└── ui/                        # Browser dashboard
```

---

## Testing

```powershell
.\tests\run-tests.ps1          # run all tests
.\god-health.ps1               # health check
```

---

## License

MIT
