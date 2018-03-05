Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\helperfunctions.ps1'

Uninstall-BasePackages
Update-Networking
Remove-Deployment
Stop-Transcript