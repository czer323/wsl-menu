# ConvertTo-WslPath — shared path conversion for WSL context menu tools
# Version: 1.0.0

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

    # Defensive fix: Windows command-line parser consumes \ before " as escape
    # so "C:\" arrives as C:" — restore the backslash
    if ($Path -match '"$') {
        $Path = $Path -replace '"$', '\'
    }

    $inputPath = $Path  # snapshot for debug log

    # Strip \\?\ prefix (Win32 long path namespace)
    if ($Path -match '^\\\\\?\\') {
        $Path = $Path.Substring(4)
        # \\?\UNC\server\share → \\server\share
        if ($Path -match '^UNC\\') {
            $Path = '\\' + $Path.Substring(4)
        }
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
        Write-DebugLog -InputPath $inputPath -Result $result
        return $result
    }

    # Rule 2: Non-WSL network share \\... (didn't match wsl.localhost) → pass through unchanged
    if ($Path -match '^\\\\') {
        Write-DebugLog -InputPath $inputPath -Result $Path
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
        Write-DebugLog -InputPath $inputPath -Result $result
        return $result
    }

    # Rule 4: Already a Linux path → pass through
    if ($fixed -match '^/') {
        Write-DebugLog -InputPath $inputPath -Result $fixed
        return $fixed
    }

    # Fallback: return original path unchanged
    Write-DebugLog -InputPath $inputPath -Result $Path
    return $Path
}

function Write-DebugLog {
    param([string]$InputPath, [string]$Result)

    $debug = [Environment]::GetEnvironmentVariable('WSLPATH_DEBUG', 'User')
    if (-not $debug) {
        return
    }

    $logDir = [Environment]::GetFolderPath('LocalApplicationData') + '\WSLTools'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $logFile = "$logDir\debug.log"
    # Cap log at 1 MB — start fresh if exceeded
    if (Test-Path $logFile) {
        if ((Get-Item $logFile).Length -gt 1MB) {
            Remove-Item $logFile -Force
        }
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp | $InputPath → $Result" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# When run directly (not dot-sourced), copy result to clipboard
if ($MyInvocation.InvocationName -ne '.') {
    $result = ConvertTo-WslPath -Path $args[0]
    if ($result) {
        Set-Clipboard -Value $result
    }
}
