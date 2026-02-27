@echo off
:: Install "Open in WSL" and "Copy WSL Path" context menu items
:: Double-click to run from any folder. Copies scripts to %LocalAppData%\WSLTools.

:: Check for admin rights, re-launch elevated if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Source = folder where this bat lives. Target = fixed install location.
set "SRC=%~dp0"
set "DST=%LocalAppData%\WSLTools\"

:: Copy scripts to install location
if not exist "%DST%" mkdir "%DST%"
copy /y "%SRC%open-in-wsl.ps1" "%DST%" >nul
copy /y "%SRC%open-in-wsl.vbs" "%DST%" >nul
copy /y "%SRC%copy-wsl-path.ps1" "%DST%" >nul
copy /y "%SRC%copy-wsl-path.vbs" "%DST%" >nul

:: === Open in WSL ===

reg add "HKCR\*\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCR\*\shell\OpenInWSL" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\*\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%1\"" /f >nul

reg add "HKCR\Directory\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCR\Directory\shell\OpenInWSL" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\Directory\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%1\"" /f >nul

reg add "HKCR\Directory\Background\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCR\Directory\Background\shell\OpenInWSL" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\Directory\Background\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%V\"" /f >nul

:: === Copy WSL Path ===

reg add "HKCR\*\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCR\*\shell\CopyWSLPath" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\*\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%1\"" /f >nul

reg add "HKCR\Directory\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCR\Directory\shell\CopyWSLPath" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\Directory\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%1\"" /f >nul

reg add "HKCR\Directory\Background\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCR\Directory\Background\shell\CopyWSLPath" /v "Icon" /d "imageres.dll,-5302" /f >nul
reg add "HKCR\Directory\Background\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%V\"" /f >nul

echo.
echo   Installed successfully!
echo   - "Open in WSL" and "Copy WSL Path" added to right-click menu.
echo   - Scripts installed to: %DST%
echo.
pause
