<#
.SYNOPSIS
Test suite for ConvertTo-WslPath

Run: pwsh test-conversion.ps1
#>

# Import conversion function
. .\copy-wsl-path.ps1

$pass = 0
$fail = 0
$results = @()

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

Test-Conversion -InputPath "C:\Users\czer3\file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "basic C:\ path"
Test-Conversion -InputPath "D:\data\stuff.txt" -Expected "/mnt/d/data/stuff.txt" -Label "D:\ drive"
Test-Conversion -InputPath "C:\" -Expected "/mnt/c/" -Label "drive root C:\"
Test-Conversion -InputPath "C:\Users\czer3\My Projects\file.ts" -Expected "/mnt/c/Users/czer3/My Projects/file.ts" -Label "spaces in path"
Test-Conversion -InputPath "C:\Users\czer3\.hidden\config" -Expected "/mnt/c/Users/czer3/.hidden/config" -Label "dotfiles/hidden dirs"
Test-Conversion -InputPath "C:\Users\czer3\深い\ファイル.txt" -Expected "/mnt/c/Users/czer3/深い/ファイル.txt" -Label "unicode characters"
Test-Conversion -InputPath "c:\users\czer3\file.ts" -Expected "/mnt/c/users/czer3/file.ts" -Label "lowercase drive letter"
Test-Conversion -InputPath "C:/Users/czer3/file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "forward slashes (C:/...)"
Test-Conversion -InputPath "C:/Users/czer3\mixed.ts" -Expected "/mnt/c/Users/czer3/mixed.ts" -Label "mixed forward/back slashes"
Test-Conversion -InputPath "C:\Users\czer3\file.ts " -Expected "/mnt/c/Users/czer3/file.ts" -Label "trailing whitespace"
Test-Conversion -InputPath " C:\Users\czer3\file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "leading whitespace"

Write-Host "`n=== WSL UNC paths ===" -ForegroundColor Cyan

Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\czer3\file.ts" -Expected "/home/czer3/file.ts" -Label "basic UNC"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\czer3\My Projects" -Expected "/home/czer3/My Projects" -Label "UNC with spaces"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\home\czer3\" -Expected "/home/czer3/" -Label "UNC trailing backslash"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\" -Expected "/" -Label "UNC distro root"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04" -Expected "/" -Label "UNC distro root no trailing slash"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\mnt\c\Users\czer3\file" -Expected "/mnt/c/Users/czer3/file" -Label "UNC to /mnt/c/ via WSL share"
Test-Conversion -InputPath "\\wsl.localhost\Ubuntu-26.04\tmp\test" -Expected "/tmp/test" -Label "UNC to /tmp/"
Test-Conversion -InputPath "//wsl.localhost/Ubuntu-26.04/home/czer3/file" -Expected "/home/czer3/file" -Label "forward-slash UNC"

Write-Host "`n=== Long path / device prefix ===" -ForegroundColor Cyan

Test-Conversion -InputPath "\\?\C:\Users\czer3\file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "\\?\ prefix (long path)"
Test-Conversion -InputPath "\\?\C:\" -Expected "/mnt/c/" -Label "\\?\ prefix drive root"
Test-Conversion -InputPath "\\.\C:\Users\czer3\file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "\\.\ prefix (device namespace)"

Write-Host "`n=== Edge cases ===" -ForegroundColor Cyan

Test-Conversion -InputPath "" -Expected "" -Label "empty string"
Test-Conversion -InputPath "\\server\share\file" -Expected "\\server\share\file" -Label "non-WSL network share (pass through)"
Test-Conversion -InputPath "/home/czer3/file.ts" -Expected "/home/czer3/file.ts" -Label "already Linux path"
Test-Conversion -InputPath "/mnt/c/Users/czer3/file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "already /mnt/c/ path"
Test-Conversion -InputPath "C:\\Users\\czer3\\file.ts" -Expected "/mnt/c/Users/czer3/file.ts" -Label "escaped double backslashes"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Results: $pass passed, $fail failed" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if ($fail -gt 0) { exit 1 }
