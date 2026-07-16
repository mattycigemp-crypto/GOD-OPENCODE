# ============================================
# GOD-OPENCODE TERMINAL UI
# ============================================

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Menu {
    Clear-Host
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "               GOD-OPENCODE TERMINAL UI" -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Install / Update GOD-OPENCODE"
    Write-Host "2. Run System Health Check"
    Write-Host "3. Project Scan (Intelligence Engine)"
    Write-Host "4. Run Pester Tests"
    Write-Host "5. Show Memory List"
    Write-Host "6. Exit"
    Write-Host ""
    Write-Host "=====================================================" -ForegroundColor Cyan
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Select an option (1-6)"

    switch ($choice) {
        "1" {
            Clear-Host
            & (Join-Path $Root "god-install.ps1")
            pause
        }
        "2" {
            Clear-Host
            & (Join-Path $Root "god-health.ps1")
            pause
        }
        "3" {
            Clear-Host
            $target = Read-Host "Enter project path to scan (leave blank for current dir)"
            if ([string]::IsNullOrWhiteSpace($target)) { $target = (Get-Location).Path }
            $scanPath = Join-Path $Root "tools\project-scan.ps1"
            if (Test-Path $scanPath) {
                & $scanPath -TargetPath $target
            } else {
                Write-Host "Scanner not found at $scanPath" -ForegroundColor Red
            }
            pause
        }
        "4" {
            Clear-Host
            Invoke-Pester -Path (Join-Path $Root "tests") -ExcludeTag Integration -Output Detailed
            pause
        }
        "5" {
            Clear-Host
            $memoryPath = Join-Path $Root "scripts\memory.ps1"
            if (Test-Path $memoryPath) {
                & $memoryPath
            } else {
                Write-Host "Memory script not found at $memoryPath" -ForegroundColor Red
            }
            pause
        }
        "6" {
            Write-Host "Exiting GOD-OPENCODE UI..."
            exit
        }
        default {
            Write-Host "Invalid option. Try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
