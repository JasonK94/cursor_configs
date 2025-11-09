# 변경 로그 (CHANGELOG_KO)

이 문서는 `CHANGELOG.md`의 한국어 요약본입니다. 원문은 Keep a Changelog 형식을 따르며 시맨틱 버저닝을 준수합니다.

## [개발 중]
### 추가
- **오류 학습 메커니즘**: `cursor_configs_context.md.template`(구 `context.md.template`)에 “Project-Specific Caveats (Learned Lessons)” 섹션을 추가하여 과거 실수를 기록하고 재발을 방지할 수 있도록 했습니다.
- **한국어 문서 지원**: 핵심 문서·템플릿을 한국어로 번역하고, `cinit`에서 영어/한국어/양어 선택 옵션을 제공하도록 업데이트했습니다.

### 변경
- 템플릿 명칭을 `templates/context.md.template`에서 `templates/cursor_configs_context.md.template`로 (한국어 버전 포함) 변경하여 메타 컨텍스트임을 명확히 했습니다.

## [0.2.0] - 2025-10-20
### 추가
- **Linux & macOS 지원**: Bash 기반 설치(`install.sh`)와 초기화(`init_project.sh`) 스크립트 작성으로 유닉스 계열 환경에서도 동일한 기능 제공
- `DEVLOG.md`, `CHANGELOG.md` 자동 생성
- 초기 Cursor 세션을 돕는 `NEXT_STEPS.md` 생성
- 신규 문서: `docs/multi_os_support.md`, `docs/project_structure.md`
- `context_general.md`(현 `context.md.template`)에 “Project Artifacts” 섹션 추가

### 변경
- **주요 변경**: 프로젝트가 완전한 크로스플랫폼 지원을 갖추게 됨
- `README.md`에 OS별 설치 안내와 개선된 워크플로 설명 추가
- `context_general.md`를 `templates/context.md.template`로 이름 변경
- 기존 프로젝트에서 `cinit` 실행 시 값 재사용 가능하도록 개선

### 수정
- PowerShell 스크립트의 작업 디렉터리, 빈 입력, 환경 호환성 관련 주요 버그 다수 해결

## [0.1.0] - 2025-10-20
### 추가
- `context_general.md` 기반 초기 프로젝트 스캐폴딩
- Windows용 `install.ps1`, `init_project.ps1`
- PATH 기반 `cinit.cmd` 셈을 통한 `cinit` 명령
- 기본 설정 및 사용법을 담은 `README.md`

