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
├── skills/                # 84 SKILL.md files
├── god-opencode/
│   ├── agents/            # 10 AGENT.md files
│   ├── workflows/         # 15 workflow .md files
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

## Next

- [Architecture](architecture.md) — what the layers mean
- [Roadmap](roadmap.md) — what we're working on next
- [Code Graph](graph.md) — the new structural feature
