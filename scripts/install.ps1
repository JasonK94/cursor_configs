# install.ps1 - Installs or updates the cursor_configs tool.

# 1. Define Paths
$centralRepoPath = "$HOME\\.cursor_configs"
$repoUrl = "https://github.com/JasonK94/cursor_configs.git"
$initScriptPath = Join-Path $centralRepoPath "scripts\\init_project.ps1"

# 2. Install or Update the Core Repository
if (Test-Path $centralRepoPath) {
    Write-Host "Updating existing cursor_configs repository..."
    try {
        Set-Location $centralRepoPath
        git pull
        Write-Host "Update complete." -ForegroundColor Green
    } catch {
        Write-Host "Error updating repository. Please check for issues and try again." -ForegroundColor Red
        return
    } finally {
        Set-Location $PSScriptRoot
    }
} else {
    Write-Host "Installing cursor_configs for the first time..."
    try {
        git clone $repoUrl $centralRepoPath
        Write-Host "Installation complete." -ForegroundColor Green
    } catch {
        Write-Host "Error cloning repository. Please ensure Git is installed and you have network connectivity." -ForegroundColor Red
        return
    }
}

# 3. Add Command to PowerShell Profile
$profilePath = $PROFILE.CurrentUserCurrentHost
if (-not (Test-Path $profilePath)) {
    Write-Host "Creating PowerShell profile at $profilePath..."
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

$commandName = "Start-CursorProject"
$command = @"

# Adds the Start-CursorProject command for initializing a new project
function $commandName {
    param()
    pwsh -File "$initScriptPath"
}
"@

$profileContent = Get-Content $profilePath -Raw
if ($profileContent -notlike "*$commandName*") {
    Write-Host "Adding '$commandName' command to your PowerShell profile..."
    Add-Content -Path $profilePath -Value $command
    Write-Host "'$commandName' has been added. Please restart your terminal or run '. $profilePath' to use it." -ForegroundColor Green
} else {
    Write-Host "'$commandName' command is already present in your PowerShell profile."
}

Write-Host "Setup finished!" -ForegroundColor Cyan
