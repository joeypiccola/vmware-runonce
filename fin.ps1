Start-Transcript  -Path C:\deploy\vmwaredeployment.txt -Append -Force
. 'c:\deploy\config\base.ps1'
Send-RabbitMqMessage -ComputerName rabbitmq.ad.piccola.us -Exchange 'deployments' -Key 'vlanmoverequests' -Persistent -Credential $CredRabbit -InputObject "$env:computername"

Remove-Deployment
Stop-Transcript