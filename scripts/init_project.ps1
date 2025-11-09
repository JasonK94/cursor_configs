param(
    [string]$ProjectRoot
)

# CRITICAL: Abort if the calling directory was not passed correctly.
if ([string]::IsNullOrWhiteSpace($ProjectRoot) -or -not (Test-Path $ProjectRoot)) {
    Write-Host "FATAL: Script was called without a valid working directory. Please ensure you are using the latest version by running install.ps1" -ForegroundColor Red
    exit 1
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
$existingReferences = ""
# Use ABSOLUTE paths for all file operations
$outputContextFile = Join-Path $ProjectRoot "context.md"

if (Test-Path $outputContextFile) {
    Write-Host "Existing 'context.md' found. Reading current values..." -ForegroundColor Cyan
    $content = Get-Content $outputContextFile -Raw
    # More robust regex to find content between a heading and the next heading or horizontal rule
    $existingGoal = [regex]::Match($content, '(?sm)## (Primary Goal|주요 목표)\s*?\r?\n(.*?)\s*?\r?\n(##\s|---)').Groups[2].Value.Trim()
    $existingModel = [regex]::Match($content, '(?sm)## (AI Model|사용 예정 AI 모델)\s*?\r?\n(.*?)\s*?\r?\n(##\s|---)').Groups[2].Value.Trim()
    $existingReferences = [regex]::Match($content, '(?sm)## (References|참고 자료)\s*?\r?\n(.*?)\s*?\r?\n(##\s|---)').Groups[2].Value.Trim()
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

$languagePrompt = @"
Select documentation language:
[1] Both (default)
[2] English only
[3] Korean only
"@
$languageChoice = Read-Host -Prompt $languagePrompt
switch ($languageChoice) {
    "2" {
        $includeEnglish = $true
        $includeKorean = $false
    }
    "3" {
        $includeEnglish = $false
        $includeKorean = $true
    }
    default {
        $includeEnglish = $true
        $includeKorean = $true
    }
}

if ([string]::IsNullOrWhiteSpace($projectGoal) -or [string]::IsNullOrWhiteSpace($aiModel)) {
    Write-Host "Project goal and AI model cannot be empty. Aborting." -ForegroundColor Red
    exit 1
}

# 4. Define Paths
$generalContextPathEn = Join-Path $centralRepoPath "templates/cursor_configs_context.md.template"
$generalContextPathKo = Join-Path $centralRepoPath "templates/cursor_configs_context_Korean.md.template"

if ($includeEnglish -and -not (Test-Path $generalContextPathEn)) {
    Write-Host "Could not find 'templates/cursor_configs_context.md.template' in '$centralRepoPath'. Please run the installation script again." -ForegroundColor Red
    exit 1
}
if ($includeKorean -and -not (Test-Path $generalContextPathKo)) {
    Write-Host "Could not find 'templates/cursor_configs_context_Korean.md.template' in '$centralRepoPath'. Please run the installation script again." -ForegroundColor Red
    exit 1
}

# 5. Generate the Project-Specific Context File(s)
if (-not [string]::IsNullOrWhiteSpace($references)) {
    $newReferenceItems = $references.Split(',') | ForEach-Object { "- " + $_.Trim() }
    if (-not [string]::IsNullOrWhiteSpace($existingReferences)) {
        $existingReferences += "`r`n"
    }
    $existingReferences += ($newReferenceItems -join "`r`n")
}
$existingReferences = $existingReferences.Trim()

if ($includeEnglish) {
    $baseContextContentEn = Get-Content $generalContextPathEn -Raw
    $referencesSectionEn = ""
    if (-not [string]::IsNullOrWhiteSpace($existingReferences)) {
        $referencesSectionEn = @"

## References
$existingReferences
"@
    }
    $projectContextHeaderEn = @"
# Project-Specific Context

## Primary Goal
$projectGoal

## AI Model
$aiModel$referencesSectionEn

---

"@
    $finalContentEn = $projectContextHeaderEn + $baseContextContentEn
    Set-Content -Path $outputContextFile -Value $finalContentEn
    Write-Host "Successfully created or updated '$outputContextFile' for your new project." -ForegroundColor Green
}

if ($includeKorean) {
    $baseContextContentKo = Get-Content $generalContextPathKo -Raw
    $referencesSectionKo = ""
    if (-not [string]::IsNullOrWhiteSpace($existingReferences)) {
        $referencesSectionKo = @"

## 참고 자료
$existingReferences
"@
    }
    $koreanContextHeader = @"
# 프로젝트 전용 컨텍스트

## 주요 목표
$projectGoal

## 사용 예정 AI 모델
$aiModel$referencesSectionKo

---

"@
    $koreanContextPath = if ($includeEnglish) { Join-Path $ProjectRoot "context_Korean.md" } else { Join-Path $ProjectRoot "context.md" }
    Set-Content -Path $koreanContextPath -Value ($koreanContextHeader + $baseContextContentKo)
    Write-Host "Successfully created or updated '$koreanContextPath' for your new project." -ForegroundColor Green
}

# 6. Create NEXT_STEPS.md
$nextStepsFile = Join-Path $ProjectRoot "NEXT_STEPS.md"
$documentationInstruction = switch ($true) {
    { $includeEnglish -and $includeKorean } {
        "4.  **Draft Documentation**: Based on the plan, write drafts for `README.md` (English) and `README_Korean.md` (Korean) that outline the project's purpose and planned features."
        break
    }
    { $includeEnglish -and -not $includeKorean } {
        "4.  **Draft Documentation**: Based on the plan, write a draft for `README.md` (English) that outlines the project's purpose and planned features."
        break
    }
    default {
        "4.  **Draft Documentation**: Based on the plan, write a draft for `README.md` (Korean) that outlines the project's purpose and planned features."
    }
}
$nextStepsContent = @"
# Next Steps: Your First Prompt for the AI Agent

Copy the following instructions and paste them into the Cursor chat to begin the development process.

---

1.  **Analyze Context**: Read the `context.md` file thoroughly to understand the project's Primary Goal, the designated AI Model, and any provided References.
2.  **Deconstruct the Goal**: Based on your analysis, break down the Primary Goal into a logical sequence of smaller, actionable sub-goals.
3.  **Propose a Plan**: Present a detailed, step-by-step TODO list that outlines the implementation plan for the *first* sub-goal. For each step, specify which files you intend to create or modify.
$documentationInstruction
5.  **Confirm Before Acting**: After presenting the plan and the draft READMEs, ask for my confirmation before you begin writing any code or modifying any files.

---
"@

Set-Content -Path $nextStepsFile -Value $nextStepsContent -Force

# Add a verification step to ensure the file was created
if (-not (Test-Path $nextStepsFile)) {
    Write-Host "Error: Failed to create '$nextStepsFile'. Please check permissions." -ForegroundColor Red
}

# 7. Copy Log Templates
$devlogTemplatePathEn = Join-Path $centralRepoPath "templates/DEVLOG.md.template"
$changelogTemplatePathEn = Join-Path $centralRepoPath "templates/CHANGELOG.md.template"
$devlogTemplatePathKo = Join-Path $centralRepoPath "templates/DEVLOG_Korean.md.template"
$changelogTemplatePathKo = Join-Path $centralRepoPath "templates/CHANGELOG_Korean.md.template"
$devlogDestPath = Join-Path $ProjectRoot "DEVLOG.md"
$changelogDestPath = Join-Path $ProjectRoot "CHANGELOG.md"

if ($includeEnglish) {
    if ((Test-Path $devlogTemplatePathEn) -and -not (Test-Path $devlogDestPath)) {
        Copy-Item -Path $devlogTemplatePathEn -Destination $devlogDestPath
    }
    if ((Test-Path $changelogTemplatePathEn) -and -not (Test-Path $changelogDestPath)) {
        Copy-Item -Path $changelogTemplatePathEn -Destination $changelogDestPath
    }
} elseif ($includeKorean) {
    if ((Test-Path $devlogTemplatePathKo) -and -not (Test-Path $devlogDestPath)) {
        Copy-Item -Path $devlogTemplatePathKo -Destination $devlogDestPath
    }
    if ((Test-Path $changelogTemplatePathKo) -and -not (Test-Path $changelogDestPath)) {
        Copy-Item -Path $changelogTemplatePathKo -Destination $changelogDestPath
    }
}

if ($includeEnglish -and $includeKorean) {
    $devlogDestPathKo = Join-Path $ProjectRoot "DEVLOG_Korean.md"
    $changelogDestPathKo = Join-Path $ProjectRoot "CHANGELOG_Korean.md"
    if ((Test-Path $devlogTemplatePathKo) -and -not (Test-Path $devlogDestPathKo)) {
        Copy-Item -Path $devlogTemplatePathKo -Destination $devlogDestPathKo
    }
    if ((Test-Path $changelogTemplatePathKo) -and -not (Test-Path $changelogDestPathKo)) {
        Copy-Item -Path $changelogTemplatePathKo -Destination $changelogDestPathKo
    }
}

$readmeTemplatePathEn = Join-Path $centralRepoPath "templates\README.md.template"
$readmeTemplatePathKo = Join-Path $centralRepoPath "templates\README_Korean.md.template"
$readmeDestPath = Join-Path $ProjectRoot "README.md"
$readmeKoreanDestPath = Join-Path $ProjectRoot "README_Korean.md"

if ($includeEnglish) {
    if (-not (Test-Path $readmeDestPath)) {
        Copy-Item -Path $readmeTemplatePathEn -Destination $readmeDestPath
    }
} elseif ($includeKorean -and -not (Test-Path $readmeDestPath)) {
    Copy-Item -Path $readmeTemplatePathKo -Destination $readmeDestPath
}

if ($includeEnglish -and $includeKorean -and -not (Test-Path $readmeKoreanDestPath)) {
    Copy-Item -Path $readmeTemplatePathKo -Destination $readmeKoreanDestPath
}

# 8. Post-Initialization Guidance
$guidance = @"

----------------------------------------------------
Next Steps:
1.  **Open `NEXT_STEPS.md`**.
2.  **Copy the instructions** from the file.
3.  **Paste them into the Cursor chat** to start the development workflow.
----------------------------------------------------

"@
Write-Host $guidance -ForegroundColor Cyan
