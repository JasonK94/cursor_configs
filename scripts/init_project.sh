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
    # Use grep and sed for basic parsing. Robust but not perfect for complex markdown.
    EXISTING_GOAL=$(grep -A 1 "## Primary Goal" "$OUTPUT_CONTEXT_FILE" | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    EXISTING_MODEL=$(grep -A 1 "## AI Model" "$OUTPUT_CONTEXT_FILE" | tail -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Extract multi-line references
    EXISTING_REFS=$(sed -n '/## References/,/---/p' "$OUTPUT_CONTEXT_FILE" | sed '1d;$d')
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

if [ -z "$PROJECT_GOAL" ] || [ -z "$AI_MODEL" ]; then
    print_error "Project goal and AI model cannot be empty. Aborting."
    exit 1
fi

# 4. Generate the Project-Specific Context File
GENERAL_CONTEXT_PATH="$CENTRAL_REPO_PATH/context_general.md"
if [ ! -f "$GENERAL_CONTEXT_PATH" ]; then
    print_error "Could not find 'context_general.md' in '$CENTRAL_REPO_PATH'. Please run the installation script again."
    exit 1
fi
BASE_CONTEXT_CONTENT=$(cat "$GENERAL_CONTEXT_PATH")

REFERENCES_SECTION=""
if [ -n "$EXISTING_REFS" ] || [ -n "$NEW_REFERENCES" ]; then
    REFERENCES_SECTION="\n\n## References\n"
    if [ -n "$EXISTING_REFS" ]; then
        REFERENCES_SECTION+="$EXISTING_REFS\n"
    fi
    if [ -n "$NEW_REFERENCES" ]; then
        # Convert comma-separated to markdown list
        echo "$NEW_REFERENCES" | tr ',' '\n' | sed 's/^[[:space:]]*/- /' | while read -r line; do
            REFERENCES_SECTION+="$line\n"
        done
    fi
fi

# Create Header
PROJECT_CONTEXT_HEADER=$(cat <<EOF
# Project-Specific Context

## Primary Goal
$PROJECT_GOAL

## AI Model
$AI_MODEL
EOF
)

{
    echo -e "$PROJECT_CONTEXT_HEADER"
    echo -e "$REFERENCES_SECTION"
    echo -e "---\n"
    echo -e "$BASE_CONTEXT_CONTENT"
} > "$OUTPUT_CONTEXT_FILE"

print_success "Successfully created or updated '$OUTPUT_CONTEXT_FILE' for your new project."

# 5. Create NEXT_STEPS.md
NEXT_STEPS_FILE="NEXT_STEPS.md"
cat > "$NEXT_STEPS_FILE" << EOF
# Next Steps: Your First Prompt for the AI Agent

Copy the following instructions and paste them into the Cursor chat to begin the development process.

---

1.  **Analyze Context**: Read the \`context.md\` file thoroughly to understand the project's Primary Goal, the designated AI Model, and any provided References.
2.  **Deconstruct the Goal**: Based on your analysis, break down the Primary Goal into a logical sequence of smaller, actionable sub-goals.
3.  **Propose a Plan**: Present a detailed, step-by-step TODO list that outlines the implementation plan for the *first* sub-goal. For each step, specify which files you intend to create or modify.
4.  **Confirm Before Acting**: After presenting the plan, ask for my confirmation before you begin writing any code or modifying any files.

---
EOF

# 6. Copy Log Templates
DEVLOG_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/DEVLOG.md.template"
CHANGELOG_TEMPLATE_PATH="$CENTRAL_REPO_PATH/templates/CHANGELOG.md.template"
DEVLOG_DEST_PATH="$PROJECT_ROOT/DEVLOG.md"
CHANGELOG_DEST_PATH="$PROJECT_ROOT/CHANGELOG.md"

if [ -f "$DEVLOG_TEMPLATE_PATH" ] && [ ! -f "$DEVLOG_DEST_PATH" ]; then
    cp "$DEVLOG_TEMPLATE_PATH" "$DEVLOG_DEST_PATH"
fi
if [ -f "$CHANGELOG_TEMPLATE_PATH" ] && [ ! -f "$CHANGELOG_DEST_PATH" ]; then
    cp "$CHANGELOG_TEMPLATE_PATH" "$CHANGELOG_DEST_PATH"
fi

# 7. Post-Initialization Guidance
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
