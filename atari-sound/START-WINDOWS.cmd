@echo off
setlocal
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0tools\compare-music.ps1" %*
if errorlevel 1 pause
