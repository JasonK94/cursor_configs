# update_tool.ps1 - Updates the cursor_configs tool by pulling the latest changes from the git repository.

# Get the directory where this script is located.
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath -Parent

# The central repository path is one level up from the 'scripts' directory.
$centralRepoPath = Split-Path $scriptDir -Parent

# Change the current location to the central repository.
try {
    Set-Location -Path $centralRepoPath -ErrorAction Stop
    Write-Host "Checking for updates in '$centralRepoPath'..." -ForegroundColor Cyan

    # Execute git pull and capture the output.
    $output = git pull 2>&1

    if ($LASTEXITCODE -eq 0) {
        if ($output -like "*Already up to date.*") {
            Write-Host "cursor_configs is already up to date." -ForegroundColor Green
        }
        else {
            Write-Host "cursor_configs has been successfully updated." -ForegroundColor Green
            Write-Host $output
        }
    }
    else {
        Write-Host "An error occurred while updating." -ForegroundColor Red
        Write-Host $output
    }
}
catch {
    Write-Host "Error: Could not navigate to the repository path '$centralRepoPath'. Is the tool installed correctly?" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
