@echo off
:: Uninstall "Open in WSL" and "Copy WSL Path" context menu items
:: Double-click to run from any folder. Removes scripts and registry entries.
:: Installed for current user only — no admin required.

:: Remove registry entries
reg delete "HKCU\Software\Classes\*\shell\OpenInWSL" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\OpenInWSL" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\OpenInWSL" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Drive\shell\OpenInWSL" /f >nul 2>&1

reg delete "HKCU\Software\Classes\*\shell\CopyWSLPath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\shell\CopyWSLPath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Directory\Background\shell\CopyWSLPath" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Drive\shell\CopyWSLPath" /f >nul 2>&1

:: Remove installed scripts
set "DST=%LocalAppData%\WSLTools\"
if exist "%DST%" rmdir /s /q "%DST%"

echo.
echo   Uninstalled successfully!
echo   - "Open in WSL" and "Copy WSL Path" removed from right-click menu.
echo   - Removed scripts from: %DST%
echo.
pause
