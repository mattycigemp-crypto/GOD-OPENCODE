# ============================================
# GOD-OPENCODE SMART GIT
# Version 1.0
# ============================================
# Smart git integration:
# - Atomic commits with AI-generated messages
# - Save points for rollback
# - Diff visualization showing what changed
#
# Usage:
#   .\scripts\smart-git.ps1 commit                   # smart commit all staged
#   .\scripts\smart-git.ps1 commit -Message "fix auth" # custom message
#   .\scripts\smart-git.ps1 savepoint                 # create save point
#   .\scripts\smart-git.ps1 rollback                  # rollback to last save point
#   .\scripts\smart-git.ps1 diff                      # show what changed
#   .\scripts\smart-git.ps1 log -Count 5              # show recent commits

param(
    [Parameter(Position=0)]
    [string]$Command = "status",
    [string]$Message = "",
    [int]$Count = 10,
    [switch]$Staged,
    [switch]$All
)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

# Generate AI-style commit message
function New-CommitMessage {
    param([string[]]$Changes)
    
    $summary = @()
    $types = @{
        "M" = "update"  # Modified
        "A" = "add"     # Added
        "D" = "remove"  # Deleted
        "R" = "rename"  # Renamed
    }
    
    foreach ($change in $Changes) {
        $parts = $change -split "\s+"
        $status = $parts[0]
        $file = $parts[1..($parts.Count-1)] -join " "
        
        $ext = [System.IO.Path]::GetExtension($file)
        $dir = [System.IO.Path]::GetDirectoryName($file)
        
        $type = $types[$status.Substring(0,1)]
        if (-not $type) { $type = "update" }
        
        # Determine scope from directory
        $scope = ""
        if ($dir -match "^scripts") { $scope = "scripts" }
        elseif ($dir -match "^skills") { $scope = "skills" }
        elseif ($dir -match "^workflows") { $scope = "workflows" }
        elseif ($dir -match "^agents") { $scope = "agents" }
        elseif ($dir -match "^docs") { $scope = "docs" }
        elseif ($dir -match "^ui") { $scope = "ui" }
        else { $scope = "project" }
        
        $summary += "$type($scope): $([System.IO.Path]::GetFileNameWithoutExtension($file))"
    }
    
    if ($summary.Count -eq 1) {
        return $summary[0]
    } elseif ($summary.Count -le 3) {
        return $summary -join "; "
    } else {
        return "chore: update $($summary.Count) files ($($summary[0..1] -join ', '))"
    }
}

# Commit command
function Invoke-Commit {
    param([string]$CustomMessage)
    
    Write-Host ""
    Write-Host "--- Smart Commit ---" -ForegroundColor Cyan
    Write-Host ""
    
    # Get staged changes
    $output = & git diff --cached --name-status 2>&1
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        Write-Host "  No staged changes. Run 'git add' first." -ForegroundColor Yellow
        return
    }
    
    $changes = $output -split "`n" | Where-Object { $_.Trim() -ne "" }
    Write-Host "  Staged changes: $($changes.Count) files" -ForegroundColor Gray
    
    # Generate or use message
    if ($CustomMessage) {
        $msg = $CustomMessage
    } else {
        $msg = New-CommitMessage -Changes $changes
    }
    
    Write-Host "  Message: $msg" -ForegroundColor White
    Write-Host ""
    
    # Commit
    & git commit -m $msg
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Committed successfully" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Commit failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Savepoint command
function Invoke-Savepoint {
    Write-Host ""
    Write-Host "--- Creating Save Point ---" -ForegroundColor Cyan
    Write-Host ""
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $tag = "savepoint/$timestamp"
    
    & git tag $tag
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Save point created: $tag" -ForegroundColor Green
        Write-Host "  Rollback with: .\scripts\smart-git.ps1 rollback" -ForegroundColor Gray
    } else {
        Write-Host "  [FAIL] Failed to create save point" -ForegroundColor Red
    }
    Write-Host ""
}

# Rollback command
function Invoke-Rollback {
    Write-Host ""
    Write-Host "--- Rolling Back ---" -ForegroundColor Cyan
    Write-Host ""
    
    # Find latest save point
    $tags = & git tag -l "savepoint/*" --sort=-version:refname 2>&1
    if (-not $tags) {
        Write-Host "  No save points found" -ForegroundColor Yellow
        return
    }
    
    $latest = ($tags -split "`n")[0].Trim()
    Write-Host "  Rolling back to: $latest" -ForegroundColor Yellow
    Write-Host ""
    
    & git reset --hard $latest
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Rolled back to $latest" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Rollback failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Diff command
function Invoke-Diff {
    Write-Host ""
    Write-Host "--- Changes ---" -ForegroundColor Cyan
    Write-Host ""
    
    if ($Staged) {
        & git diff --cached --stat
    } else {
        & git diff --stat
    }
    Write-Host ""
}

# Log command
function Invoke-Log {
    param([int]$NumCommits)
    
    Write-Host ""
    Write-Host "--- Recent Commits ---" -ForegroundColor Cyan
    Write-Host ""
    
    & git log --oneline -n $NumCommits
    Write-Host ""
}

# Status command
function Invoke-Status {
    Write-Host ""
    Write-Host "--- Git Status ---" -ForegroundColor Cyan
    Write-Host ""
    
    & git status --short
    Write-Host ""
    
    # Show save points
    $tags = & git tag -l "savepoint/*" --sort=-version:refname 2>&1
    if ($tags) {
        Write-Host "  Save points:" -ForegroundColor Gray
        ($tags -split "`n" | Select-Object -First 3) | ForEach-Object {
            Write-Host "    $_" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

# Main
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SMART GIT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

switch ($Command.ToLower()) {
    "commit" { Invoke-Commit -CustomMessage $Message }
    "savepoint" { Invoke-Savepoint }
    "rollback" { Invoke-Rollback }
    "diff" { Invoke-Diff }
    "log" { Invoke-Log -NumCommits $Count }
    "status" { Invoke-Status }
    default {
        Write-Host ""
        Write-Host "  Commands: commit, savepoint, rollback, diff, log, status" -ForegroundColor Gray
        Write-Host ""
    }
}
