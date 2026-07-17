#!/usr/bin/env bash
# ============================================
# GOD-OPENCODE cross-platform installer (bash)
# Version 1.0
# ============================================
# Delegates to ./install.ps1 via PowerShell 7 (pwsh).
# Linux / macOS / WSL users can run: bash install.sh
#
# Note: pwsh must be installed. Get it from
#   https://learn.microsoft.com/powershell/scripting/install/installing-powershell

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
PS1="$DIR/install.ps1"

if ! command -v pwsh >/dev/null 2>&1; then
    echo "[install.sh] ERROR: PowerShell (pwsh) is required for cross-platform install."
    echo "  Install: https://aka.ms/powershell"
    echo "  Or run the PowerShell installer directly if you already have PowerShell 7."
    exit 1
fi

if [ ! -f "$PS1" ]; then
    echo "[install.sh] ERROR: $PS1 not found."
    exit 1
fi

echo "[install.sh] Delegating to PowerShell installer at $PS1"
exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$PS1" "$@"
