@echo off
REM ============================================
REM  GOD-OPENCODE cross-platform installer (cmd.exe)
REM  Version 1.0
REM ============================================
REM  Windows cmd.exe shim. Forwards to .\install.ps1 via PowerShell.
REM
REM  Use .\install.ps1 directly on PowerShell hosts; this file is for
REM  cmd-only environments where PowerShell call is non-obvious.

setlocal

set "DIR=%~dp0"
rem Ensure DIR ends with a backslash before joining with install.ps1
if "%DIR:~-1%" neq "\" set "DIR=%DIR%\"
set "PS1=%DIR%install.ps1"

if not exist "%PS1%" (
    echo [install.cmd] ERROR: %PS1% not found.
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
exit /b %ERRORLEVEL%
