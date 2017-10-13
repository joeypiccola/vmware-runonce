function New-MyFolder
{
    Write-Verbose "running new-myfolder"
    # something simple
    New-Item -ItemType Directory -Path c:\MyFolder
}

Function Rename-CDROM
{
    Write-Verbose "running rename-cdrom"
    $drive = gwmi win32_volume -Filter "DriveType = '5'"
    $drive.DriveLetter = "X:"
    $drive.put()
}

function Set-FinRunOnce
{
    Write-Verbose "running set-finrunonce"
    $RunOnceParams = @{
        Path         = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        Name         = "RebootNotify"
        PropertyType = "String"
        Value        = "c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File c:\deploy\config\fin.ps1 -ExecutionPolicy Unrestricted"
    }

    New-ItemProperty @RunOnceParams
}

function Remove-Deployment
{
    Write-Verbose "running running remove-deployment"
    Remove-Item -Force -Recurse 'C:\deploy\config'
}

function Reboot-System
{
    Write-Verbose "running reboot-system"
    # if this folder exists then assume MDT or SCCM built the server. Let the TS handle the reboot and auto logon (i.e. LogonCount)
    if (!(Test-Path -Path C:\MININT))
    {    
        shutdown /r /t 60 /c "Post Config Reboot..."
    }
}

function Set-KMS
{
    Write-Verbose "running set-kms"
    slmgr.vbs /skms mono.piccola.us:1688
    slmgr.vbs /ato
}

function Install-BaseModules
{
    Install-Module -Name psrabbitmq -Confirm:$false -Force
}

function Uninstall-BaseModules
{
    # loop this at some point maybe
    Remove-Module -Name psrabbitmq -Force
    Uninstall-Module -Name psrabbitmq -Confirm:$false -Force
}

function Uninstall-BasePackages
{
    choco uninstall git git.install -y
}

function Update-Networking
{
    # import the json file
    $netcfg_import = Get-Content -Path C:\deploy\netfcg.json | ConvertFrom-Json
    # get the nic that currenlty has the DHCP address (need to imporve on this detection)
    $nic = Get-WmiObject win32_networkadapterconfiguration |  ?{$_.dnshostname -ne $null}
    # set static, gateway, netmase an dns
    $nic.EnableStatic($netcfg_import.ip, $netcfg_import.netmask)
    $nic.SetGateways($netcfg_import.gateway)
    $nic.SetDNSServerSearchOrder($netcfg_import.dns)
    # enable dyn dns registration and full dns registration
    $nic.SetDynamicDNSRegistration($true)
    $nic.FullDNSRegistrationEnabled
    # get the nic again but in the networkadpater class (find it by the index from win32_networkadapterconfiguration
    $net = Get-WmiObject win32_networkadapter | ?{$_.deviceid -eq $nic.index}
    # disable \ enabled the nic
    $net.Disable()
    sleep -Seconds 5
    $net.Enable()
    sleep -Seconds 15
    # register dns
    ipconfig /registerdns
}