' Silent launcher — runs copy-wsl-path.ps1 with zero visible windows
' The 0 in .Run means vbHide (completely invisible)

Set shell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\copy-wsl-path.ps1"
arg = WScript.Arguments(0)

shell.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1 & """ """ & arg & """", 0, False
