# Kotlin/KMP 프로젝트 마스터 지침 (CLAUDE_COMMON)

> **이 파일은 모든 Kotlin/KMP 프로젝트에 공통 적용되는 글로벌 규칙이다.**
> 프로젝트별 특화 규칙은 각 프로젝트의 `INSTRUCTIONS.md`에서 정의한다.

---

## 0. [TOP PRIORITY] Smart Resource & Batch Strategy

> Claude Max 플랜의 성능을 극한으로 활용하면서 한도를 효율적으로 관리하는 전략.
> 이 섹션은 모든 다른 규칙보다 **최상위 우선순위**로 적용된다.

### 0-1. Dynamic Model Tiering (동적 모델 운용 전략)

작업 복잡도에 따라 적합한 모델을 동적으로 선택한다.

| Tier | 모델 | 적용 작업 | 예시 |
|------|------|----------|------|
| **Tier 1 (Max)** | Opus | 아키텍처 설계, 대규모 리팩토링, 복잡한 디버깅, 심층 코드 리뷰 | 멀티모듈 구조 변경, 보안 취약점 분석 |
| **Tier 2 (Standard)** | Sonnet | 일반 기능 구현, UI 작성, 단위 테스트, 문서화 | 화면 구현, UseCase, Repository, 버그 수정 |
| **Tier 3 (Eco)** | Haiku | 단순 텍스트 수정, 주석 처리, 리소스 키 생성, 코드 포매팅 | i18n 키 추가, 간단한 검색/확인 |

**자동 전환 규칙 (Action Rules):**
- 현재 Tier 1 모델인데 단순 반복 작업(리소스 키 생성, 포매팅 등)을 수행 중이면:
  → "이 작업은 Tier 3(Eco) 모델로도 충분합니다. `/model haiku` 전환을 추천합니다."
- 현재 Tier 3 모델인데 복잡한 추론(아키텍처 설계, 멀티파일 리팩토링)이 필요하면:
  → "이 작업은 Tier 1(Max) 모델이 필요합니다. `/model opus` 전환을 권장합니다."
- 서브에이전트 배정 시에도 동일 기준 적용: 복잡한 로직 → Opus, 정형화된 작업 → Sonnet/Haiku.
- 판단이 어려우면 Sonnet을 기본으로 시작하고, 품질 부족 시 Opus로 전환한다.

### 0-2. Batch Processing Protocol (병렬/배치 처리)

파일 라운드트립(Round-trip)을 최소화하여 작업 속도를 높인다.

1. **Multi-File Parallel Edit (필수)**:
   - 여러 파일을 수정할 때 한 턴에 하나씩 처리하지 않는다.
   - 관련된 모든 파일의 변경 사항을 분석한 뒤, **한 번의 응답에 독립적인 파일들을 동시에 수정**한다.
   - 의존성이 있는 수정은 순차 처리하되, 독립적인 수정은 반드시 병렬 처리한다.

2. **Look-Ahead Context (예측 읽기)**:
   - 파일을 읽을 때, 해당 파일의 `import` 구문을 분석하여 의존 파일들을 예측한다.
   - 곧 필요할 것으로 판단되는 관련 파일들을 한 번에 읽어들여 추가 라운드트립을 방지한다.
   - 특히 `interface → impl`, `UiState → ViewModel → Screen` 체인은 한 번에 읽는다.

3. **Hardware-Aware Build**:
   - 시스템 RAM이 16GB 이상이면 로컬 빌드/테스트를 적극 수행하여 코드 완결성을 검증한다.
   - 빌드 시 CPU 점유율 100% 방지를 위해 Gradle 병렬 빌드 옵션(`--parallel`)을 활용한다.
   - RAM이 부족한 환경에서는 `--no-daemon` 옵션으로 메모리를 절약한다.

4. **Context Window 최적화**:
   - 200k 토큰 컨텍스트 윈도우를 효율적으로 사용한다.
   - `.claudeignore`를 통해 빌드 아티팩트, IDE 설정, 바이너리 파일을 제외한다.
   - 대규모 수정 시 인터페이스/시그니처를 먼저 스캔하여 구조를 파악한 뒤, 필요한 구현부만 읽는다.

### 0-3. 사용량 모니터링

- **주간 한도 인지**: Max 플랜의 모든 모델 통합 주간 한도와 Sonnet 전용 주간 한도를 인지한다.
- **Extra Usage**: 대규모 작업 전 API 크레딧 자동 전환 옵션 설정 여부를 확인한다.
- **모니터링 습관**: `/cost`로 세션 토큰 사용량을, `/status`로 남은 할당량을 수시로 확인한다.

---

## 1. 에이전트 협업 및 병렬 워크플로우

### 1-1. 에이전트 역할 구분

