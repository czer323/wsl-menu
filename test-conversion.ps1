<#
.SYNOPSIS
Test suite for ConvertTo-WslPath

Run: pwsh test-conversion.ps1
#>

# Import conversion function
. .\copy-wsl-path.ps1

$pass = 0
$fail = 0

function Test-Conversion {
    param([string]$InputPath, [string]$Expected, [string]$Label)

    $actual = ConvertTo-WslPath -Path $InputPath
    if ($actual -eq $Expected) {
        $script:pass++
        Write-Host "  PASS" -ForegroundColor Green -NoNewline
        Write-Host "  $Label"
    } else {
        $script:fail++
        Write-Host "  FAIL" -ForegroundColor Red -NoNewline
        Write-Host "  $Label"
        Write-Host "       Input:    '$InputPath'" -ForegroundColor DarkGray
        Write-Host "       Expected: '$Expected'" -ForegroundColor DarkGray
        Write-Host "       Got:      '$actual'" -ForegroundColor DarkGray
    }
}

Write-Host "=== Windows drive paths ===" -ForegroundColor Cyan

Test-Conversion -InputPath "C:\Users\testuser\file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "basic C:\ path"
Test-Conversion -InputPath "D:\data\stuff.txt" -Expected "/mnt/d/data/stuff.txt" -Label "D:\ drive"
Test-Conversion -InputPath "C:\" -Expected "/mnt/c/" -Label "drive root C:\"
Test-Conversion -InputPath "C:\Users\testuser\My Projects\file.ts" -Expected "/mnt/c/Users/testuser/My Projects/file.ts" -Label "spaces in path"
Test-Conversion -InputPath "C:\Users\testuser\.hidden\config" -Expected "/mnt/c/Users/testuser/.hidden/config" -Label "dotfiles/hidden dirs"
Test-Conversion -InputPath "C:\Users\testuser\深い\ファイル.txt" -Expected "/mnt/c/Users/testuser/深い/ファイル.txt" -Label "unicode characters"
Test-Conversion -InputPath "c:\users\testuser\file.ts" -Expected "/mnt/c/users/testuser/file.ts" -Label "lowercase drive letter"
Test-Conversion -InputPath "C:/Users/testuser/file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "forward slashes (C:/...)"
Test-Conversion -InputPath "C:/Users/testuser\mixed.ts" -Expected "/mnt/c/Users/testuser/mixed.ts" -Label "mixed forward/back slashes"
Test-Conversion -InputPath "C:\Users\testuser\file.ts " -Expected "/mnt/c/Users/testuser/file.ts" -Label "trailing whitespace"
Test-Conversion -InputPath " C:\Users\testuser\file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "leading whitespace"

Write-Host "`n=== WSL UNC paths ===" -ForegroundColor Cyan

Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\testuser\file.ts" -Expected "/home/testuser/file.ts" -Label "basic UNC"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\testuser\My Projects" -Expected "/home/testuser/My Projects" -Label "UNC with spaces"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\testuser\" -Expected "/home/testuser/" -Label "UNC trailing backslash"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\" -Expected "/" -Label "UNC distro root"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04" -Expected "/" -Label "UNC distro root no trailing slash"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\mnt\c\Users\testuser\file" -Expected "/mnt/c/Users/testuser/file" -Label "UNC to /mnt/c/ via WSL share"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\tmp\test" -Expected "/tmp/test" -Label "UNC to /tmp/"
Test-Conversion -InputPath "//wsl.localhost/Ubuntu-26.04/home/testuser/file" -Expected "/home/testuser/file" -Label "forward-slash UNC"

Write-Host "`n=== Long path / device prefix ===" -ForegroundColor Cyan

Test-Conversion -InputPath "\\?\C:\Users\testuser\file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "\\?\ prefix (long path)"
Test-Conversion -InputPath "\\?\C:\" -Expected "/mnt/c/" -Label "\\?\ prefix drive root"
Test-Conversion -InputPath "\\.\C:\Users\testuser\file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "\\.\ prefix (device namespace)"

Write-Host "`n=== Long path UNC namespace ===" -ForegroundColor Cyan

