# WSL Tools — Windows Explorer Context Menu

Adds two items to the right-click menu in Windows Explorer:

- **Copy WSL Path** — copies the WSL path to clipboard (e.g. `/mnt/c/Users/foo/project` or `/home/foo/file`)
- **Open in WSL** — opens Windows Terminal with WSL `cd`'d to that path

Works on files, folders, drives, and folder backgrounds (empty space).

## Install

1. Double-click **`install.bat`**

That's it. Scripts are copied to `%LocalAppData%\WSLTools\` automatically. And added to registry as current user.  You can delete this folder after installing.

## Uninstall

1. Double-click **`uninstall.bat`**

This will remove both registry entries and installed scripts.

## Path Conversions

| You right-click | You get |
|---|---|
| `C:\Users\foo\project` | `/mnt/c/Users/foo/project` |
| `D:\data\file.txt` | `/mnt/d/data/file.txt` |
| `C:\` | `/mnt/c/` |
| `\\wsl.localhost\Ubuntu\home\foo\.bashrc` | `/home/foo/.bashrc` |
| `\\wsl.localhost\Ubuntu\tmp\test` | `/tmp/test` |
| `\\?\C:\long\path` (Win32 long path) | `/mnt/c/long/path` |
| Mixed forward/back slashes | Normalized automatically |
| Leading/trailing whitespace | Trimmed automatically |
| Non-WSL network shares (\\server\share) | Pass through unchanged |
| Already a Linux path (`/home/foo`) | Pass through unchanged |

## Requires

- Windows 11
- Windows Terminal (`wt.exe`) — pre-installed on Windows 11 (Open in WSL only)
- WSL2 installed with a default distro (Open in WSL only)

**Copy WSL Path** does not need WSL or Windows Terminal — it uses pure PowerShell string conversion.

## Debug

Set `WSLPATH_DEBUG` user environment variable to any value to log every path conversion to `%LocalAppData%\WSLTools\debug.log`.

Example log entries:

```
2026-07-07 14:22:01 | C:\Users\czer3\file.ts → /mnt/c/Users/czer3/file.ts
2026-07-07 14:22:05 | \\wsl.localhost\Ubuntu-26.04\home\czer3\.bashrc → /home/czer3/.bashrc
2026-07-07 14:22:09 | C:\ → /mnt/c/
2026-07-07 14:22:12 | \\server\share\file → \\server\share\file
```

```powershell
# Enable
[Environment]::SetEnvironmentVariable('WSLPATH_DEBUG', '1', 'User')

# Disable
[Environment]::SetEnvironmentVariable('WSLPATH_DEBUG', $null, 'User')
```

Restart Explorer (or log out/in) after changing. The log file grows unbounded — clear it manually.
