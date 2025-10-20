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
    $existingGoal = [regex]::Match($content, '(?sm)## Primary Goal\s*?\r?\n(.*?)\s*?\r?\n##').Groups[1].Value.Trim()
    $existingModel = [regex]::Match($content, '(?sm)## AI Model\s*?\r?\n(.*?)\s*?\r?\n(##|---)').Groups[1].Value.Trim()
}


# 3. Get User Input (only if values are missing)
$projectGoal = $existingGoal
if ([string]::IsNullOrWhiteSpace($projectGoal)) {
    $projectGoal = Read-Host -Prompt "What is the primary goal of this project?"
} else {
    Write-Host "Using existing Primary Goal: $projectGoal"
}

$aiModel = $existingModel
if ([string]::IsNullOrWhiteSpace($aiModel)) {
    $aiModel = Read-Host -Prompt "Which AI model do you plan to use?"
} else {
    Write-Host "Using existing AI Model: $aiModel"
}

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

# 6. Post-Initialization Guidance
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
