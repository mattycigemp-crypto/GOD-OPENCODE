# GOD-OPENCODE

An AI engineering OS built on OpenCode. Provides specialized agents, domain skills, and structured workflows for production-grade software development.

## Project Structure

```
GOD-OPENCODE/
├── agents/           # Agent definitions (AGENT.md files)
├── skills/           # Skill source files (SKILL.md in categories)
├── workflows/        # Step-by-step workflow definitions
├── commands/         # Command definitions (build, debug, review, etc.)
├── router/           # Intent detection and routing config
├── scripts/          # PowerShell utilities (shared-utils, god-builder, etc.)
├── config/           # Configuration files
├── mcps/             # MCP server registry
├── models/           # Model routing config
├── templates/        # Templates for scaffolding
├── tools/            # Custom tools
├── brand/            # Logo assets and brand guidelines
└── ui/               # Dashboard (HTML/Canvas2D)
```

## Coding Standards

- PowerShell 5.1 compatible (no Unicode box-drawing, no `char * int`, use `;` not `&&`)
- All scripts dot-source `scripts/shared-utils.ps1` for common functions
- Skills use YAML frontmatter with `name` and `description` fields
- Workflows use `{{PARAM}}` syntax for parameter substitution
- Markdown for all documentation and definitions

## Key Commands

| Command | Purpose |
|---------|---------|
| `.\install.ps1` | Install skills, workflows, agents, commands to OpenCode |
| `.\god-install.ps1` | Full installation with build and health check |
| `.\scripts\god-builder.ps1` | Build/scaffold components |
| `.\scripts\god-expansion.ps1` | Expand existing components |
| `.\scripts\god-health.ps1` | Health check |
| `.\scripts\auto-router.ps1` | Test intent detection routing |

## Architecture

GOD-OPENCODE extends OpenCode with three layers:

1. **Agents** — Specialized AI personas (backend-engineer, security-engineer, etc.)
2. **Skills** — Domain knowledge loaded on-demand (fastapi, react, security-audit, etc.)
3. **Workflows** — Step-by-step processes (security-audit, api-design, etc.)

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
- Workflows/agents/commands copied to `~/.config/opencode/god-opencode/`
- Use `skill` tool to load skills: `skill(name="auto-router")`
- Use `@agent-name` to invoke subagents
- Tab to switch between primary agents (Build/Plan)
