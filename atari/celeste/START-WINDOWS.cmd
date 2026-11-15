@echo off
rem Double-click to play Celeste in Altirra (needs celeste.xex built).
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1" %*
if errorlevel 1 pause
