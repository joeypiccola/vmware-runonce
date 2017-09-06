Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'

#oh yea, creds and load the module (auto load does not work in this context)
ipmo psrabbitmq
$secpasswd = ConvertTo-SecureString "joey" -AsPlainText -Force
$CredRabbit = New-Object System.Management.Automation.PSCredential ("joey", $secpasswd)

Send-RabbitMqMessage -ComputerName rabbitmq.ad.piccola.us -Exchange 'deployments' -Key 'vlanmoverequests' -Persistent -Credential $CredRabbit -InputObject "$env:computername"
Uninstall-BaseModules
Uninstall-BasePackages

Remove-Deployment
Stop-Transcript