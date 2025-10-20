#!/bin/bash
# install.sh - Installs or updates the cursor_configs tool for Linux and macOS.

set -e # Exit immediately if a command exits with a non-zero status.

# 1. Define Paths
CENTRAL_REPO_PATH="$HOME/.cursor_configs"
REPO_URL="https://github.com/JasonK94/cursor_configs.git"
SHIM_DIR="$HOME/.local/bin"
INIT_SCRIPT_PATH="$CENTRAL_REPO_PATH/scripts/init_project.sh"
SHIM_PATH="$SHIM_DIR/cinit"

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

# 2. Install or Update the Core Repository
if [ -d "$CENTRAL_REPO_PATH" ]; then
    print_info "Updating existing cursor_configs repository..."
    cd "$CENTRAL_REPO_PATH"
    git pull
    cd - > /dev/null
    print_success "Update complete."
else
    print_info "Installing cursor_configs for the first time..."
    if ! git clone "$REPO_URL" "$CENTRAL_REPO_PATH"; then
        print_error "Error cloning repository. Please ensure Git is installed and you have network connectivity."
        exit 1
    fi
    print_success "Installation complete."
fi

# 3. Create Shim Directory if it doesn't exist
mkdir -p "$SHIM_DIR"

# 4. Create the 'cinit' shim executable
cat > "$SHIM_PATH" << EOF
#!/bin/bash
# This shim executes the main cinit logic.
# It passes the current working directory to the script.

exec bash "$INIT_SCRIPT_PATH" --project-root "\$PWD" "\$@"
EOF

chmod +x "$SHIM_PATH"
print_success "cinit command created at $SHIM_PATH"

# 5. Ensure Shim Directory is on PATH
# Detect shell profile
if [ -n "\$BASH_VERSION" ]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [ -n "\$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
else
    PROFILE_FILE="$HOME/.profile"
fi

if ! grep -q "$SHIM_DIR" "\$PROFILE_FILE"; then
    print_info "Adding $SHIM_DIR to your PATH in $PROFILE_FILE..."
    {
        echo ''
        echo '# Add cursor_configs shim directory to PATH'
        echo "export PATH=\"\$PATH:$SHIM_DIR\""
    } >> "\$PROFILE_FILE"
    print_success "$SHIM_DIR added to PATH. Please restart your terminal or run 'source \$PROFILE_FILE'."
else
    print_info "$SHIM_DIR is already in your PATH."
fi

print_success "Setup finished!"
