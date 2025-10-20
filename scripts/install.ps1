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
# Use CurrentUserAllHosts to make the command available in all PowerShell terminals (VS Code, Windows Terminal, etc.)
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
    Write-Host "Creating PowerShell profile at $profilePath..."
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

$commandName = "Start-CursorProject"
$aliasName = "cinit" # Changed from SCP to avoid conflict with Secure Copy Protocol
$command = @"

# Adds the Start-CursorProject command for initializing a new project
function $commandName {
    param()
    pwsh -File "$initScriptPath"
}
"@

$aliasCommand = @"
# Sets a short alias for Start-CursorProject
Set-Alias -Name $aliasName -Value $commandName
"@

$profileContent = Get-Content $profilePath -Raw
$changesMade = $false

if ($profileContent -notlike "*function $commandName*") {
    Write-Host "Adding '$commandName' command to your PowerShell profile..."
    Add-Content -Path $profilePath -Value $command
    $changesMade = $true
} else {
    Write-Host "'$commandName' command is already present in your PowerShell profile."
}

if ($profileContent -notlike "*Set-Alias -Name $aliasName*") {
    Write-Host "Adding alias '$aliasName' to your PowerShell profile..."
    Add-Content -Path $profilePath -Value $aliasCommand
    $changesMade = $true
} else {
    Write-Host "Alias '$aliasName' is already present in your PowerShell profile."
}

if ($changesMade) {
    Write-Host "'$commandName' (alias '$aliasName') has been configured. Please restart your terminal or run '. `"$profilePath`"' to use it." -ForegroundColor Green
}

Write-Host "Setup finished!" -ForegroundColor Cyan
