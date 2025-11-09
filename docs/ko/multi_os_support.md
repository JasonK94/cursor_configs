# 멀티 OS 지원 설계

`cinit` 워크플로를 Windows와 Unix 계열(Linux, macOS)에서 동일하게 사용할 수 있도록 설계한 이유와 구조를 설명합니다. 영어 버전은 `docs/multi_os_support.md`를 참고하세요.

## 핵심 원칙: 플랫폼별 병렬 구현

OS마다 조건문을 늘어놓은 하나의 거대 스크립트 대신, **플랫폼에 맞는 별도 구현**을 유지합니다.

- **Windows**: PowerShell(`.ps1`)로 주요 로직을, CMD 셈(`.cmd`)으로 명령어 진입점을 제공합니다. Windows에서 가장 안정적인 방식입니다.
- **Linux/macOS**: Bash(`.sh`) 스크립트와 실행 가능한 셈을 사용합니다. 유닉스 환경의 표준 관례를 따릅니다.

이렇게 분리하면 각 스크립트가 간결하고 가독성이 높으며, 운영체제 고유의 관례를 그대로 사용할 수 있어 유지보수가 쉬워집니다.

## 플랫폼별 `cinit` 동작 방식

사용자가 경험하는 명령은 동일(`cinit`)하지만, 내부 동작은 OS에 따라 다릅니다.

### Windows

1. **`install.ps1`**
    - 저장소를 `~/.cursor_configs`에 clone/pull
    - CMD 셈 `~/.cursor_configs/bin/cinit.cmd` 생성
    - **핵심**: `~/.cursor_configs/bin`을 사용자 PATH(레지스트리)에 추가하여 어디서든 `cinit` 사용 가능
    - 여러 PowerShell 프로필에도 명령과 alias를 등록
2. **`cinit` 실행**
    - 사용자가 `cinit` 입력 → PATH에서 `cinit.cmd` 찾음
    - `cinit.cmd`가 `init_project.ps1`을 실행하며 현재 디렉터리(`%CD%`) 전달

### Linux & macOS

1. **`install.sh`**
    - 저장소를 `~/.cursor_configs`에 clone/pull
    - 실행 가능한 셈 `~/.local/bin/cinit` 생성 (`~/.local/bin`은 사용자 전용 실행 파일 경로 표준)
    - **핵심**: 사용자의 쉘 프로필(`.bashrc`, `.zshrc` 등)에 `~/.local/bin` PATH 추가
2. **`cinit` 실행**
    - 사용자가 `cinit` 입력 → PATH에서 `~/.local/bin/cinit` 찾음
    - 셈이 `init_project.sh`를 실행하며 현재 디렉터리(`$PWD`) 전달

이중 셈 구조 덕분에 각 OS에서 가장 자연스러운 사용자 경험을 제공합니다.

