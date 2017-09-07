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