Test-Conversion -InputPath "\\?\UNC\wsl.localhost\Ubuntu\home\testuser\file.ts" -Expected "/home/testuser/file.ts" -Label "\\?\UNC\ wsl.localhost path"
Test-Conversion -InputPath "\\?\UNC\server\share\file" -Expected "\\server\share\file" -Label "\\?\UNC\ non-WSL share (pass through)"

Write-Host "`n=== Edge cases ===" -ForegroundColor Cyan

Test-Conversion -InputPath "" -Expected "" -Label "empty string"
Test-Conversion -InputPath "\\server\share\file" -Expected "\\server\share\file" -Label "non-WSL network share (pass through)"
Test-Conversion -InputPath "/home/testuser/file.ts" -Expected "/home/testuser/file.ts" -Label "already Linux path"
Test-Conversion -InputPath "/mnt/c/Users/testuser/file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "already /mnt/c/ path"
Test-Conversion -InputPath "C:\\Users\\testuser\\file.ts" -Expected "/mnt/c/Users/testuser/file.ts" -Label "escaped double backslashes"

Write-Host "`n=== Drive root edge cases ===" -ForegroundColor Cyan

Test-Conversion -InputPath "C:" -Expected "/mnt/c/" -Label "drive letter only (C:)"
Test-Conversion -InputPath 'C:"' -Expected 'C:"' -Label "drive letter trailing quote (falls back)"
Test-Conversion -InputPath "D:" -Expected "/mnt/d/" -Label "drive letter only (D:)"
Test-Conversion -InputPath "Z:" -Expected "/mnt/z/" -Label "drive letter only (Z:)"

Write-Host "`n=== Debug log format ===" -ForegroundColor Cyan

# Backup existing debug state
$savedDebug = [Environment]::GetEnvironmentVariable('WSLPATH_DEBUG', 'User')
$logFile = [Environment]::GetFolderPath('LocalApplicationData') + '\WSLTools\debug.log'
if (Test-Path $logFile) { Remove-Item $logFile -Force }

[Environment]::SetEnvironmentVariable('WSLPATH_DEBUG', '1', 'User')
ConvertTo-WslPath -Path "C:\Users\testuser\test.ts" | Out-Null
[Environment]::SetEnvironmentVariable('WSLPATH_DEBUG', $savedDebug, 'User')

if (Test-Path $logFile) {
    $logLine = Get-Content $logFile -Tail 1
    if ($logLine -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \| .+ → .+$') {
        $script:pass++
        Write-Host "  PASS  debug log format"
    } else {
        $script:fail++
        Write-Host "  FAIL  debug log format"
        Write-Host "       Got: '$logLine'" -ForegroundColor DarkGray
    }
} else {
    $script:fail++
    Write-Host "  FAIL  debug log format — no log file created"
}
Remove-Item $logFile -Force -ErrorAction SilentlyContinue

Write-Host "`n=== Direct PowerShell pipeline (no VBS) ===" -ForegroundColor Cyan


$result = ConvertTo-WslPath -Path "C:"
if ($result -eq "/mnt/c/") {
    $script:pass++
    Write-Host "  PASS  direct C:"
} else {
    $script:fail++
    Write-Host "  FAIL  direct C:"
    Write-Host "       Got: '$result'" -ForegroundColor DarkGray
}

$result = ConvertTo-WslPath -Path "C:\"
if ($result -eq "/mnt/c/") {
    $script:pass++
    Write-Host "  PASS  direct C:\"
} else {
    $script:fail++
    Write-Host "  FAIL  direct C:\"
    Write-Host "       Got: '$result'" -ForegroundColor DarkGray
}

$result = ConvertTo-WslPath -Path 'C:"'
if ($result -eq 'C:"') {
    $script:pass++
    Write-Host "  PASS  direct C:"" (trailing quote preserved)"
} else {
    $script:fail++
    Write-Host "  FAIL  direct C:"" (trailing quote preserved)"
    Write-Host "       Got: '$result'" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan
Write-Host "  Passed: $pass" -ForegroundColor Green
Write-Host "  Failed: $fail" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
if ($fail -gt 0) { exit 1 }
