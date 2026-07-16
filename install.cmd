@echo off
echo =====================================================
echo               GOD-OPENCODE INSTALLER
echo =====================================================
echo.
echo Launching god-install.ps1...
powershell.exe -ExecutionPolicy Bypass -File "%~dp0god-install.ps1"
echo.
pause