- **Main Agent (Orchestrator)**: 요구사항 분석 → 작업 계획 수립 → Sub-agents에 분배 → 결과물 통합(Merge) → 아키텍처 정합성 검증.
- **Sub-agents (Specialists)**:
  - `ui-architect`: UI/UX, Compose/KMP UI, 플랫폼 대응.
  - `logic-expert`: 비즈니스 로직, Clean Architecture(Domain/Data), MVI 흐름.
  - `i18n-specialist`: 다국어 리소스, 지역화 표준, 국가별 포맷팅.
  - `data-specialist`: API 연동, DB 스키마, 데이터 모델링.
  - `project-organizer`: 빌드 설정, 의존성 관리, 패키지 구조 정돈.
  - `refactor-bot`: 코드 품질 개선, 성능 최적화, 상호 검증.
  - `doc-master`: 문서화, KDoc, README 최신화.

### 1-2. 병렬 작업 및 통합 지침

1. **작업 분할 (Parallel Spawning)**: 복합 요구사항을 UI/Logic/Resource 등 독립 수행 가능한 단위로 분할하여 동시 요청한다.
2. **인터페이스 계약 (Contract First)**: 병렬 작업 전, 에이전트 간 접점(ViewModel 인터페이스, UiState, Resource Key)을 먼저 확정한다.
3. **독립 수행**: 타 영역 의존성 발생 시 Mock 또는 인터페이스를 활용한다.
4. **자동 검증 (Build-Check-Loop)**: 코드 수정 후 반드시 빌드를 실행한다.
5. **최종 통합 및 보고**: `git diff` 기반 변경 사항을 한국어로 보고한다. 아키텍처 영향도가 큰 변경은 상세 분석을 포함한다.

### 1-3. 세션 관리

- 대규모 수정 시 인터페이스/UseCase 시그니처를 먼저 스캔하여 전체 구조를 빠르게 파악한다.
- 세션이 매우 길어진 경우 `/clear`를 선택적으로 사용하되, 작업 흐름이 끊기지 않는 것을 우선한다.

---

## 2. 소통 및 언어 규칙

- **언어**: 모든 대화, 분석, 질문, 에러 보고는 **한국어**로 진행한다.
- **응답 품질**: 아키텍처 결정 근거, 플랫폼별 차이점, 잠재적 이슈 등 유의미한 설명을 포함하되 불필요한 장황함은 지양한다.
- **사전 확인**: 모호한 부분(스크롤 범위, 비율 유지, 로직 누락 등)은 구현 전 반드시 질문한다.
- **번역 기준**: 기본 UI 리소스는 **한국어(ko)**를 최우선 기준으로 생성한다.

> **Language Protocol:**
> ALL responses, questions, and thinking processes MUST be in **Korean (한국어)**.
> Even if the user asks in English, translate the context and reply in Korean unless explicitly asked to speak English.

---

## 3. 기술 스택 및 아키텍처

- **Clean Architecture & Offline-First**: UI → Domain → Data 레이어 분리. 로컬 DB 중심 Offline-First 전략.
- **SSoT (Single Source of Truth)**: 모든 UI 상태는 로컬 DB를 최종 소스로 삼는다. AuthRepository는 외부 결과를 로컬에 동기화한다.
- **MVI Pattern**: `UiState`(불변), `UiIntent`(Sealed), `UiSideEffect`(단발성) 구조를 유지한다.
- **Naming Convention**:
  - Entity: `[Name]Entity`
  - Repository 인터페이스: `[Name]Repository`
  - Repository 구현체: `Firebase[Name]Repository`, `Room[Name]Repository`, `[Name]RepositoryImpl`

---

## 4. UI/UX 및 디자인 시스템

- **공통 컴포넌트 우선**: 모든 화면은 `sharedUI` 모듈의 공통 컴포넌트를 최우선 사용한다.
- **신규 요소 도입**: 기존 컴포넌트 비교 분석 → 확장 가능하면 기존 수정 → 불가능하면 `sharedUI`에 공통 컴포넌트로 먼저 등록.
- **Safe Area**: iOS(Notch/Home Indicator) 및 Android System Bars를 `WindowInsets.safeDrawing` 등으로 강제 반영.
- **스크롤 우선순위**: 0순위(중앙 메인 콘텐츠) → 1순위(리스트) → N순위(기타 보조 뷰).

---

## 5. 리소스 프로토콜

- **Material Icons**: 기본 아이콘 라이브러리를 최우선 사용한다.
- **커스텀 리소스 요청**: 구현 완료 후 `[대상 파일 | 추천 네이밍(ic_/img_) | 포맷 | 디자인 가이드]` 형식으로 요청한다.

---

## 6. 글로벌 지역화 표준 (i18n/L10n)

- **Hardcoding 금지**: 코드 내 문자열 직접 입력은 엄격히 금지한다. 모든 텍스트는 리소스화한다.
- **Key 표준**: `feature_component_action` 형식 (예: `login_button_submit`). 기본 값은 한국어.
- **포맷팅**: 국가별 숫자, 날짜, 통화 표기법을 준수한다.

---

## 7. 개발 퍼포먼스 지침

### 7-1. 포괄적 구현
- 코드 생성 시 **완전한 파일/모듈 단위**로 생성한다.
- 에러 처리, 엣지 케이스, 유효성 검증을 기본 포함한다.
- 핵심 비즈니스 로직에는 **유닛 테스트 코드**를 함께 생성한다.

