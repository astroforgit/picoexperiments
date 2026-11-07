@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-outro-full-quality-test.ps1" %*
if errorlevel 1 pause
