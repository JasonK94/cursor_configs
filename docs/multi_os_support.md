# Multi-OS Support Design

> Korean translation: `docs/ko/multi_os_support.md`

This document explains the design choices behind making the `cinit` workflow compatible with both Windows and Unix-like systems (Linux, macOS).

## Core Principle: Parallel Implementations

Instead of creating a single, complex script with many OS-specific conditional branches, we opted for a cleaner approach: **parallel, OS-native implementations**.

-   **For Windows**: We use PowerShell (`.ps1`) for logic and a CMD shim (`.cmd`) for command availability. This is the most robust and idiomatic approach for the Windows environment.
-   **For Linux/macOS**: We use Bash (`.sh`) for both logic and the command shim. This is the standard for Unix-like systems.

This separation ensures that each script is simple, easy to read, and uses the standard conventions of its target operating system, which makes maintenance much easier.

## How `cinit` Works on Each Platform

The end-user experience is identical (`cinit` command), but the underlying mechanism differs.

### On Windows

1.  **`install.ps1`**:
    -   Clones/pulls the repository to `~/.cursor_configs`.
    -   Creates a CMD shim file: `~/.cursor_configs/bin/cinit.cmd`.
    -   **Key Step**: Adds the `~/.cursor_configs/bin` directory to the user's `PATH` environment variable in the Windows Registry. This makes `cinit.cmd` available globally.
    -   It also attempts to add aliases to various PowerShell profiles as a fallback.

2.  **Running `cinit`**:
    -   The user types `cinit`.
    -   The system's `PATH` is searched, and `cinit.cmd` is found and executed.
    -   `cinit.cmd` then executes the main logic script (`init_project.ps1`) using `powershell.exe`, passing the user's current directory (`%CD%`) as a parameter.

### On Linux & macOS

1.  **`install.sh`**:
    -   Clones/pulls the repository to `~/.cursor_configs`.
    -   Creates an executable shell script shim: `~/.local/bin/cinit`. (`~/.local/bin` is the standard location for user-specific executables on modern Linux systems).
    -   **Key Step**: Ensures `~/.local/bin` is present in the user's `PATH` by adding an `export PATH` line to their shell profile (`.bashrc`, `.zshrc`, etc.).

2.  **Running `cinit`**:
    -   The user types `cinit`.
    -   The system's `PATH` is searched, and the `~/.local/bin/cinit` script is found and executed.
    -   The `cinit` shim then executes the main logic script (`init_project.sh`), passing the user's current directory (`$PWD`) as a parameter.

This dual-shim approach provides the most reliable and conventional user experience on each respective platform.
