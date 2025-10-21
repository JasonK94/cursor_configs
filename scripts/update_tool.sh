#!/bin/bash
# update_tool.sh - Updates the cursor_configs tool for Linux and macOS.

set -e # Exit immediately if a command exits with a non-zero status.

# Define Paths
CENTRAL_REPO_PATH="$HOME/.cursor_configs"

# Helper Functions
print_success() {
    printf "\e[32m%s\e[0m\n" "$1"
}

print_error() {
    printf "\e[31m%s\e[0m\n" "$1"
}

print_info() {
    printf "\e[36m%s\e[0m\n" "$1"
}

# Check if the repository directory exists
if [ ! -d "$CENTRAL_REPO_PATH" ]; then
    print_error "Error: The directory '$CENTRAL_REPO_PATH' does not exist."
    print_error "Please run the installation script first."
    exit 1
fi

# Navigate to the repository and pull the latest changes
print_info "Checking for updates in '$CENTRAL_REPO_PATH'..."
cd "$CENTRAL_REPO_PATH"

output=$(git pull)
exit_code=$?

if [ $exit_code -eq 0 ]; then
    if [[ "$output" == "Already up to date." ]]; then
        print_success "cursor_configs is already up to date."
        last_commit_date=$(git log -1 --format="%cd" --date=iso)
        print_info "Last updated on: $last_commit_date"
    else
        print_success "cursor_configs has been successfully updated."
        echo "$output"
    fi
else
    print_error "An error occurred during the update process."
    exit 1
fi

cd - > /dev/null
