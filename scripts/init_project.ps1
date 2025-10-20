param(
    [string]$WorkingDirectory
)

# Set the working directory to where cinit was called from
if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory) -and (Test-Path $WorkingDirectory)) {
    Set-Location -Path $WorkingDirectory
}

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

# 2. Check for existing context and extract values
$existingGoal = ""
$existingModel = ""
$outputContextFile = "context.md"

if (Test-Path $outputContextFile) {
    Write-Host "Existing 'context.md' found. Reading current values..." -ForegroundColor Cyan
    $content = Get-Content $outputContextFile -Raw
    # More robust regex to find content between a heading and the next heading or horizontal rule
    $existingGoal = [regex]::Match($content, '(?sm)## Primary Goal\s*?\r?\n(.*?)\s*?\r?\n(##\s|---)').Groups[1].Value.Trim()
    $existingModel = [regex]::Match($content, '(?sm)## AI Model\s*?\r?\n(.*?)\s*?\r?\n(##\s|---)').Groups[1].Value.Trim()
}


# 3. Get User Input
$goalPrompt = "What is the primary goal of this project?"
if (-not [string]::IsNullOrWhiteSpace($existingGoal)) {
    $goalPrompt += " (Press Enter to keep: '$existingGoal')"
}
$userInputGoal = Read-Host -Prompt $goalPrompt
$projectGoal = if ([string]::IsNullOrWhiteSpace($userInputGoal)) { $existingGoal } else { $userInputGoal }

$modelPrompt = "Which AI model do you plan to use?"
if (-not [string]::IsNullOrWhiteSpace($existingModel)) {
    $modelPrompt += " (Press Enter to keep: '$existingModel')"
}
$userInputModel = Read-Host -Prompt $modelPrompt
$aiModel = if ([string]::IsNullOrWhiteSpace($userInputModel)) { $existingModel } else { $userInputModel }

$references = Read-Host -Prompt "[Optional] Any new reference URLs or documents to add? (comma-separated)"

if ([string]::IsNullOrWhiteSpace($projectGoal) -or [string]::IsNullOrWhiteSpace($aiModel)) {
    Write-Host "Project goal and AI model cannot be empty. Aborting." -ForegroundColor Red
    exit 1
}

# 4. Define Paths
$generalContextPath = Join-Path $centralRepoPath "context_general.md"


if (-not (Test-Path $generalContextPath)) {
    Write-Host "Could not find 'context_general.md' in '$centralRepoPath'. Please run the installation script again." -ForegroundColor Red
    exit 1
}

# 5. Generate the Project-Specific Context File
$baseContextContent = Get-Content $generalContextPath -Raw

$referencesSection = ""
# Try to preserve existing references if any
$existingReferences = [regex]::Match($content, '(?sm)## References\s*?\r?\n(.*?)\s*?\r?\n---').Groups[1].Value.Trim()

if (-not [string]::IsNullOrWhiteSpace($references)) {
    # Add new references
    $newReferenceItems = $references.Split(',') | ForEach-Object { "- " + $_.Trim() }
    $existingReferences += "`r`n" + ($newReferenceItems -join "`r`n")
}

if (-not [string]::IsNullOrWhiteSpace($existingReferences)) {
    $referencesSection = @"

## References
$($existingReferences.Trim())
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

$finalContent = $projectContextHeader + $baseContextContent

Set-Content -Path $outputContextFile -Value $finalContent

Write-Host "Successfully created or updated '$outputContextFile' for your new project." -ForegroundColor Green

# 6. Create NEXT_STEPS.md
$nextStepsFile = "NEXT_STEPS.md"
$nextStepsContent = @"
# Next Steps: Your First Prompt for the AI Agent

Copy the following instructions and paste them into the Cursor chat to begin the development process.

---

1.  **Analyze Context**: Read the `context.md` file thoroughly to understand the project's Primary Goal, the designated AI Model, and any provided References.
2.  **Deconstruct the Goal**: Based on your analysis, break down the Primary Goal into a logical sequence of smaller, actionable sub-goals.
3.  **Propose a Plan**: Present a detailed, step-by-step TODO list that outlines the implementation plan for the *first* sub-goal. For each step, specify which files you intend to create or modify.
4.  **Confirm Before Acting**: After presenting the plan, ask for my confirmation before you begin writing any code or modifying any files.

---
"@

Set-Content -Path $nextStepsFile -Value $nextStepsContent -Force

# Add a verification step to ensure the file was created
if (-not (Test-Path $nextStepsFile)) {
    Write-Host "Error: Failed to create '$nextStepsFile'. Please check permissions." -ForegroundColor Red
}

# 7. Post-Initialization Guidance
$guidance = @"

----------------------------------------------------
Next Steps:
1.  **Open `NEXT_STEPS.md`**.
2.  **Copy the instructions** from the file.
3.  **Paste them into the Cursor chat** to start the development workflow.
----------------------------------------------------

"@
Write-Host $guidance -ForegroundColor Cyan
