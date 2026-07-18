# CogniVect

An AI engineering OS built on OpenCode. Provides specialized agents, domain skills, and structured workflows for production-grade software development.

## Project Structure

```
CogniVect/
├── opencode.json              # OpenCode config (agents, commands)
├── AGENTS.md                  # Project context for OpenCode
├── god-cli.ps1                # Non-interactive CLI
├── god-ui.ps1                 # Interactive terminal UI (TUI)
├── install.ps1                # Global installer (skills, workflows, agents, commands)
├── install.sh                 # Native bash installer (no PowerShell needed)
├── .opencode/skills/          # Project-local skills (auto-discovered)
├── agents/                    # 10 agent personas (AGENT.md each)
├── skills/                    # 88 skill definitions (SKILL.md each, 12 categories)
├── workflows/                 # 16 parameterized workflows
├── commands/                  # 6 slash command definitions
├── router/                    # Intent detection and routing config
├── scripts/                   # PowerShell engines (builder, expansion, health)
├── mcps/                      # MCP server configs
├── templates/                 # Project scaffolds
├── tests/                     # Pester test suite
├── docs/                      # Documentation and wiki
├── memory/                    # Long-term memory store
└── ui/                        # Browser dashboard
```

## Coding Standards

- PowerShell 5.1 compatible (use `;` not `&&`, `Join-Path` for paths)
- Unicode box-drawing characters use `[char]0xXXXX` variables (not literal strings in hashtables)
- All scripts use `$ErrorActionPreference = "Stop"` explicitly
- Skills use YAML frontmatter with `name` and `description` fields
- Workflows use `{{PARAM}}` syntax for parameter substitution
- Markdown for all documentation and definitions

## Key Commands

| Command | Purpose |
|---------|---------|
| `.\god-ui.ps1` | Launch interactive TUI (main entry point) |
| `.\god-cli.ps1` | Non-interactive CLI |
| `.\install.ps1` | Install skills, workflows, agents, commands to OpenCode |
| `.\god-install.ps1` | Full installation with build and health check |
| `.\god-health.ps1` | Health check |

## CLI Commands

```powershell
.\god-cli.ps1 install             # install globally
.\god-cli.ps1 health              # health check
.\god-cli.ps1 test                # run tests
.\god-cli.ps1 status              # show install status
.\god-cli.ps1 code-graph          # build code graph
.\god-cli.ps1 skill-fragment -Query "auth jwt"
.\god-cli.ps1 smart-load -Query "fastapi" -Context "backend"
.\god-cli.ps1 session -Init       # init session memory
.\god-cli.ps1 wiki-build          # generate wiki pages
.\god-cli.ps1 cursor-export       # export .cursorrules
.\god-cli.ps1 security-scan       # scan for secrets/vulns
.\god-cli.ps1 agent-orch -Task "Build API"  # multi-agent task
.\god-cli.ps1 mcp-connect -Tool chrome -Action screenshot
.\god-cli.ps1 smart-git commit    # smart commit staged
.\god-cli.ps1 -Help               # show all commands
```

## TUI Menu

The terminal UI (`god-ui.ps1`) provides an interactive menu:

| Key | Action |
|-----|--------|
| Enter / `1` | Install Globally (default) |
| `2` | Health Check |
| `3` | Code Graph |
| `4` | Skill Fragment |
| `5` | Memory |
| `6` | Cross-Platform |
| `7` | Tests |
| `8` | Wiki |
| `9` | Dashboard |
| `S` | Session Memory |
| `W` | Wiki Builder |
| `L` | Live Architecture |
| `R` | Skills Registry |
| `C` | Cursor Export |
| `T` | Security Scanner |
| `A` | Agent Orchestrator |
| `M` | MCP Connectors |
| `G` | Smart Git |
| `N` | What's New |
| `Q` | Exit |

## Architecture

CogniVect extends OpenCode with three layers:

1. **Agents** — Specialized AI personas (backend-engineer, security-engineer, etc.)
2. **Skills** — Domain knowledge loaded on-demand (fastapi, react, security-audit, etc.)
3. **Workflows** — Step-by-step processes (security-audit, api-design, etc.)

Plus utility scripts:

4. **Security Scanner** — Pre-commit scanning for secrets and vulnerabilities
5. **Agent Orchestrator** — Multi-agent task delegation with verification
6. **MCP Connectors** — External tool integration (Chrome, DB, Jira, Monitoring)
7. **Smart Git** — AI-powered commits, save points, and rollback

## Build / Test / Health Commands

Run these from the repository root:

| Command | Purpose |
|---------|---------|
| `.\tests\run-tests.ps1` | Run unit, property, and smoke tests (excludes integration) |
| `.\tests\run-tests.ps1 -All` | Run all tests including integration |
| `.\tests\run-tests.ps1 -Integration` | Run integration tests only |
| `.\god-health.ps1` | Run the full health check against the repository |

## Contribution Workflow

1. **Fork or branch** from `master`.
2. **Make changes** following the coding standards above.
3. **Run tests** with `.\tests\run-tests.ps1`.
4. **Run health check** with `.\god-health.ps1`.
5. **Commit** with clear, descriptive messages.
6. **Open a pull request** describing the change and linking any related issue.
7. **Tag a release** with `git tag v<major>.<minor>.<patch>` when ready.

## OpenCode Integration

- Skills installed to `~/.config/opencode/skills/`
- Workflows/agents/commands copied to `~/.config/opencode/cognivect/`
- Use `skill` tool to load skills: `skill(name="auto-router")`
- Use `@agent-name` to invoke subagents
- Tab to switch between primary agents (Build/Plan)
