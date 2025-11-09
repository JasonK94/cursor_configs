# Cursor Configs 소개

이 저장소는 Cursor AI 어시스턴트와 협업하기 위한 설정과 컨텍스트 파일을 관리합니다. 목표는 AI 페어 프로그래밍을 활용한 프로젝트를 표준화된 방식으로 빠르게 시작하고, 지속적으로 개선 가능한 작업 환경을 제공하는 것입니다.

> English version is available in `README.md`.

## 핵심 구성 요소

1. **모델 문서(이 저장소)**: `context.md`, `docs/` 등의 가이드와 메타 에이전트 워크플로를 통해 Cursor 기반 프로젝트 운영 방식을 설명합니다.
2. **템플릿(`templates/` 디렉터리)**: `cinit` 명령이 새 프로젝트마다 복사하는 기본 파일들입니다. 예: `cursor_configs_context.md.template`, `DEVLOG.md.template`, 한·영 README 템플릿, 프로젝트 컨텍스트 템플릿 등.
3. **자동화 스크립트(`scripts/`)**: 설치 및 유지보수 도구(`install`, `init_project`, `update_tool`)로 `cinit`, `cupdate` 명령을 제공합니다.

## 메타 워크플로 개요

이 프로젝트는 “프로세스를 정의하는 프로세스”를 다룹니다. 협업 방식은 고정되어 있지 않고, 실무 경험을 반영하여 계속 발전시킵니다. 모든 변경 사항은 `DEVLOG.md`와 `CHANGELOG.md`에 기록하여 추적합니다.

### 설치 전제 조건

- **필수 도구**
  - Git
  - Cursor
  - PowerShell(Windows), bash/zsh(Linux/macOS)
- **권장 도구**
  - GitHub CLI (`gh`)
  - Mermaid 미리보기 확장

## 설치 및 업데이트

### 최초 설치

1. 저장소 클론  
   ```powershell
   git clone https://github.com/JasonK94/cursor_configs.git
   ```
2. 설치 스크립트 실행  
   - Windows: `./scripts/install.ps1`  
   - Linux/macOS: `sh ./scripts/install.sh`
3. 터미널을 재시작하여 `cinit`, `cupdate` 명령을 사용합니다.

### 업데이트

새로운 템플릿이나 스크립트를 받아오려면 다음 명령을 실행하세요.

```sh
cupdate
```

`~/.cursor_configs` 디렉터리로 최신 변경 사항을 가져옵니다.

## 새 프로젝트 시작하기 (`cinit`)

1. 새 프로젝트 폴더 생성 후 이동  
   ```sh
   mkdir my-new-project
   cd my-new-project
   ```
2. 필요 시 `git init`
3. `cinit` 실행 및 질문에 답변  
   - 프로젝트 목표
   - 사용할 AI 모델
   - 생성할 문서 언어 (기본: 한·영 동시)
4. 스크립트는 `context.md`, `NEXT_STEPS.md`, 로그 템플릿, 선택한 언어의 README 등을 생성합니다.

## `cinit` 이후 권장 흐름

1. 생성된 `context.md`를 열어 목표와 제약을 구체화합니다.
2. `NEXT_STEPS.md`의 프롬프트를 Cursor 챗에 붙여 넣어 첫 플랜을 수립합니다.
3. 작업이 진행되면 `context.md`, `project_context.md`, `DEVLOG.md` 등을 갱신합니다.

## 모델 문서 vs 템플릿

- **루트 README, docs/**: Cursor-configs 자체를 개선하거나 이해하기 위한 자료입니다. 이 저장소를 개발하거나 운영 규범을 살펴볼 때 참고합니다.
- **templates/**: `cinit`이 프로젝트마다 복사하는 원본 템플릿입니다. 새로운 표준이 필요할 때만 직접 수정하세요.

자세한 설명은 `docs/project_structure.md` 및 한국어 버전(`docs/ko/project_structure.md`)을 참고하세요.

## 추가 자료

- `docs/project_structure.md`: 모델 문서와 프로젝트 문서의 차이
- `docs/cursor_workflow.md`: Cursor 협업 워크플로 (한국어 버전: `docs/ko/cursor_workflow.md`)
- `docs/multi_os_support.md`: 멀티 OS 지원 세부 사항 (한국어 버전 포함)
- `docs/powershell_caveats.md`: PowerShell 환경 주의 사항 (한국어 버전 포함)

## 기록 정책

- `DEVLOG.md`: 세션별 의사결정과 다음 계획을 기록
- `CHANGELOG.md`: Keep a Changelog 형식으로 버전 변화를 정리
- 한국어 요약은 각각 `DEVLOG_KO.md`, `CHANGELOG_KO.md`에서 제공합니다.

지속적인 개선을 위해 제안이나 발견한 문제를 `DEVLOG.md`에 먼저 기록하고, 필요하다면 관련 문서와 템플릿을 갱신하세요.

