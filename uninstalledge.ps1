
# Code to uninstall microsoft edge browser
#locates edge program files (x86) and unninstall edge's installer

$UninstallEdge
    [String] $ProgramX86 = "$env:SystemDrive\Program Files (x86)"
    [String] $edgepath = "$ProgramX86\Microsoft\Edge\Application\*.*.*.*\Installer"
    [String] $arguments = "--uninstall --system-level --verbose-logging --force-uninstall"

  # locates edge application 

    if (Test-Path "$ProgramX86\Microsoft\Edge\Application")

    {
        Write-Host "Uninstalling " -NoNewline
        Write-Host "Microsoft Edge" -ForegroundColor Cyan
        Start-Process -FilePath "$edgepath\setup.exe" -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait
        "\MicrosoftEdgeUpdateTaskMachineUA", "\MicrosoftEdgeUpdateTaskMachineCore" | ForEach-Object {
            Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue | Out-Null
        }

        # uninstall edge registry keys from system 

        @("edgeupdatem", "edgeupdate", "MicrosoftEdgeElevationService") | ForEach-Object {
            Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Stop-Service -Name $_ -NoWait -Force -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Host "Clearing" -NoNewline
        Write-Host "Microsoft Edge's" -NoNewline -ForegroundColor Cyan
        Write-Host " registry keys!"

        [Array] $RegistryPaths = @(
            "HKCU:\SOFTWARE\Microsoft\Edge", "HKCU:\SOFTWARE\Microsoft\EdgeUpdate", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate"
        ) 

        Foreach($Path in $RegistryPaths){
            Remove-Item -Path $Path -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
        }

        #removes edge's system files

        Write-Host "Removing " -NoNewline
        Write-Host "Microsoft Edge's" -NoNewline -ForegroundColor Cyan
        Write-Host " files!"

        Get-ChildItem -Path "$ProgramX86\Microsoft\Edge" -Force | ForEach-Object{
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }

        Get-ChildItem -Path "$ProgramX86\Microsoft\EdgeUpdate" -Force | ForEach-Object{
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }

        Get-ChildItem -Path "$ProgramX86\Microsoft\Temp" -Force | ForEach-Object{
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }
    
        #Removes Edge update

        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdate"){
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdate" -ErrorAction SilentlyContinue -Force | Out-Null
        }

        if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdatem"){
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\edgeupdatem" -ErrorAction SilentlyContinue -Force | Out-Null
        }

        New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name DisableEdgeDesktopShortcutCreation -PropertyType DWORD -Value 1
        Write-Host "Microsoft Edge " -NoNewline -ForegroundColor Cyan
        Write-Host "has been removed"
    }

    else

    {
        Write-Host "Microsoft Edge " -NoNewline -ForegroundColor Cyan
        Write-Host "is not even installed?"
    }


    Stop-Process $PID -Force
