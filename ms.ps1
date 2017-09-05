Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'

# base function calls
Rename-CDROM
New-MyFolder
Set-KMS

# clean up
Set-FinRunOnce
Stop-Transcript
# reboot
#if ((Get-WmiObject -Class win32_computersystem).Manufacturer -eq 'VMware, Inc.')
# if this folder exists then assume MDT or SCCM built the server. Let the TS handle the reboot and auto logon (i.e. LogonCount)
Reboot-System