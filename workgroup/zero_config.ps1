Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\helperfunctions.ps1'

Uninstall-BasePackages
uninstall-Chocolatey

# base function calls
$diskconfig = Get-Content -Path c:\deploy\diskcfg.json
if ($diskconfig -ne 'nodisks')
{
    $diskjson = $diskconfig | ConvertFrom-Json
    Set-Disks -DisksConfig $diskjson
}

# clean up
Set-FinRunOnce
Stop-Transcript
# reboot
Reboot-System