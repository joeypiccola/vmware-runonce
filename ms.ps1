﻿Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'

# base function calls
Rename-CDROM
New-MyFolder

# clean up
Set-FinRunOnce
Stop-Transcript
# reboot
shutdown /r /t 60 /c "reboot post deployment"