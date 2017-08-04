Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
clear
Write-Host "####    Installing Chocolatey and GIT    ####" -ForegroundColor Green
sleep -Seconds 5
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install git -y
sleep -Seconds 5
Stop-Transcript