@echo off
:: Install "Open in WSL" and "Copy WSL Path" context menu items
:: Double-click to run from any folder. Copies scripts to %LocalAppData%\WSLTools.
:: Installs for current user only — no admin required.

:: Source = folder where this bat lives. Target = fixed install location.
set "SRC=%~dp0"
set "DST=%LocalAppData%\WSLTools\"

:: Copy scripts to install location
if not exist "%DST%" mkdir "%DST%"
copy /y "%SRC%open-in-wsl.ps1" "%DST%" >nul
if errorlevel 1 goto :err_copy
copy /y "%SRC%open-in-wsl.vbs" "%DST%" >nul
if errorlevel 1 goto :err_copy
copy /y "%SRC%copy-wsl-path.ps1" "%DST%" >nul
if errorlevel 1 goto :err_copy
copy /y "%SRC%copy-wsl-path.vbs" "%DST%" >nul
if errorlevel 1 goto :err_copy
goto :reg_add

:err_copy
echo.
echo   ERROR: Could not copy script files.
echo   Make sure install.bat is in the same folder as all .ps1 and .vbs files.
echo   Source folder: %SRC%
pause
exit /b 1

:reg_add

:: === Open in WSL ===

reg add "HKCU\Software\Classes\*\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCU\Software\Classes\*\shell\OpenInWSL" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\*\shell\OpenInWSL" /v "Icon" /d "%%SystemRoot%%\System32\wsl.exe" /f >nul
reg add "HKCU\Software\Classes\*\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\OpenInWSL" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\OpenInWSL" /v "Icon" /d "%%SystemRoot%%\System32\wsl.exe" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInWSL" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInWSL" /v "Icon" /d "%%SystemRoot%%\System32\wsl.exe" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%V\"" /f >nul

reg add "HKCU\Software\Classes\Drive\shell\OpenInWSL" /ve /d "Open in WSL" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\OpenInWSL" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\OpenInWSL" /v "Icon" /d "%%SystemRoot%%\System32\wsl.exe" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\OpenInWSL\command" /ve /d "wscript.exe \"%DST%open-in-wsl.vbs\" \"%%1\"" /f >nul

:: === Copy WSL Path ===

reg add "HKCU\Software\Classes\*\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCU\Software\Classes\*\shell\CopyWSLPath" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\*\shell\CopyWSLPath" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-5356" /f >nul
reg add "HKCU\Software\Classes\*\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\CopyWSLPath" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\CopyWSLPath" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-5356" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\Directory\Background\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyWSLPath" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyWSLPath" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-5356" /f >nul
reg add "HKCU\Software\Classes\Directory\Background\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%V\"" /f >nul

reg add "HKCU\Software\Classes\Drive\shell\CopyWSLPath" /ve /d "Copy WSL Path" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\CopyWSLPath" /v "Position" /d "Bottom" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\CopyWSLPath" /v "Icon" /d "%%SystemRoot%%\System32\imageres.dll,-5356" /f >nul
reg add "HKCU\Software\Classes\Drive\shell\CopyWSLPath\command" /ve /d "wscript.exe \"%DST%copy-wsl-path.vbs\" \"%%1\"" /f >nul

echo.
echo   Scripts installed to: %DST%
echo.
echo   Right-click any file or folder to see:
echo     - Copy WSL Path
echo     - Open in WSL
echo.
pause
