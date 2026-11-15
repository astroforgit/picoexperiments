@echo off
setlocal
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0tools\music-library.ps1" %*
if errorlevel 1 pause
