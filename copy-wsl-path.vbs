' Silent launcher — runs copy-wsl-path.ps1 with zero visible windows
' The 0 in .Run means vbHide (completely invisible)
' Version: 1.0.0

If WScript.Arguments.Count = 0 Then WScript.Quit 1

Set shell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
ps1 = scriptDir & "\copy-wsl-path.ps1"
arg = WScript.Arguments(0)

' Fix Windows command-line backslash escaping:
' A trailing \ before a closing quote is consumed as an escape character,
' so "C:\" becomes C:" — restore the backslash.
If Len(arg) > 0 And Right(arg, 1) = """" Then
    arg = Left(arg, Len(arg) - 1) & "\"
End If

shell.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & ps1 & """ """ & arg & """", 0, False
