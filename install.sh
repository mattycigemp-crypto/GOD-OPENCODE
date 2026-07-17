#!/usr/bin/env bash
# ============================================
# GOD-OPENCODE Native Bash Installer
# Version 2.0
# ============================================
# Full native bash installer - no PowerShell dependency.
# Works on Linux, macOS, WSL, and Git Bash on Windows.
#
# Usage:
#   bash install.sh              # interactive install
#   bash install.sh --yes        # skip prompts
#   bash install.sh --uninstall  # remove global install
#   bash install.sh --status     # check install status
#
# Requirements: bash 4+, git, curl (optional)
# ============================================

set -euo pipefail

# ============================================
# Configuration
# ============================================

GOD_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_DIR="${HOME}/.config/opencode"
SKILLS_DIR="${OPENCODE_DIR}/skills"
GOD_DIR="${OPENCODE_DIR}/god-opencode"
GLOBAL_CONFIG="${OPENCODE_DIR}/opencode.json"
VERSION="2.0"
YES_MODE=false
UNINSTALL=false
STATUS_ONLY=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============================================
# Helper Functions
# ============================================

log_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_created() { echo -e "${GREEN}[CREATED]${NC} $1"; }
log_updated() { echo -e "${YELLOW}[UPDATED]${NC} $1"; }
log_skipped() { echo -e "${GRAY}[SKIPPED]${NC} $1"; }

ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_created "$1"
    fi
}

write_if_changed() {
    local path="$1"
    local content="$2"
    local dir
    dir="$(dirname "$path")"
    ensure_dir "$dir"

    if [ ! -f "$path" ]; then
        echo "$content" > "$path"
        log_created "$path"
    else
        local existing
        existing="$(cat "$path")"
        if [ "$existing" != "$content" ]; then
            echo "$content" > "$path"
            log_updated "$path"
        fi
    fi
}

write_if_missing() {
    local path="$1"
    local content="$2"
    local dir
    dir="$(dirname "$path")"
    ensure_dir "$dir"

    if [ ! -f "$path" ]; then
        echo "$content" > "$path"
        log_created "$path"
    fi
}

prompt_yn() {
    local msg="$1"
    local default="${2:-y}"
    if [ "$YES_MODE" = true ]; then
        return 0
    fi
    if [ "$default" = "y" ]; then
        read -rp "$(echo -e "${CYAN}${msg} [Y/n]:${NC} ")" answer
        [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
    else
        read -rp "$(echo -e "${CYAN}${msg} [y/N]:${NC} ")" answer
        [[ "$answer" =~ ^[Yy]$ ]]
    fi
}

# ============================================
# Parse Arguments
# ============================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes|-y)      YES_MODE=true; shift ;;
        --uninstall)   UNINSTALL=true; shift ;;
        --status)      STATUS_ONLY=true; shift ;;
        --help|-h)
            echo "Usage: bash install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --yes, -y        Skip confirmation prompts"
            echo "  --uninstall      Remove global installation"
            echo "  --status         Check installation status"
            echo "  --help, -h       Show this help"
            exit 0
            ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

# ============================================
# Status Check
# ============================================

show_status() {
    echo ""
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${MAGENTA}  GOD-OPENCODE INSTALL STATUS${NC}"
    echo -e "${MAGENTA}========================================${NC}"
    echo ""

    local installed=false

    # Check skills
    if [ -d "$SKILLS_DIR" ]; then
        local skill_count
        skill_count=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l)
        if [ "$skill_count" -gt 0 ]; then
            log_success "Skills: $skill_count installed in $SKILLS_DIR"
            installed=true
        else
            log_warn "Skills directory exists but empty"
        fi
    else
        log_warn "Skills not installed"
    fi

    # Check agents
    if [ -d "${GOD_DIR}/agents" ]; then
        local agent_count
        agent_count=$(find "${GOD_DIR}/agents" -type d -mindepth 1 2>/dev/null | wc -l)
        if [ "$agent_count" -gt 0 ]; then
            log_success "Agents: $agent_count installed in ${GOD_DIR}/agents"
            installed=true
        fi
    else
        log_warn "Agents not installed"
    fi

    # Check workflows
    if [ -d "${GOD_DIR}/workflows" ]; then
        local wf_count
        wf_count=$(find "${GOD_DIR}/workflows" -name "*.md" 2>/dev/null | wc -l)
        if [ "$wf_count" -gt 0 ]; then
            log_success "Workflows: $wf_count installed in ${GOD_DIR}/workflows"
            installed=true
        fi
    else
        log_warn "Workflows not installed"
    fi

    # Check global config
    if [ -f "$GLOBAL_CONFIG" ]; then
        if grep -q "god-opencode" "$GLOBAL_CONFIG" 2>/dev/null; then
            log_success "Global config: merged at $GLOBAL_CONFIG"
            installed=true
        else
            log_warn "Global config exists but not merged"
        fi
    else
        log_warn "No global config"
    fi

    echo ""
    if [ "$installed" = true ]; then
        echo -e "${GREEN}GOD-OPENCODE is globally installed.${NC}"
    else
        echo -e "${YELLOW}GOD-OPENCODE is NOT globally installed.${NC}"
        echo -e "${GRAY}Run: bash install.sh${NC}"
    fi
    echo ""
}

if [ "$STATUS_ONLY" = true ]; then
    show_status
    exit 0
fi

# ============================================
# Uninstall
# ============================================

