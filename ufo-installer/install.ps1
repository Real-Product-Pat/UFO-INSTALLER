# ...existing code...
sc.exe start  "UFO2Service"

# 8. Create a desktop shortcut Dad can click to talk
# -----------------------------------------------
$wsh   = New-Object -ComObject WScript.Shell
$desk  = [Environment]::GetFolderPath('CommonDesktopDirectory')   # C:\Users\Public\Desktop
$link  = $wsh.CreateShortcut("$desk\Talk to Computer.lnk")

# — Target: pythonw (no console) running voice_shell.py inside the venv
$pyExe = "$env:ProgramData\UFO\venv\Scripts\pythonw.exe"
$script= "$env:ProgramData\UFO\extras\voice_shell.py"

$link.TargetPath       = $pyExe
$link.Arguments        = "`"$script`""
$link.WorkingDirectory = "$env:ProgramData\UFO"
$link.IconLocation     = "$env:ProgramData\UFO\extras\icons\ufo.ico"
$link.WindowStyle      = 7          # Minimized
$link.Description      = "Click once, then speak after the beep."
$link.Save()