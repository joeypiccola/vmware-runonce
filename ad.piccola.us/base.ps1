Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'

# base function calls
Rename-CDROM
New-MyFolder
Set-KMS
#Install-BaseModules
Configure-OfflineDisks

# clean up
Set-FinRunOnce
Stop-Transcript
# reboot
Reboot-System