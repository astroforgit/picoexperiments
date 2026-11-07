@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-heroes-vbxe3.ps1" %*
if errorlevel 1 pause
