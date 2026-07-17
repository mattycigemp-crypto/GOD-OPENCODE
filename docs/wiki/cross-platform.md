# Cross-Platform Install

> **Before 1.2:** PowerShell-only on Windows. Linux/macOS users had to
> bootstrap pwsh themselves with no guidance.
>
> **In 1.2:** Linux/macOS users run `bash install.sh`. Windows users
> have `install.cmd` as a fallback. Docker image ships to ghcr.io.

## Matrix

| Platform | Command | Pre-reqs |
|----------|---------|----------|
| Windows 10/11 | `.\install.ps1` | PowerShell 5.1 (built in) |
| Windows 10/11 | `install.cmd` | PowerShell (called internally) |
| Linux / macOS | `bash install.sh` | [PowerShell 7](https://aka.ms/powershell) |
| WSL | `bash install.sh` | Same as Linux |
| Docker | `docker pull ghcr.io/mattycigemp-crypto/god-opencode:latest` | Docker |
| GitHub Codespaces | (one-click) | Repo on GitHub |

## Why two Windows shims?

- `install.ps1` — full-featured, used by PowerShell hosts. All options,
  flags, and error reporting land here.
- `install.cmd` — minimal `cmd.exe` wrapper for batch scripts and 
  task-runner use. Forwards to `install.ps1` via PowerShell.

## install.sh in detail

```bash
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$DIR/install.ps1" "$@"
```

- Validates `pwsh` is on PATH (else errors clearly with the install link).
- Validates `install.ps1` exists.
- Forwards all CLI args through to `install.ps1`.

## Container

Pulls PowerShell 7.4 + the installable project as a single image:

```
docker pull ghcr.io/mattycigemp-crypto/god-opencode:latest
docker run --rm -it ghcr.io/mattycigemp-crypto/god-opencode:latest
```

Inside the container you land in PowerShell at `/god-opencode`. Run
`./install.ps1` to install into the container's home; or `pwsh -File 
./scripts/god-install.ps1` for the project-local install.

## Devcontainer (Codespaces)

A `.devcontainer/devcontainer.json` is on the roadmap (1.3) so anyone
opening the repo in GitHub Codespaces gets PowerShell + OpenCode 
ready in one click.

## Roadmap

- **1.2 (shipped):** `install.sh`, `install.cmd`, ghcr.io container
- **1.3:** `.devcontainer/devcontainer.json` for Codespaces  
- **1.3:** Multi-arch container (amd64 + arm64)
- **2.0:** First-class PowerShell module (`Install-Module GodOpenCode`) 
  published to the PowerShell Gallery

## See also

- [Roadmap](roadmap.md) — the cross-platform concern in context
- [Getting Started](getting-started.md) — first-run walkthrough
