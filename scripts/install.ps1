# install.ps1 - Installs or updates the cursor_configs tool.

param(
    [string]$Alias,
    [switch]$Quiet
)

# 1. Define Paths
$centralRepoPath = "$HOME\\.cursor_configs"
$repoUrl = "https://github.com/JasonK94/cursor_configs.git"
$initScriptPath = Join-Path $centralRepoPath "scripts\\init_project.ps1"
$shimDir = Join-Path $centralRepoPath "bin"
$shimCmdPath = Join-Path $shimDir "cinit.cmd"

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

# 3. Build the command content
$commandName = "Start-CursorProject"
$command = @"

# Adds the Start-CursorProject command for initializing a new project
function $commandName {
    param()
    & "$initScriptPath"
}
"@

# 4. Determine a safe alias automatically (no prompting)
function Get-AvailableAlias {
    param(
        [string]$preferredAlias,
        [int]$maxAttempts = 20
    )
    if (-not (Get-Command $preferredAlias -ErrorAction SilentlyContinue)) {
        return $preferredAlias
    }
    for ($i = 2; $i -le $maxAttempts; $i++) {
        $candidate = "$preferredAlias$i"
        if (-not (Get-Command $candidate -ErrorAction SilentlyContinue)) {
            return $candidate
        }
    }
    return "cursorinit"
}

$desiredAlias = if ($Alias) { $Alias } else { "cinit" }
$finalAlias = Get-AvailableAlias -preferredAlias $desiredAlias

$aliasCommandTemplate = @"
# Sets a short alias for Start-CursorProject
Set-Alias -Name {ALIAS} -Value $commandName
"@

# 5. Write to both WindowsPowerShell and PowerShell profiles (AllHosts)
$profilesToUpdate = @(
    $PROFILE.CurrentUserAllHosts,
    (Join-Path $HOME "Documents\\WindowsPowerShell\\Profile.ps1"),
    (Join-Path $HOME "Documents\\PowerShell\\Profile.ps1")
) | Where-Object { $_ -and $_.Trim() -ne "" } | Select-Object -Unique

$changesMade = $false
foreach ($profilePath in $profilesToUpdate) {
    try {
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path $profilePath)) {
            if (-not $Quiet) { Write-Host "Creating PowerShell profile at $profilePath..." }
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }
        $profileContent = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { "" }

        if ($profileContent -notlike "*function $commandName*") {
            if (-not $Quiet) { Write-Host "Adding '$commandName' command to $profilePath..." }
            Add-Content -Path $profilePath -Value $command
            $changesMade = $true
        }

        $aliasCommand = $aliasCommandTemplate.Replace("{ALIAS}", $finalAlias)
        if ($profileContent -notlike "*Set-Alias -Name $finalAlias*") {
            if (-not $Quiet) { Write-Host "Adding alias '$finalAlias' to $profilePath..." }
            Add-Content -Path $profilePath -Value $aliasCommand
            $changesMade = $true
        }
    } catch {
        Write-Host "Failed to update profile: $profilePath" -ForegroundColor Yellow
    }
}

# 6. Create a PATH-based shim so 'cinit' works without profiles
if (-not (Test-Path $shimDir)) {
    New-Item -Path $shimDir -ItemType Directory -Force | Out-Null
}

$shimCmd = "@echo off`r`n" + "powershell -NoProfile -ExecutionPolicy Bypass -File \"%USERPROFILE%\\.cursor_configs\\scripts\\init_project.ps1\"`r`n" + "exit /b %ERRORLEVEL%`r`n"
Set-Content -Path $shimCmdPath -Value $shimCmd -Encoding ASCII

# Ensure shimDir is on PATH (User) and current session
try {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $userPath) { $userPath = "" }
    if ($userPath -notlike "*${shimDir}*") {
        [Environment]::SetEnvironmentVariable("Path", ($userPath.TrimEnd(';') + ";" + $shimDir), "User")
    }
    # Update current session PATH if possible
    if ($env:Path -notlike "*${shimDir}*") {
        $env:Path = $env:Path.TrimEnd(';') + ";" + $shimDir
    }
} catch {
    Write-Host "Warning: Failed to update PATH. You may need to add '$shimDir' to PATH manually." -ForegroundColor Yellow
}

if ($changesMade) {
    Write-Host "'$commandName' (alias '$finalAlias') has been configured. Restart your terminal or run '. `"$($PROFILE.CurrentUserAllHosts)`"' to use it." -ForegroundColor Green
} else {
    Write-Host "No profile changes were necessary. '$commandName' and alias '$finalAlias' may already be configured." -ForegroundColor Green
}

Write-Host "Shim installed at '$shimCmdPath'. If PATH updated, 'cinit' should work immediately in new shells; it may also work in this session." -ForegroundColor Cyan
Write-Host "Setup finished!" -ForegroundColor Cyan
