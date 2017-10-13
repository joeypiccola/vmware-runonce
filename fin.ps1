Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'

#Uninstall-BaseModules
Uninstall-BasePackages

#oh yea, creds and load the module (auto load does not work in this context)
ipmo psrabbitmq
$secpasswd = ConvertTo-SecureString "joey" -AsPlainText -Force
$CredRabbit = New-Object System.Management.Automation.PSCredential ("joey", $secpasswd)

Send-RabbitMqMessage -ComputerName rabbitmq.ad.piccola.us -Exchange 'deployments' -Key 'vlanmoverequests' -Persistent -Credential $CredRabbit -InputObject "$env:computername"
sleep -Seconds 10
Update-Networking

Remove-Deployment
Stop-Transcript