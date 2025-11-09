# PowerShell Caveats & FAQ

> Korean translation: `docs/ko/powershell_caveats.md`

This document addresses common issues and questions regarding the PowerShell environment, particularly the differences between terminals and how our scripts handle them.

### 1. Why does PowerShell behave differently in Cursor (VS Code) vs. the System Terminal?
*(PS는 원래 vs-code(cursor)와 시스템에서 사용하는 게 다른가?)*

Yes, they are slightly different. Both use the same PowerShell engine, but they are different "host" applications. This means they can have their own separate profile scripts, settings, and sometimes even module versions. This is the primary reason we encountered issues where a command worked in one terminal but not another.

Our `install.ps1` script now mitigates this by writing the command configuration to multiple profile locations, covering all common hosts.

### 2. Do extensions change PowerShell behavior?
*(확장프로그램을 깔면서 바뀌나?)*

Yes. The official "PowerShell" extension for VS Code is a good example. It provides its own integrated terminal environment which has its own profile (`Microsoft.VSCode_profile.ps1`). This is a common source of confusion.

### 3. Where are the default PowerShell config files (profiles)?
*(그래서 각 PS의 default config은 어디에 있는가?)*

PowerShell has several profile files that load in a specific order. The most important ones for our purposes are:

-   `$PROFILE.CurrentUserAllHosts`: For all hosts (e.g., `Documents\PowerShell\Profile.ps1`). This is the **primary** location our script now targets.
-   `$PROFILE.CurrentUserCurrentHost`: For the specific host you're in (e.g., `Documents\PowerShell\Microsoft.VSCode_profile.ps1` for VS Code). Our script now writes to this as a fallback.

The `install.ps1` script now robustly writes to all of these potential locations to ensure commands are available everywhere.

### 4. What should I be aware of regarding the PATH variable?
*(PATH 관련해서 변동사항이나 내가 명심해야할 사항이 있는가?)*

The key takeaway is that changes to the PATH environment variable (especially those made by a script) are often **not reflected in your current, running terminal session**.

-   **The `cinit.cmd` Shim**: To solve this, our installer creates a `.cmd` file (a "shim"). It adds the location of this file to your User PATH in the Windows Registry. This makes the `cinit` command available globally in **any new terminal you open after installation**.
-   **Cursor Terminals**: If Cursor's integrated terminal is still open during installation, it won't see the new PATH. You must **restart Cursor or open a new integrated terminal** (`Terminal > New Terminal`) for the change to take effect.

### 5. Why did `cinit` work in the system PS but not in Cursor's PS?
*(지금 왜 시스템 PS는 cinit이 잘 먹히는데, cursor에서는 새로 킨 powershell에서 cinit이 잘 안 먹히는가?)*

This was likely due to the PATH issue described above. The system terminal where it worked was probably opened *after* the installer had successfully updated the PATH in the registry. The Cursor terminal that failed was likely an older session that was started *before* the PATH was updated, so it had an outdated copy of the environment variables.

### 6. Is my system PATH messed up? Why did `. $PROFILE` fail?
*(아까 내가 보내준 로그를 보면, 뭔가 PATH나 기본 명령어가 좀 꼬여 있는 것같은데. . $PROFILE같은 것도 안 먹히고. 이상 없는 거 맞아?)*

Your system is likely fine. The `. $PROFILE` command failed for two reasons:
1.  As mentioned, different hosts have different `$PROFILE` variables, so you might have been in a terminal where that specific file didn't exist yet.
2.  Even if the file exists in your current directory, PowerShell's security features prevent you from running scripts with just `profile.ps1`. You must use the full path or relative path, like `.\profile.ps1`.

Our installer now handles all of this complexity for you. You should not need to worry about managing profiles manually.

### 7. Should we snapshot and version control system variables?
*(PS config이나 명령어 등 시스템에 영향을 주는 패치를 적용한다면, 기존 시스템 변수들을 snapshot 해서 이 프로젝트에서 버전 관리를 해야 하지 않을까?)*

This is an advanced and thoughtful concept, often used in Infrastructure-as-Code (IaC). For our current needs, it's a bit too complex.

Our script is designed to be minimally invasive. It only **appends** a new, unique directory to your PATH. It never deletes or overwrites existing paths. The "uninstall" process would simply be to remove that one specific entry from your PATH and delete the `~/.cursor_configs` directory, which is a very low-risk operation. Versioning the entire system PATH is therefore not necessary for this tool.

### 8. Why does my PowerShell profile path point to OneDrive?
*(왜 내 파워쉘은 onedrive 하위 폴더에 있는가?)*

This is normal behavior on modern Windows systems (10/11). By default, Windows often syncs the `Documents` folder with OneDrive. Since PowerShell profiles are created within `Documents`, their path will naturally point to a location inside your OneDrive folder if syncing is active. Both system PowerShell and integrated terminals (like in Cursor/VS Code) will correctly reference this synced location.

### 9. How are all the different PowerShells (System, VS Code, etc.) updated?
*(시스템 파워쉘, 원드라이브 파워쉘, vs-code 파워쉘 다 cinit에 의해 자동으로 업데이트 되는가?)*

The `cinit` command itself does not run the installer. The update mechanism works in two ways:
1.  **Manual Update**: When you manually run `.\scripts\install.ps1`, the script updates the central repository (`~/.cursor_configs`) via `git pull`. This is for updating the installer logic itself.
2.  **Automatic Update**: When you run `cinit`, the `init_project.ps1` script's first action is to run `git pull` from within the central repository. This ensures that every time you start a new project, you are using the latest version of the core logic, regardless of which PowerShell you run it from. You can also run `cupdate` at any time to refresh without kicking off a project initialization.

---

## Useful Diagnostic Commands

Here are some commands you can run in different PowerShell terminals to understand and compare their environments.

-   **Check the full PATH variable**:
    ```powershell
    $env:Path -split ';'
    ```

-   **See all profile file paths**:
    ```powershell
    $PROFILE | Format-List *
    ```

-   **Check PowerShell Version (un-truncated)**:
    ```powershell
    $PSVersionTable | Format-List
    ```

-   **Copy output to clipboard (to avoid truncation)**:
    ```powershell
    # Example:
    $PSVersionTable | Out-Clipboard
    ```
