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
    $netcfg_import = Get-Content -Path C:\deploy\netcfg.json | ConvertFrom-Json
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

Function Configure-OfflineDisks
{ 
 
    #Check for offline disks on server. 
    $offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} 
     
    #If offline disk(s) exist 
    if($offlinedisk.count -eq 1) 
    { 
     
        Write-Output "Following Offline disk(s) found..Trying to bring Online." 
        $offlinedisk 
         
        #for all offline disk(s) found on the server 
        foreach($offdisk in $offlinedisk) 
        { 
     
            $offdiskS = $offdisk.Substring(2,6) 
            Write-Output "Enabling $offdiskS" 
#Creating command parameters for selecting disk, making disk online and setting off the read-only flag. 
$OnlineDisk = @" 
select $offdiskS
attributes disk clear readonly
online disk
select $offdiskS
clean
convert gpt
create partition primary
format quick fs=ntfs label="Data" unit=4096
assign letter="D"
"@ 
            #Sending parameters to diskpart 
            $noOut = $OnlineDisk | diskpart 
            sleep 5 
     
       } 
 
        #If selfhealing failed throw the alert. 
        if(($offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} )) 
        { 
         
            Write-Output "Failed to bring the following disk(s) online" 
            $offlinedisk 
 
        } 
        else 
        { 
     
            Write-Output "Disk(s) are now online." 
 
        } 
 
    }
    elseif ($offlinedisk.count -gt 1)
    {
        Write-Output "Following Offline disk(s) found..Trying to bring Online." 
        $offlinedisk 
         
        #for all offline disk(s) found on the server 
        foreach($offdisk in $offlinedisk) 
        { 
     
            $offdiskS = $offdisk.Substring(2,6) 
            Write-Output "Enabling $offdiskS" 
#Creating command parameters for selecting disk, making disk online and setting off the read-only flag. 
$OnlineDisk = @" 
select $offdiskS
attributes disk clear readonly
online disk
select $offdiskS
clean
convert gpt
create partition primary
format quick fs=ntfs label="Data" unit=4096
"@ 
            #Sending parameters to diskpart 
            $noOut = $OnlineDisk | diskpart 
            sleep 5 
     
       } 
 
        #If selfhealing failed throw the alert. 
        if(($offlinedisk = "list disk" | diskpart | where {$_ -match "offline"} )) 
        { 
         
            Write-Output "Failed to bring the following disk(s) online" 
            $offlinedisk 
 
        } 
        else 
        { 
     
            Write-Output "Disk(s) are now online." 
 
        }    
    
    } 
 
    #If no offline disk(s) exist. 
    else 
    { 
 
        #All disk(s) are online. 
        Write-Host "All disk(s) are online!" 
 
    } 
}