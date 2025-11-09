# 문서 구조: 모델 문서 vs 프로젝트 문서

이 문서는 `cursor_configs` 저장소 안의 모델 문서와, `cinit` 실행 후 각 프로젝트에서 생성되는 문서의 차이를 설명합니다. 영어 버전은 `docs/project_structure.md`를 참고하세요.

## 1. 모델 문서 (`cursor_configs` 내부)

모델 문서는 모든 Cursor 기반 프로젝트의 기본 규칙과 템플릿을 정의합니다. 메타 프레임워크를 개선할 때 수정하는 대상입니다.

- **위치**: 클론한 `cursor_configs` 저장소 (기본적으로 `~/.cursor_configs`)
- **목적**: 재사용 가능한 표준을 제공하여 향후 프로젝트에 일관성을 보장합니다.
- **예시**:
  - `context.md`: 저장소 전역 규범과 다중 에이전트 계층 구조
  - `docs/`: Cursor 워크플로, 멀티 OS 지원, PowerShell 주의사항 등 가이드 (한국어 버전은 `docs/ko/`)
  - `docs/context/meta_agent.md`: 메타 에이전트 역할과 책임
- `templates/`: `cinit`이 복사해 가는 Markdown 템플릿 (영어·한국어 버전 제공, 저장소 메타 컨텍스트는 `cursor_configs_context*.md.template`)
  - `scripts/`: `cinit`(프로젝트 초기화), `cupdate`(프레임워크 업데이트) 명령을 제공하는 스크립트
- **수정 원칙**: 향후 모든 프로젝트에 공통적으로 적용하고 싶은 개선 사항이 있을 때만 변경합니다. 변경 내역은 `DEVLOG.md`/`DEVLOG_KO.md`에 기록하고, 릴리스 노트는 `CHANGELOG.md` 및 한국어 요약(`CHANGELOG_KO.md`)에 반영합니다.

## 2. 프로젝트 문서 (각 프로젝트 폴더)

새 프로젝트 폴더에서 `cinit`을 실행하면 필요한 템플릿이 복사되며, 선호 언어(1=한·영, 2=영어, 3=한국어)를 선택할 수 있습니다.

- **위치**: 실제 개발을 진행하는 프로젝트 루트 (예: `~/projects/amazon_scraper`)
- **목적**: 해당 프로젝트만의 목표, 제약, 진행 상황을 상세히 기록하여 AI와 사람 모두에게 단일 출처(Single Source of Truth)를 제공합니다.
- **예시**:
- `context.md`: 프로젝트 목표·AI 모델·참고 자료 (`cursor_configs_context*.md.template`에서 생성)
  - `project_context.md`: 프로젝트 상태와 핸드오프 정보를 적는 서술형 문서
  - `DEVLOG.md` / `CHANGELOG.md`: 프로젝트 전용 로그 (언어 설정에 따라 한국어/영어 버전 포함 가능)
  - `README.md` / `README_Korean.md`: 선택한 언어에 맞춰 생성되는 소개 문서
- **수정 원칙**:
  - 프로젝트 진행 중 자유롭게 수정하며 최신 정보를 유지합니다.
  - 모델 문서와는 독립적이므로, 여기서의 변경은 `cursor_configs` 템플릿에 영향을 주지 않습니다.
  - 필요 시 `cinit`을 다시 실행하면 누락된 파일만 보충하며 기존 내용은 유지합니다.

## 3. 프레임워크 업데이트 유지하기

- `cupdate`: `~/.cursor_configs` 디렉터리를 최신 상태로 업데이트합니다.
- 업데이트 후 기존 프로젝트는 그대로 유지되지만, 새로운 템플릿이 필요하면 직접 복사하거나 새 프로젝트에서 `cinit`을 실행하면 됩니다.
- 언어 선택은 `cinit`의 질문에서 조정할 수 있으며, 1=한·영 동시, 2=영어만, 3=한국어만 생성합니다.

## 요약 다이어그램

```
[cursor_configs 저장소]                  [프로젝트 저장소]
-----------------------                  ---------------------
- docs/ (영문 가이드)                     - context.md (프로젝트별)
- docs/ko/ (국문 가이드)                  - project_context.md (선택)
- templates/ (영·한 템플릿)   --cinit-->  - README(.md / _Korean.md)
- scripts/ (cinit, cupdate)              - DEVLOG(.md) / CHANGELOG(.md)
```

