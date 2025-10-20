# init_project.ps1 - Interactively initializes a new project with cursor context.

# 1. Self-Update: Pull the latest changes from the central repository
Write-Host "Checking for updates to cursor_configs..."
$centralRepoPath = "$HOME\\.cursor_configs"
try {
    Set-Location $centralRepoPath
    git pull
    Set-Location $PSScriptRoot
    Write-Host "Update check complete." -ForegroundColor Green
} catch {
    Write-Host "Could not check for updates. Proceeding with local version." -ForegroundColor Yellow
    Set-Location $PSScriptRoot
}

# 2. Get User Input
$projectGoal = Read-Host -Prompt "What is the primary goal of this project?"
$aiModel = Read-Host -Prompt "Which AI model do you plan to use? (e.g., GPT-4o, Claude 3 Opus)"
$references = Read-Host -Prompt "[Optional] Any reference URLs or documents? (comma-separated)"

if ([string]::IsNullOrWhiteSpace($projectGoal) -or [string]::IsNullOrWhiteSpace($aiModel)) {
    Write-Host "Project goal and AI model cannot be empty. Aborting." -ForegroundColor Red
    exit 1
}

# 3. Define Paths
$generalContextPath = Join-Path $centralRepoPath "context_general.md"
$outputContextFile = "context.md"

if (-not (Test-Path $generalContextPath)) {
    Write-Host "Could not find 'context_general.md' in '$centralRepoPath'. Please run the installation script again." -ForegroundColor Red
    exit 1
}

# 4. Generate the Project-Specific Context File
$generalContextContent = Get-Content $generalContextPath -Raw

$referencesSection = ""
if (-not [string]::IsNullOrWhiteSpace($references)) {
    $referenceItems = $references.Split(',') | ForEach-Object { "- " + $_.Trim() }
    $referencesSection = @"

## References
$($referenceItems -join "`r`n")
"@
}

$projectContextHeader = @"
# Project-Specific Context

## Primary Goal
$projectGoal

## AI Model
$aiModel$($referencesSection)

---

"@

$finalContent = $projectContextHeader + $generalContextContent

Set-Content -Path $outputContextFile -Value $finalContent

Write-Host "Successfully created '$outputContextFile' for your new project." -ForegroundColor Green

# 5. Post-Initialization Guidance
$guidance = @"

----------------------------------------------------
Next Steps:
1. Open the newly created `context.md` file.
2. Review the content and add any more specific details to the 'Primary Goal' or 'References' sections.
3. Start your session with the AI assistant by giving it a high-level instruction, for example:
   "Read the context.md file, understand the goal, and propose a step-by-step plan to achieve it."
----------------------------------------------------

"@
Write-Host $guidance -ForegroundColor Cyan
