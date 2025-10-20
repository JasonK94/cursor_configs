# init_project.ps1 - Interactively initializes a new project with cursor context.

# 1. Get User Input
$projectGoal = Read-Host -Prompt "What is the primary goal of this project?"
$aiModel = Read-Host -Prompt "Which AI model do you plan to use? (e.g., GPT-4o, Claude 3 Opus)"

if ([string]::IsNullOrWhiteSpace($projectGoal) -or [string]::IsNullOrWhiteSpace($aiModel)) {
    Write-Host "Project goal and AI model cannot be empty. Aborting." -ForegroundColor Red
    exit 1
}

# 2. Define Paths
$centralRepoPath = "$HOME\\.cursor_configs"
$generalContextPath = Join-Path $centralRepoPath "context_general.md"
$outputContextFile = "context.md"

if (-not (Test-Path $generalContextPath)) {
    Write-Host "Could not find 'context_general.md' in '$centralRepoPath'. Please run the installation script again." -ForegroundColor Red
    exit 1
}

# 3. Generate the Project-Specific Context File
$generalContextContent = Get-Content $generalContextPath -Raw

$projectContextHeader = @"
# Project-Specific Context

## Primary Goal
$projectGoal

## AI Model
$aiModel

---

"@

$finalContent = $projectContextHeader + $generalContextContent

Set-Content -Path $outputContextFile -Value $finalContent

Write-Host "Successfully created '$outputContextFile' for your new project." -ForegroundColor Green
