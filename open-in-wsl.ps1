param(
    [string]$Path
)

# Convert Windows path to WSL path and open Windows Terminal there
# C:\Users\foo\bar → wsl cd /mnt/c/Users/foo/bar

if (-not $Path) { exit 1 }

# Resolve to full path
$FullPath = [System.IO.Path]::GetFullPath($Path)

# If it's a file, use its parent directory
if (Test-Path $FullPath -PathType Leaf) {
    $FullPath = Split-Path $FullPath -Parent
}

# Convert: C:\Users\foo → /mnt/c/Users/foo
$DriveLetter = $FullPath.Substring(0, 1).ToLower()
$Rest = $FullPath.Substring(3).Replace('\', '/')
$WslPath = "/mnt/$DriveLetter/$Rest"

# Open Windows Terminal with WSL at that path
Start-Process wt.exe -ArgumentList "wsl.exe --cd `"$WslPath`""
