# PowerShell 주의 사항 & FAQ

PowerShell 환경에서 자주 발생하는 이슈와 질문을 정리했습니다. 특히 터미널 종류에 따라 동작이 다른 이유와 스크립트가 이를 어떻게 처리하는지 설명합니다. 영어 버전은 `docs/powershell_caveats.md`에서 확인하세요.

### 1. Cursor(VS Code)와 시스템 PowerShell이 다르게 동작하는 이유는?

두 환경 모두 동일한 PowerShell 엔진을 사용하지만, “호스트” 애플리케이션이 달라서 프로필, 설정, 모듈 버전 등이 달라질 수 있습니다. 그래서 어떤 터미널에서는 되던 명령이 다른 터미널에서는 실패하는 경우가 발생했습니다. `install.ps1`은 주요 프로필 위치에 모두 명령 구성을 기록해 이 문제를 완화합니다.

### 2. 확장 프로그램이 PowerShell 동작에 영향을 주나?

예. VS Code의 PowerShell 확장은 자체 통합 터미널을 제공하며, `Microsoft.VSCode_profile.ps1` 같은 별도 프로필을 사용합니다. 환경 차이를 만드는 대표적인 사례입니다.

### 3. 기본 PowerShell 프로필은 어디에 저장되어 있나?

PowerShell에는 여러 프로필 파일이 있고, 특정 순서로 로드됩니다.

- `$PROFILE.CurrentUserAllHosts`: 대부분 `Documents\PowerShell\Profile.ps1` 위치. 스크립트가 기본적으로 갱신하는 경로입니다.
- `$PROFILE.CurrentUserCurrentHost`: 현재 호스트 전용 프로필. 예: VS Code 환경의 `Documents\PowerShell\Microsoft.VSCode_profile.ps1`. 보조 경로로 함께 갱신합니다.

### 4. PATH 환경변수 변경 시 주의할 점은?

스크립트가 PATH를 수정해도 현재 터미널에는 바로 반영되지 않는 경우가 많습니다.

- **`cinit.cmd` 셈**: 설치 프로그램이 사용자 PATH에 셈이 있는 디렉터리를 추가합니다. 설치 후 새 터미널을 열어야 `cinit` 명령을 인식합니다.
- **Cursor 터미널**: 설치 당시 터미널이 열려 있었다면, 새 터미널을 열거나 Cursor를 재시작해야 최신 PATH가 적용됩니다.

### 5. 시스템 PowerShell에서는 되는데 Cursor에서는 `cinit`가 안 되는 이유는?

대부분 앞서 언급한 PATH 반영 지연 때문입니다. 설치 후 새 터미널(또는 Cursor 재시작)을 열면 해결됩니다.

### 6. `. $PROFILE` 명령이 실패한 이유는?

1. 호스트마다 `$PROFILE` 경로가 다르며, 해당 파일이 존재하지 않을 수 있습니다.
2. PowerShell 보안 정책상 실행 시 전체 경로 또는 상대 경로(`.\profile.ps1`)를 지정해야 합니다.

`install.ps1`이 필요한 프로필 파일을 자동으로 생성·갱신하므로 수동으로 관리할 필요가 없습니다.

### 7. 시스템 변수를 스냅샷하여 버전 관리해야 할까?

인프라스트럭처 코드(IaC) 관점에서 좋은 아이디어지만, 현재 도구 범위에서는 과도합니다. 스크립트는 사용자 PATH에 새 디렉터리를 추가할 뿐 기존 값을 수정하지 않습니다. 필요 시 PATH 항목과 `~/.cursor_configs` 디렉터리를 삭제하면 제거가 완료됩니다.

### 8. PowerShell 프로필 경로가 왜 OneDrive 아래로 잡히는가?

Windows 10/11에서는 기본적으로 `Documents` 폴더를 OneDrive와 동기화합니다. PowerShell 프로필이 `Documents` 아래에 생성되므로 자연스럽게 OneDrive 경로를 사용하게 됩니다. 시스템 PowerShell과 VS Code PowerShell 모두 이 위치를 참조합니다.

### 9. 서로 다른 PowerShell(시스템, VS Code 등)은 어떻게 업데이트되는가?

업데이트 방식은 두 가지입니다.

1. **수동 업데이트**: `.\scripts\install.ps1`을 다시 실행하면 `~/.cursor_configs` 저장소를 `git pull`로 갱신합니다. 설치 로직 자체를 업데이트할 때 사용합니다.
2. **자동 업데이트**: `cinit` 실행 시 가장 먼저 중앙 저장소에서 `git pull`을 수행하여 항상 최신 로직을 사용합니다. 프로젝트를 시작하지 않고도 최신 상태를 유지하려면 언제든 `cupdate` 명령을 실행하세요.

---

## 유용한 진단 명령

아래 명령은 서로 다른 PowerShell 터미널의 환경을 비교할 때 도움이 됩니다.

- PATH 확인
  ```powershell
  $env:Path -split ';'
  ```
- 프로필 파일 경로 확인
  ```powershell
  $PROFILE | Format-List *
  ```
- PowerShell 버전 상세 확인
  ```powershell
  $PSVersionTable | Format-List
  ```
- 출력 내용을 클립보드에 복사
  ```powershell
  $PSVersionTable | Out-Clipboard
  ```

