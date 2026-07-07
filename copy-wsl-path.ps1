function ConvertTo-WslPath {
    param(
        [string]$Path
    )

    if (-not $Path) {
        return ''
    }

    # Strip leading/trailing whitespace
    $Path = $Path.Trim()
    if (-not $Path) {
        return ''
    }

    # Strip \\?\ prefix (Win32 long path namespace)
    if ($Path -match '^\\\\\?\\') {
        $Path = $Path.Substring(4)
    }

    # Strip \\.\ prefix (device namespace)
    if ($Path -match '^\\\\\.\\') {
        $Path = $Path.Substring(4)
    }

    # Normalize all backslashes to forward slashes for parsing
    $fixed = $Path -replace '\\', '/'

    # Rule 1: UNC path //wsl.localhost/<distro>/<rest> → /<rest>
    if ($fixed -match '^//wsl\.localhost/([^/]+)(?:/(.*))?$') {
        $rest = if ($matches[2]) { $matches[2] } else { '' }
        return "/$rest"
    }

    # Rule 2: Non-WSL network share \\... (didn't match wsl.localhost) → pass through unchanged
    if ($Path -match '^\\\\') {
        return $Path
    }

    # Collapse multiple consecutive slashes
    $fixed = $fixed -replace '/{2,}', '/'

    # Rule 3: Windows drive path <drive>:/<rest> → /mnt/<drive>/<rest>
    if ($fixed -match '^([A-Za-z]):/(.*)') {
        $drive = $matches[1].ToLower()
        $rest = $matches[2]
        return "/mnt/$drive/$rest"
    }

    # Rule 4: Already a Linux path → pass through
    if ($fixed -match '^/') {
        return $fixed
    }

    # Fallback: return original path unchanged
    return $Path
}

# When run directly (not dot-sourced), copy result to clipboard
if ($MyInvocation.InvocationName -ne '.') {
    $result = ConvertTo-WslPath -Path $args[0]
    if ($result) {
        Set-Clipboard -Value $result
    }
}
