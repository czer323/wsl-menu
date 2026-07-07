param(
    [string]$Path
)

# Open in WSL — launches Windows Terminal with WSL cd'd to the given path.
# Uses ConvertTo-WslPath from copy-wsl-path.ps1 for robust path conversion.
# Version: 1.0.0

if (-not $Path) { exit 1 }
if ($Path -match '"$') {
    $Path = $Path -replace '"$', '\'
}

# Dot-source the shared conversion function
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\copy-wsl-path.ps1"

# If it's a file, use its parent directory
try {
    if (Test-Path $Path -PathType Leaf) {
        $Path = Split-Path $Path -Parent
    }
} catch {
    # Path may contain illegal characters — pass through to converter
}

# Convert to WSL path using the shared, tested conversion function
$WslPath = ConvertTo-WslPath -Path $Path
if (-not $WslPath) { exit 1 }

# Verify Windows Terminal is available
if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Windows Terminal (wt.exe) not found.`n`nInstall it from the Microsoft Store.",
        "Open in WSL — Error",
        "OK",
        "Error"
    ) | Out-Null
    exit 1
}

# Open Windows Terminal with WSL at that path
# The -- separator ensures wt.exe passes --cd to wsl.exe, not interpreting it itself
Start-Process wt.exe -ArgumentList "-- wsl.exe --cd `"$WslPath`""
