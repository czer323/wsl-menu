# WSL Tools — Windows Explorer Context Menu

Adds two items to the right-click menu in Windows Explorer:

- **Open in WSL** — opens Windows Terminal with WSL `cd`'d to that path
- **Copy WSL Path** — copies the WSL path to clipboard (e.g. `/mnt/c/Users/foo/project`)

Works on files, folders, and folder backgrounds (empty space).

## Install

1. Double-click **`install.bat`** (from any folder)
2. Click "Yes" on the admin prompt

That's it. Scripts are copied to `%LocalAppData%\WSLTools\` automatically. You can delete this folder after installing.

## Uninstall

Double-click **`uninstall.bat`** (from any folder) — removes both registry entries and installed scripts.

## Requires

- Windows 11
- Windows Terminal (`wt.exe`) — pre-installed on Windows 11
- WSL installed with a default distro
