# GOD-OPENCODE container image
# Self-contained PowerShell + the installable skills/agents/workflows/tools.
# Built and pushed to ghcr.io on every v* tag.
# Tag pattern: ghcr.io/mattycigemp-crypto/god-opencode:<version> and :latest.

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# Least-privilege: non-root user with no login shell (entrypoint is pwsh only).
RUN useradd -m -s /bin/false -u 1001 goduser

WORKDIR /god-opencode

# Single COPY layer with --chown so we don't need a follow-up chown -R layer.
# Mirrors package-release.ps1's runtime-required include list.
COPY --chown=goduser:goduser \
    skills/ workflows/ agents/ commands/ scripts/ \
    install.ps1 opencode.json AGENTS.md README.md CHANGELOG.md LICENSE \
    ./

USER goduser

# Fast, clean PowerShell that drops you inside /god-opencode.
ENTRYPOINT ["pwsh", "-NoProfile", "-NoLogo"]
CMD ["-Command", "Get-ChildItem | Format-Table Name; Write-Host '' ; Write-Host 'GOD-OPENCODE container ready.' -ForegroundColor Cyan ; Write-Host 'Try: pwsh -File ./install.ps1' -ForegroundColor Cyan"]
