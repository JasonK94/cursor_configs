#!/bin/bash
# init_project.sh - Interactively initializes a new project with cursor context for Linux/macOS.

#
# Helper Functions
#
print_success() {
    printf "\e[32m%s\e[0m\n" "$1"
}

print_error() {
    printf "\e[31m%s\e[0m\n" "$1"
}

print_warning() {
    printf "\e[33m%s\e[0m\n" "$1"
}

print_info() {
    printf "\e[36m%s\e[0m\n" "$1"
}

# Parse command line arguments for --project-root
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --project-root)
        PROJECT_ROOT="$2"
        shift
        shift
        ;;
        *)
        # unknown option
        shift
        ;;
    esac
done

# CRITICAL: Abort if the calling directory was not passed correctly.
if [ -z "$PROJECT_ROOT" ] || [ ! -d "$PROJECT_ROOT" ]; then
    print_error "FATAL: Script was called without a valid working directory. Please ensure you are using the latest version by running install.sh"
    exit 1
fi

cd "$PROJECT_ROOT"

# 1. Self-Update: Pull the latest changes from the central repository
print_info "Checking for updates to cursor_configs..."
CENTRAL_REPO_PATH="$HOME/.cursor_configs"
if ! (cd "$CENTRAL_REPO_PATH" && git pull); then
    print_warning "Could not check for updates. Proceeding with local version."
fi
print_success "Update check complete."


# 2. Check for existing context and extract values
OUTPUT_CONTEXT_FILE="context.md"
EXISTING_GOAL=""
EXISTING_MODEL=""
EXISTING_REFS=""

if [ -f "$OUTPUT_CONTEXT_FILE" ]; then
    print_info "Existing 'context.md' found. Reading current values..."
    EXISTING_GOAL=$(awk '/^## (Primary Goal|주요 목표)/{getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}' "$OUTPUT_CONTEXT_FILE")
    EXISTING_MODEL=$(awk '/^## (AI Model|사용 예정 AI 모델)/{getline; gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}' "$OUTPUT_CONTEXT_FILE")
    EXISTING_REFS=$(sed -n '/## References\|## 참고 자료/,/---/p' "$OUTPUT_CONTEXT_FILE" | sed '1d;$d')
fi

# 3. Get User Input
GOAL_PROMPT="What is the primary goal of this project?"
if [ -n "$EXISTING_GOAL" ]; then
    read -p "$GOAL_PROMPT (Press Enter to keep: '$EXISTING_GOAL'): " USER_INPUT_GOAL
    PROJECT_GOAL=${USER_INPUT_GOAL:-$EXISTING_GOAL}
else
    read -p "$GOAL_PROMPT: " PROJECT_GOAL
fi

MODEL_PROMPT="Which AI model do you plan to use?"
if [ -n "$EXISTING_MODEL" ]; then
    read -p "$MODEL_PROMPT (Press Enter to keep: '$EXISTING_MODEL'): " USER_INPUT_MODEL
    AI_MODEL=${USER_INPUT_MODEL:-$EXISTING_MODEL}
else
    read -p "$MODEL_PROMPT: " AI_MODEL
fi

read -p "[Optional] Any new reference URLs or documents to add? (comma-separated): " NEW_REFERENCES

read -p $'Select documentation language:\n[1] Both (default)\n[2] English only\n[3] Korean only\nChoice: ' LANGUAGE_CHOICE
case "$LANGUAGE_CHOICE" in
    2)
        INCLUDE_EN=true
        INCLUDE_KO=false
        ;;
    3)
        INCLUDE_EN=false
        INCLUDE_KO=true
        ;;
    *)
        INCLUDE_EN=true
        INCLUDE_KO=true
        ;;
esac

if [ -z "$PROJECT_GOAL" ] || [ -z "$AI_MODEL" ]; then
    print_error "Project goal and AI model cannot be empty. Aborting."
    exit 1
fi

# 4. Generate the Project-Specific Context File
GENERAL_CONTEXT_PATH_EN="$CENTRAL_REPO_PATH/templates/cursor_configs_context.md.template"
GENERAL_CONTEXT_PATH_KO="$CENTRAL_REPO_PATH/templates/cursor_configs_context_Korean.md.template"
if [ "$INCLUDE_EN" = true ] && [ ! -f "$GENERAL_CONTEXT_PATH_EN" ]; then
    print_error "Could not find 'templates/cursor_configs_context.md.template' in '$CENTRAL_REPO_PATH'. Please run the installation script again."
    exit 1
