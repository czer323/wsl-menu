param(
    [string]$Path
)

# Convert Windows path to WSL path
# C:\Users\foo\bar → /mnt/c/Users/foo/bar

if (-not $Path) {
    Write-Host "No path provided."
    exit 1
}

# Resolve to full path (handles relative paths)
$FullPath = [System.IO.Path]::GetFullPath($Path)

# Extract drive letter and convert to lowercase
$DriveLetter = $FullPath.Substring(0, 1).ToLower()

# Get the rest of the path after "C:\"
$Rest = $FullPath.Substring(3)

# Replace backslashes with forward slashes
$Rest = $Rest.Replace('\', '/')

# Build WSL path
$WslPath = "/mnt/$DriveLetter/$Rest"

# Copy to clipboard
Set-Clipboard -Value $WslPath

# Brief toast-style notification via PowerShell
Write-Host "Copied: $WslPath"
