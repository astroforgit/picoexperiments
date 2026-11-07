@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-prince-and-the-nymph.ps1" %*
if errorlevel 1 pause