fi
if [ "$INCLUDE_KO" = true ] && [ ! -f "$GENERAL_CONTEXT_PATH_KO" ]; then
    print_error "Could not find 'templates/cursor_configs_context_Korean.md.template' in '$CENTRAL_REPO_PATH'. Please run the installation script again."
    exit 1
fi
[ "$INCLUDE_EN" = true ] && BASE_CONTEXT_CONTENT_EN=$(cat "$GENERAL_CONTEXT_PATH_EN")
[ "$INCLUDE_KO" = true ] && BASE_CONTEXT_CONTENT_KO=$(cat "$GENERAL_CONTEXT_PATH_KO")

REFERENCES_ACCUM=""
if [ -n "$EXISTING_REFS" ]; then
    REFERENCES_ACCUM=$(echo "$EXISTING_REFS" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi
if [ -n "$NEW_REFERENCES" ]; then
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$line" ] && continue
        if [ -n "$REFERENCES_ACCUM" ]; then
            REFERENCES_ACCUM="${REFERENCES_ACCUM}"$'\n'
        fi
        REFERENCES_ACCUM="${REFERENCES_ACCUM}- ${line}"
    done < <(echo "$NEW_REFERENCES" | tr ',' '\n')
fi
REFERENCES_ACCUM=$(echo "$REFERENCES_ACCUM" | sed 's/[[:space:]]*$//')

REF_SECTION_EN=""
REF_SECTION_KO=""
if [ -n "$REFERENCES_ACCUM" ]; then
    REF_SECTION_EN=$'\n\n''## References\n'"$REFERENCES_ACCUM"
    REF_SECTION_KO=$'\n\n''## 참고 자료\n'"$REFERENCES_ACCUM"
fi

if [ "$INCLUDE_EN" = true ]; then
    cat <<EOF > "$OUTPUT_CONTEXT_FILE"
# Project-Specific Context

## Primary Goal
$PROJECT_GOAL

## AI Model
$AI_MODEL$REF_SECTION_EN

---

$BASE_CONTEXT_CONTENT_EN
EOF
    print_success "Successfully created or updated '$OUTPUT_CONTEXT_FILE' for your new project."
fi

if [ "$INCLUDE_KO" = true ]; then
    if [ "$INCLUDE_EN" = true ]; then
        KOREAN_CONTEXT_PATH="context_Korean.md"
    else
        KOREAN_CONTEXT_PATH="context.md"
    fi
    cat <<EOF > "$KOREAN_CONTEXT_PATH"
# 프로젝트 전용 컨텍스트

## 주요 목표
$PROJECT_GOAL

## 사용 예정 AI 모델
$AI_MODEL$REF_SECTION_KO

---

$BASE_CONTEXT_CONTENT_KO
EOF
    print_success "Successfully created or updated '$KOREAN_CONTEXT_PATH' for your new project."
fi

# 5. Create NEXT_STEPS.md
NEXT_STEPS_FILE="NEXT_STEPS.md"
if [ "$INCLUDE_EN" = true ] && [ "$INCLUDE_KO" = true ]; then
    DOC_INSTRUCTION="4.  **Draft Documentation**: Based on the plan, write drafts for \`README.md\` (English) and \`README_Korean.md\` (Korean) that outline the project's purpose and planned features."
elif [ "$INCLUDE_EN" = true ]; then
    DOC_INSTRUCTION="4.  **Draft Documentation**: Based on the plan, write a draft for \`README.md\` (English) that outlines the project's purpose and planned features."
else
    DOC_INSTRUCTION="4.  **Draft Documentation**: Based on the plan, write a draft for \`README.md\` (Korean) that outlines the project's purpose and planned features."
fi
cat > "$NEXT_STEPS_FILE" << EOF
# Next Steps: Your First Prompt for the AI Agent

Copy the following instructions and paste them into the Cursor chat to begin the development process.

---

1.  **Analyze Context**: Read the \`context.md\` file thoroughly to understand the project's Primary Goal, the designated AI Model, and any provided References.
2.  **Deconstruct the Goal**: Based on your analysis, break down the Primary Goal into a logical sequence of smaller, actionable sub-goals.
3.  **Propose a Plan**: Present a detailed, step-by-step TODO list that outlines the implementation plan for the *first* sub-goal. For each step, specify which files you intend to create or modify.
$DOC_INSTRUCTION
5.  **Confirm Before Acting**: After presenting the plan and the draft READMEs, ask for my confirmation before you begin writing any code or modifying any files.

---
EOF

# 6. Copy Log Templates
DEVLOG_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/DEVLOG.md.template"
CHANGELOG_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/CHANGELOG.md.template"
DEVLOG_TEMPLATE_PATH_KO="$CENTRAL_REPO_PATH/templates/DEVLOG_Korean.md.template"
CHANGELOG_TEMPLATE_PATH_KO="$CENTRAL_REPO_PATH/templates/CHANGELOG_Korean.md.template"
DEVLOG_DEST_PATH="$PROJECT_ROOT/DEVLOG.md"
CHANGELOG_DEST_PATH="$PROJECT_ROOT/CHANGELOG.md"

if [ "$INCLUDE_EN" = true ]; then
    [ -f "$DEVLOG_TEMPLATE_PATH" ] && [ ! -f "$DEVLOG_DEST_PATH" ] && cp "$DEVLOG_TEMPLATE_PATH" "$DEVLOG_DEST_PATH"
    [ -f "$CHANGELOG_TEMPLATE_PATH" ] && [ ! -f "$CHANGELOG_DEST_PATH" ] && cp "$CHANGELOG_TEMPLATE_PATH" "$CHANGELOG_DEST_PATH"
elif [ "$INCLUDE_KO" = true ]; then
    [ -f "$DEVLOG_TEMPLATE_PATH_KO" ] && [ ! -f "$DEVLOG_DEST_PATH" ] && cp "$DEVLOG_TEMPLATE_PATH_KO" "$DEVLOG_DEST_PATH"
    [ -f "$CHANGELOG_TEMPLATE_PATH_KO" ] && [ ! -f "$CHANGELOG_DEST_PATH" ] && cp "$CHANGELOG_TEMPLATE_PATH_KO" "$CHANGELOG_DEST_PATH"
fi

if [ "$INCLUDE_EN" = true ] && [ "$INCLUDE_KO" = true ]; then
    DEVLOG_DEST_PATH_KO="$PROJECT_ROOT/DEVLOG_Korean.md"
    CHANGELOG_DEST_PATH_KO="$PROJECT_ROOT/CHANGELOG_Korean.md"
    [ -f "$DEVLOG_TEMPLATE_PATH_KO" ] && [ ! -f "$DEVLOG_DEST_PATH_KO" ] && cp "$DEVLOG_TEMPLATE_PATH_KO" "$DEVLOG_DEST_PATH_KO"
    [ -f "$CHANGELOG_TEMPLATE_PATH_KO" ] && [ ! -f "$CHANGELOG_DEST_PATH_KO" ] && cp "$CHANGELOG_TEMPLATE_PATH_KO" "$CHANGELOG_DEST_PATH_KO"
fi

# 7. Copy README Templates
README_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/README.md.template"
README_KOREAN_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/README_Korean.md.template"
README_DEST_PATH="$PROJECT_ROOT/README.md"
README_KOREAN_DEST_PATH="$PROJECT_ROOT/README_Korean.md"

if [ "$INCLUDE_EN" = true ]; then
    [ -f "$README_TEMPLATE_PATH" ] && [ ! -f "$README_DEST_PATH" ] && cp "$README_TEMPLATE_PATH" "$README_DEST_PATH"
elif [ "$INCLUDE_KO" = true ]; then
    [ -f "$README_KOREAN_TEMPLATE_PATH" ] && [ ! -f "$README_DEST_PATH" ] && cp "$README_KOREAN_TEMPLATE_PATH" "$README_DEST_PATH"
fi

if [ "$INCLUDE_EN" = true ] && [ "$INCLUDE_KO" = true ]; then
    [ -f "$README_KOREAN_TEMPLATE_PATH" ] && [ ! -f "$README_KOREAN_DEST_PATH" ] && cp "$README_KOREAN_TEMPLATE_PATH" "$README_KOREAN_DEST_PATH"
fi

# 8. Post-Initialization Guidance
GUIDANCE=$(cat <<EOF

----------------------------------------------------
Next Steps:
1.  **Open \`NEXT_STEPS.md\`**.
2.  **Copy the instructions** from the file.
3.  **Paste them into the Cursor chat** to start the development workflow.
----------------------------------------------------

EOF
)
print_info "$GUIDANCE"
