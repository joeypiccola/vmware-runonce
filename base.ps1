function New-MyFolder
{
    # something simple
    New-Item -ItemType Directory -Path c:\MyFolder
}

Function Rename-CDROM
{
    $drive = gwmi win32_volume -Filter "DriveType = '5'"
    $drive.DriveLetter = "X:"
    $drive.put()
}

function Set-FinRunOnce
{
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
    Remove-Item -Force -Recurse 'C:\deploy\config'
}