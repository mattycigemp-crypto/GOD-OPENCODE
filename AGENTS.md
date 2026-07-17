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

## OpenCode Integration

- Skills installed to `~/.config/opencode/skills/`
- Workflows/agents/commands copied to `~/.config/opencode/god-opencode/`
- Use `skill` tool to load skills: `skill(name="auto-router")`
- Use `@agent-name` to invoke subagents
- Tab to switch between primary agents (Build/Plan)