### 7-2. 플랫폼별 구현 가이드
- `expect`/`actual` 분기 시 **각 플랫폼별 구현 코드를 모두** 제공한다.
- 플랫폼별 알려진 이슈(iOS 키보드 처리, Android 백프레스 등)를 사전 안내한다.

### 7-3. 의사결정 지원
- 아키텍처 결정 시 **장단점 비교표**와 구현 예시 코드를 함께 제공한다.
- 라이브러리 선택 시 KMP 호환성, 커뮤니티 활성도, 유지보수 현황을 비교한다.
- 디버깅 시 **근본 원인 분석(Root Cause Analysis)**을 포함한다.

### 7-4. 고도화된 워크플로우
- **멀티스텝 파이프라인**: 코드 리뷰 → 리팩토링 → 테스트 생성 연속 수행.
- **병렬 서브에이전트**: UI 코드와 테스트 코드를 동시 생성.
- **Git 자동화**: 커밋 메시지, PR 설명, 체인지로그 생성 지원.
- **대규모 변경 리뷰**: 전체 diff를 빠짐없이 리뷰하여 누락 방지.

---

## 8. 작업 완료 프로토콜 (Task Completion Protocol)

> **모든 작업의 마지막 단계**에서 반드시 실행해야 하는 문서 동기화 프로세스.
> 이 프로토콜은 프로젝트 지식이 항상 최신 상태를 유지하도록 보장한다.

### 8-1. 문서 계층 구조 (Documentation Hierarchy)

```
Level 0 (Global):    CLAUDE.md / CLAUDE_COMMON.md     ← 모든 프로젝트 공통 규칙
Level 1 (Project):   INSTRUCTIONS.md                   ← 프로젝트 특화 아키텍처/비즈니스 규칙
                     CONVENTIONS.md                    ← 코딩 컨벤션
                     SKILLS.md                         ← 프로젝트 특화 스킬
                     [도메인별].md                      ← 도메인 가이드 (예: LOCALIZATION.md)
Level 2 (Memory):    memory/MEMORY.md                  ← Auto Memory (세션 간 지속, 200줄 이내)
                     memory/structure.md               ← 파일 구조 참조
                     memory/[topic].md                 ← 주제별 상세 노트
```

### 8-2. 동기화 트리거 조건

작업 완료 시 아래 중 **하나라도 해당**되면 문서 동기화를 실행한다:

| 변경 유형 | 동기화 대상 |
|-----------|------------|
| 새 파일/디렉터리 추가 | `structure.md`, `INSTRUCTIONS.md` |
| expect/actual 추가 | `INSTRUCTIONS.md`, `MEMORY.md` |
| DB 스키마 변경 | `INSTRUCTIONS.md`, `MEMORY.md` |
| 새 화면(MVI) 추가 | `structure.md`, `INSTRUCTIONS.md` |
| DI 모듈 변경 | `INSTRUCTIONS.md` |
| 빌드/릴리스 설정 변경 | `INSTRUCTIONS.md`, `MEMORY.md` |
| 새 도메인 규칙/Gotcha 발견 | `CONVENTIONS.md`, `MEMORY.md` |
| 아키텍처 패턴 변경 | `CLAUDE.md` (글로벌), `INSTRUCTIONS.md` (프로젝트) |
| i18n 리소스 추가/삭제 | 도메인별 가이드 (예: `LOCALIZATION.md`) |

### 8-3. 동기화 실행 절차

1. **변경 영향 분석**: 이번 작업에서 수정/생성된 파일 목록을 기반으로 영향받는 문서를 식별한다.
2. **Top-Down 업데이트**: Level 0 → Level 1 → Level 2 순서로 검토하고 업데이트한다.
3. **업데이트 판단 기준**:
   - 해당 문서에 이미 최신 정보가 반영되어 있으면 → **Skip**
   - 새로운 정보가 추가되어야 하면 → **Update**
   - 기존 정보가 변경/삭제되었으면 → **Update**
4. **변경 보고**: 동기화 결과를 사용자에게 테이블 형태로 보고한다.

```
예시 보고 형식:
| 파일 | 상태 | 변경 내용 |
|------|------|----------|
| INSTRUCTIONS.md | Updated | 새 화면 LanguageSelection 추가 |
| structure.md    | Updated | languageselection/ 디렉터리 추가 |
| MEMORY.md       | Updated | i18n 섹션 추가 |
| CONVENTIONS.md  | Skip    | 변경 없음 |
```

### 8-4. 주의사항

- **CLAUDE.md 수정은 신중하게**: 글로벌 규칙이므로 모든 프로젝트에 영향. 프로젝트 특화 규칙은 반드시 `INSTRUCTIONS.md`에 작성.
- **MEMORY.md 200줄 제한**: 시스템 프롬프트에 자동 로딩되므로 간결하게 유지. 상세 내용은 별도 `memory/[topic].md`로 분리.
- **단순 버그 수정**은 새로운 Gotcha가 발견된 경우에만 `MEMORY.md`에 기록. 일상적 수정은 Skip.
