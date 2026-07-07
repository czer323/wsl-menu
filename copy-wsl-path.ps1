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

    $inputPath = $Path  # snapshot for debug log

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
        $result = "/$rest"
        Write-DebugLog -Input $inputPath -Result $result
        return $result
    }

    # Rule 2: Non-WSL network share \\... (didn't match wsl.localhost) → pass through unchanged
    if ($Path -match '^\\\\') {
        Write-DebugLog -Input $inputPath -Result $Path
        return $Path
    }

    # Collapse multiple consecutive slashes
    $fixed = $fixed -replace '/{2,}', '/'

    # Rule 3: Windows drive path <drive>:<rest> → /mnt/<drive>/<rest>
    # Matches bare "C:", "C:\path", "C:/path"
    if ($fixed -match '^([A-Za-z]):(?:/(.*))?$') {
        $drive = $matches[1].ToLower()
        $rest = if ($matches[2]) { $matches[2] } else { '' }
        $result = "/mnt/$drive/$rest"
        Write-DebugLog -Input $inputPath -Result $result
        return $result
    }

    # Rule 4: Already a Linux path → pass through
    if ($fixed -match '^/') {
        Write-DebugLog -Input $inputPath -Result $fixed
        return $fixed
    }

    # Fallback: return original path unchanged
    Write-DebugLog -Input $inputPath -Result $Path
    return $Path
}

function Write-DebugLog {
    param([string]$Input, [string]$Result)

    $debug = [Environment]::GetEnvironmentVariable('WSLPATH_DEBUG', 'User')
    if (-not $debug) {
        return
    }

    $logDir = [Environment]::GetFolderPath('LocalApplicationData') + '\WSLTools'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $logFile = "$logDir\debug.log"
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp | $Input → $Result" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# When run directly (not dot-sourced), copy result to clipboard
if ($MyInvocation.InvocationName -ne '.') {
    $result = ConvertTo-WslPath -Path $args[0]
    if ($result) {
        Set-Clipboard -Value $result
    }
}