if [ "$UNINSTALL" = true ]; then
    echo ""
    echo -e "${YELLOW}This will remove GOD-OPENCODE from $OPENCODE_DIR${NC}"
    if ! prompt_yn "Proceed?" "n"; then
        echo "Cancelled."
        exit 0
    fi

    [ -d "$SKILLS_DIR" ] && rm -rf "$SKILLS_DIR" && log_info "Removed $SKILLS_DIR"
    [ -d "${GOD_DIR}/agents" ] && rm -rf "${GOD_DIR}/agents" && log_info "Removed ${GOD_DIR}/agents"
    [ -d "${GOD_DIR}/workflows" ] && rm -rf "${GOD_DIR}/workflows" && log_info "Removed ${GOD_DIR}/workflows"
    [ -d "${GOD_DIR}/commands" ] && rm -rf "${GOD_DIR}/commands" && log_info "Removed ${GOD_DIR}/commands"
    [ -d "$GOD_DIR" ] && rmdir "$GOD_DIR" 2>/dev/null && log_info "Removed $GOD_DIR"

    echo ""
    log_success "Uninstall complete"
    exit 0
fi

# ============================================
# Install
# ============================================

echo ""
echo -e "${MAGENTA}========================================${NC}"
echo -e "${MAGENTA}  GOD-OPENCODE INSTALLER v${VERSION}${NC}"
echo -e "${MAGENTA}========================================${NC}"
echo ""
echo -e "${CYAN}Installing to: $OPENCODE_DIR${NC}"
echo ""

if ! prompt_yn "Install GOD-OPENCODE globally?"; then
    echo "Cancelled."
    exit 0
fi

echo ""

# 1. Install Skills
log_info "Installing skills..."
ensure_dir "$SKILLS_DIR"

skill_count=0
if [ -d "${GOD_ROOT}/skills" ]; then
    while IFS= read -r -d '' skill_dir; do
        skill_name="$(basename "$(dirname "$skill_dir")")"
        category="$(basename "$(dirname "$(dirname "$skill_dir")")")"
        dest="${SKILLS_DIR}/${category}/${skill_name}"
        ensure_dir "$dest"
        if cp "$skill_dir" "${dest}/SKILL.md" 2>/dev/null; then
            ((skill_count++))
        else
            log_warn "Failed to copy: $skill_dir"
        fi
    done < <(find "${GOD_ROOT}/skills" -name "SKILL.md" -print0)
fi
log_success "Installed $skill_count skills"

# 2. Install Agents
log_info "Installing agents..."
ensure_dir "${GOD_DIR}/agents"

agent_count=0
if [ -d "${GOD_ROOT}/agents" ]; then
    for agent_dir in "${GOD_ROOT}/agents"/*/; do
        [ -d "$agent_dir" ] || continue
        agent_name="$(basename "$agent_dir")"
        dest="${GOD_DIR}/agents/${agent_name}"
        ensure_dir "$dest"
        if [ -f "${agent_dir}/AGENT.md" ]; then
            if cp "${agent_dir}/AGENT.md" "${dest}/AGENT.md" 2>/dev/null; then
                ((agent_count++))
            else
                log_warn "Failed to copy: ${agent_dir}/AGENT.md"
            fi
        fi
    done
fi
log_success "Installed $agent_count agents"

# 3. Install Workflows
log_info "Installing workflows..."
ensure_dir "${GOD_DIR}/workflows"

wf_count=0
if [ -d "${GOD_ROOT}/workflows" ]; then
    for wf in "${GOD_ROOT}/workflows"/*.md; do
        [ -f "$wf" ] || continue
        if cp "$wf" "${GOD_DIR}/workflows/" 2>/dev/null; then
            ((wf_count++))
        else
            log_warn "Failed to copy: $wf"
        fi
    done
fi
log_success "Installed $wf_count workflows"

# 4. Install Commands
log_info "Installing commands..."
ensure_dir "${GOD_DIR}/commands"

cmd_count=0
if [ -d "${GOD_ROOT}/commands" ]; then
    for cmd in "${GOD_ROOT}/commands"/*.md; do
        [ -f "$cmd" ] || continue
        if cp "$cmd" "${GOD_DIR}/commands/" 2>/dev/null; then
            ((cmd_count++))
        else
            log_warn "Failed to copy: $cmd"
        fi
    done
fi
log_success "Installed $cmd_count commands"

# 5. Merge opencode.json (idempotent)
log_info "Merging opencode.json..."
ensure_dir "$(dirname "$GLOBAL_CONFIG")"

if [ -f "${GOD_ROOT}/opencode.json" ]; then
    if [ ! -f "$GLOBAL_CONFIG" ]; then
        cp "${GOD_ROOT}/opencode.json" "$GLOBAL_CONFIG"
        log_created "$GLOBAL_CONFIG"
    else
        # Check if already merged
        if grep -q "god-opencode" "$GLOBAL_CONFIG" 2>/dev/null; then
            log_skipped "opencode.json already merged"
        else
            log_info "Merging agent configs (would need jq for full merge)..."
            log_warn "Manual merge recommended: compare opencode.json with $GLOBAL_CONFIG"
        fi
    fi
fi

# 6. Create project-local skills symlink
log_info "Setting up project-local skills..."
ensure_dir "${GOD_ROOT}/.opencode/skills"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  INSTALL COMPLETE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  Skills:    $skill_count installed"
echo -e "  Agents:    $agent_count installed"
echo -e "  Workflows: $wf_count installed"
echo -e "  Commands:  $cmd_count installed"
echo ""
echo -e "${CYAN}Global install: $OPENCODE_DIR${NC}"
echo -e "${GRAY}Skills are now available from any directory.${NC}"
echo ""
