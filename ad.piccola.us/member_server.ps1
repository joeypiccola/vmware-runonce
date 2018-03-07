Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\helperfunctions.ps1'

# base function calls
Rename-CDROM
New-MyFolder
Set-KMS

$diskconfig = Get-Content -Path c:\deploy\diskcfg.json | ConvertFrom-Json
if ($diskconfig.disks.count -gt 0)
{
    Set-Disks -DisksConfig $diskconfig
}

# clean up
Set-FinRunOnce
Stop-Transcript
# reboot
Reboot-System