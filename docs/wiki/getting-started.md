# Getting Started

Five-minute setup, works on Windows / Linux / macOS / Docker.

## 1. Clone

```bash
git clone https://github.com/mattycigemp-crypto/GOD-OPENCODE
cd GOD-OPENCODE
```

## 2. Install globally

The **main** command. This is what makes skills available from every
directory.

| Platform | Command |
|----------|---------|
| Windows (PowerShell) | `.\install.ps1` |
| Windows (cmd.exe)    | `install.cmd` |
| Linux / macOS / WSL  | `bash install.sh` (requires [pwsh](https://aka.ms/powershell)) |
| Docker               | `docker pull ghcr.io/mattycigemp-crypto/god-opencode:latest` |

After install, your `~/.config/opencode/` looks like:

```
~/.config/opencode/
├── skills/                # 88 SKILL.md files
├── god-opencode/
│   ├── agents/            # 10 AGENT.md files
│   ├── workflows/         # 16 workflow .md files
│   └── commands/          # 6 command .md files
└── opencode.jsonc         # opencode.json merged in
```

## 3. Launch the TUI

```powershell
.\god-ui.ps1
```

In the TUI, **press Enter** to install globally (it's the default action).

## 4. Use slash commands

In any directory:

```
/build a FastAPI REST API with JWT auth and PostgreSQL
/debug users get duplicate emails on registration
/secure review the authentication flow
/architect should I use Postgres or MongoDB for a multi-tenant SaaS?
```

## 5. Open the dashboard (optional)

In the TUI, press `[9] Dashboard`, or:

```bash
start ui/index.html         # Windows
open ui/index.html          # macOS
xdg-open ui/index.html      # Linux
```

## v1.7.0 Features — Universal Skill Distribution

New in v1.7.0 — cross-tool skill ecosystem:

| Feature | Command | Purpose |
|---------|---------|--------|
| Skill Security Auditor | `.\scripts\audit-skills.ps1` | Scan SKILL.md for malicious patterns |
| Cross-Tool Converter | `.\scripts\convert-skills.ps1` | SKILL.md → .cursorrules, CLAUDE.md, .clinerules, .windsurfrules, copilot-instructions.md |
| Skill Sync (16 tools) | `.\scripts\sync-skills.ps1` | Symlink skills to Claude, Cursor, Windsurf, Cline, Copilot, and 11 more |
| Universal Publisher | `.\scripts\publish-skills.ps1` | One-command pipeline: audit → convert → sync → package |

## v1.6.0 Features (also accessible via TUI menu keys T/A/M/G or god-cli.ps1)

| Feature | Command | Purpose |
|---------|---------|--------|
| Security Scanner | `.\scripts\security-scan.ps1` | Pre-commit secret/vulnerability scan |
| Agent Orchestrator | `.\scripts\agent-orchestrator.ps1` | Multi-agent task delegation |
| MCP Connectors | `.\scripts\mcp-connect.ps1` | Chrome/DB/Jira/Monitoring integration |
| Smart Git | `.\scripts\smart-git.ps1` | Atomic commits, save points, rollback |
| Test-Driven AI | `workflows/test-driven-ai.md` | Generate tests before code |

## Next

- [Architecture](architecture.md) — what the layers mean
- [Roadmap](roadmap.md) — what we're working on next
- [Code Graph](graph.md) — the new structural feature
