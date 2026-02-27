@echo off
:: Uninstall "Open in WSL" and "Copy WSL Path" context menu items
:: Double-click to run from any folder. Removes scripts and registry entries.

:: Check for admin rights, re-launch elevated if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Remove registry entries
reg delete "HKCR\*\shell\OpenInWSL" /f >nul 2>&1
reg delete "HKCR\Directory\shell\OpenInWSL" /f >nul 2>&1
reg delete "HKCR\Directory\Background\shell\OpenInWSL" /f >nul 2>&1

reg delete "HKCR\*\shell\CopyWSLPath" /f >nul 2>&1
reg delete "HKCR\Directory\shell\CopyWSLPath" /f >nul 2>&1
reg delete "HKCR\Directory\Background\shell\CopyWSLPath" /f >nul 2>&1

:: Remove installed scripts
set "DST=%LocalAppData%\WSLTools\"
if exist "%DST%" rmdir /s /q "%DST%"

echo.
echo   Uninstalled successfully!
echo   - "Open in WSL" and "Copy WSL Path" removed from right-click menu.
echo   - Removed scripts from: %DST%
echo.
pause
