# ============================================
# GOD-OPENCODE BUILDER ENGINE
# Version 2.0
# ============================================

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "shared-utils.ps1")
$Root = Get-ProjectRoot

Write-Banner "GOD-OPENCODE BUILDER ENGINE"

# ============================================
# BASE STRUCTURE
# ============================================

$Folders = @(
    "agents",
    "prompts",
    "workflows",
    "templates",
    "mcps",
    "config"
)

foreach ($Folder in $Folders) {
    EnsureFolder "$Root\$Folder"
}

# ============================================
# AGENTS
# ============================================

$Agents = @(
    "principal-engineer",
    "ai-engineer",
    "frontend-engineer",
    "backend-engineer",
    "security-engineer",
    "devops-engineer",
    "database-architect",
    "researcher",
    "debugger",
    "technical-writer"
)

foreach ($Agent in $Agents) {
    EnsureFolder "$Root\agents\$Agent"
}

# ============================================
# WORKFLOWS
# ============================================

$Workflows = @(
    "debug-system",
    "refactor-codebase",
    "create-ai-agent",
    "create-mcp-server",
    "security-review",
    "performance-audit",
    "launch-product"
)

foreach ($Workflow in $Workflows) {
    EnsureFolder "$Root\workflows"
}

# ============================================
# PROMPT CATEGORIES
# ============================================

$PromptFolders = @(
    "coding",
    "ai",
    "research",
    "writing",
    "business"
)

foreach ($Folder in $PromptFolders) {
    EnsureFolder "$Root\prompts\$Folder"
}

# ============================================
# MCP REGISTRY
# ============================================

$MCP = @"
{
    "servers": {
        "filesystem": { "enabled": true },
        "github": { "enabled": true },
        "playwright": { "enabled": true },
        "context7": { "enabled": true },
        "tavily": { "enabled": true }
    }
}
"@

Write-IfChanged "$Root\mcps\registry.json" $MCP

# ============================================
# GOD CONFIG
# ============================================

$Config = @"
{
    "name": "GOD-OPENCODE",
    "version": "2.0",
    "autoUpdate": true,
    "skillSystem": true,
    "agentSystem": true,
    "mcpSystem": true,
    "workflowSystem": true
}
"@

Write-IfChanged "$Root\config\god-config.json" $Config

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " GOD-OPENCODE BUILD COMPLETE" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
