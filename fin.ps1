Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\helperfunctions.ps1'

Update-Networking
Remove-Deployment
Stop-Transcript