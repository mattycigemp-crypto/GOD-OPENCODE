# GOD-OPENCODE container image
# Self-contained PowerShell + the installable skills/agents/workflows/tools.
# Built and pushed to ghcr.io on every v* tag.
# Tag pattern: ghcr.io/mattycigemp-crypto/god-opencode:<version> and :latest.

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# Least-privilege: run as a non-root user inside the container.
RUN useradd -m -s /bin/bash goduser

WORKDIR /god-opencode

# Selective COPY mirrors package-release.ps1's $Include list.
# Excludes docs/ brand/ ui/ tests/ which are developer-only / not runtime-required.
COPY skills/      ./skills/
COPY workflows/   ./workflows/
COPY agents/      ./agents/
COPY commands/    ./commands/
COPY scripts/     ./scripts/
COPY install.ps1  opencode.json AGENTS.md README.md CHANGELOG.md LICENSE ./

RUN chown -R goduser:goduser /god-opencode
USER goduser

# Fast, clean PowerShell that drops you inside /god-opencode.
ENTRYPOINT ["pwsh", "-NoProfile", "-NoLogo"]
CMD ["-Command", "Get-ChildItem | Format-Table Name; Write-Host '' ; Write-Host 'GOD-OPENCODE container ready.' -ForegroundColor Cyan ; Write-Host 'Try: pwsh -File ./install.ps1' -ForegroundColor Cyan"]
