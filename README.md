# Cursor Configs

This repository stores and manages the configuration and context files for working with the Cursor AI assistant. The goal is to create a standardized, efficient, and evolving framework for initiating and executing software projects with an AI pair programmer.

## Core Components

1.  **`context_general.md`**: A general context file that outlines the foundational principles, communication styles, and workflows for any project. This serves as the base template.
2.  **Project-Specific Contexts**: (Future) A collection of specialized context files for different types of projects (e.g., `python_api_context.md`, `react_frontend_context.md`).

## The Meta-Workflow

This project is "meta" in that it defines the process for how we define processes. The key idea is that our methods for collaboration should continuously improve. The workflows and context files in this repository are not static; they are expected to be updated as we discover better ways of working together.

## Getting Started

### One-Time Setup

To start using this framework, you need to install the initialization tool. This only needs to be done once per machine.

1.  **Clone this repository**:
    ```powershell
    git clone https://github.com/JasonK94/cursor_configs.git
    ```

2.  **Run the installation script**:
    Open a PowerShell terminal, navigate into the cloned directory, and run the installer.
    ```powershell
    cd cursor_configs
    ./scripts/install.ps1
    ```
    This script will copy the repository to a central location on your machine and add a `Start-CursorProject` command to your PowerShell profile.

3.  **Restart your terminal** or run `. $PROFILE` to make the new command available.

### Usage for New Projects

Once the one-time setup is complete, you can initialize any new project with a single command.

1.  Create a new directory for your project and navigate into it.
    ```powershell
    mkdir my-new-project
    cd my-new-project
    ```
2.  Initialize a git repository.
    ```powershell
    git init
    ```
3.  Run the initialization command:
    ```powershell
    Start-CursorProject
    ```
4.  Follow the interactive prompts to define your project's goal and the AI model you'll be using. The script will automatically create a `context.md` file for you, and you can begin your project.

### Recommended Workflow After `cinit`

After `cinit` successfully creates your `context.md`, follow these steps:

1.  **Enrich the Context**: Open the new `context.md`. Add more specific details, requirements, or constraints to the "Primary Goal" section. If you have them, add more links or file paths to the "References" section. A rich context leads to better results.
2.  **Start the Conversation**: Begin your session with the AI assistant. A good starting prompt is:
    > "Read the `context.md` file, understand the goal, and propose a step-by-step plan to achieve it."
3.  **Iterate**: Use the AI to execute the plan, one step at a time. Update `context.md` as the project evolves to reflect new decisions or changes in scope.

## Further Reading

-   **[Documentation Structure](./docs/project_structure.md)**: Understand the difference between the "model" documents in this repository and the "project" documents you'll be creating.
-   **[PowerShell Caveats & FAQ](./docs/powershell_caveats.md)**: Answers to common questions about the PowerShell environment and why the installer is designed the way it is.

## Development History

- Use `DEVLOG.md` to capture narrative context across sessions.
- Use `CHANGELOG.md` to record notable, versioned changes.
- Prefer local commits during active development; push only major/stable updates or when sharing is needed.
