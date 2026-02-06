# Kotlin/KMP Project Master’s Guide (High Fidelity)


 지침: 에이전트 협업 및 병렬 워크플로우
본 프로젝트는 **Main Agent**의 지휘 아래 전문화된 **Sub-agents**가 병렬로 작업을 수행하는 구조를 유지한다.

### 0-1. 에이전트 역할 구분
- **Main Agent (Orchestrator)**: 사용자의 요구사항을 분석하여 전체 작업 계획을 수립하고, 작업을 Sub-agents에게 분배한다. 최종적으로 각 에이전트의 결과물을 통합(Merge)하고 전체 아키텍처 정합성을 검증한다.
- **Sub-agents (Specialists)**: 특정 도메인에 특화된 지침을 수행하며, 메인 에이전트의 요청에 따라 독립적으로 코드를 생성한다.
    - `ui-architect`: UI/UX, Compose/KMP UI, 플랫폼 대응.
    - `logic-expert`: 비즈니스 로직, Clean Architecture(Domain/Data), MVI 흐름.
    - `i18n-specialist`: 다국어 리소스, 지역화 표준, 국가별 포맷팅.
    - `data-specialist`: API 연동, DB 스키마, 데이터 모델링. (필요 시)
    - `project-organizer`: 빌드 설정, 의존성 관리, 패키지 구조 정돈.

### 0-2. 병렬 작업 및 통합 지침
1. **작업 분할 (Parallel Spawning)**: 메인 에이전트는 복합적인 요구사항을 'UI', 'Logic', 'Resource' 등 각 에이전트가 독립적으로 수행할 수 있는 단위로 쪼개어 동시 요청한다.
2. **인터페이스 계약 (Contract First)**: 병렬 작업 전, 에이전트 간 접점(예: ViewModel 인터페이스, UiState 정의, Resource Key)을 먼저 확정하여 충돌을 방지한다. 단순 기능(저장, 로그인 등)은 요청 단계에서 즉시 인터페이스화하여 공유한다.
3. **독립 수행**: 각 서브 에이전트는 할당된 범위 내에서 최선의 코드를 생성하며, 타 영역에 의존성이 생길 경우 Mock 또는 인터페이스를 활용하여 진행한다. 저장, 로그인, 로그아웃 등 정형화된 단순 기능은 요청 즉시 인터페이스 시그니처를 선언하여 공유한다.
4. **자동 검증 (Build-Check-Loop)**: 코드 수정 후에는 반드시 `./gradlew :app:assembleDebug` 또는 관련 유닛 테스트를 실행하여 성공 여부를 확인한다.
5. **최종 통합 및 보고**: 메인 에이전트는 서브 에이전트들이 제출한 코드를 통합하며, 변경 사항을 `git diff`로 분석하여 핵심 요약만 한국어로 보고한다.

### 0-3. 토큰 최적화 및 세션 관리
- **인터페이스 우선**: 대규모 수정 시 구현부 전체보다는 인터페이스나 UseCase 시그니처(Skeleton)를 먼저 스캔하여 맥락을 파악한다.
- **세션 다이어트**: 세션이 길어져 토큰 소모가 클 경우, `/clear` 실행을 고려한다. 다음 단계로 넘어가기 전 사용자에게 `1. 추천 항목 제안 후 clear`, `2. 즉시 clear 후 새 요청`, `3. clear 없이 진행` 중 선택지를 제공한다.
- **최소 인덱싱**: `.claudeignore`를 통해 빌드 아티팩트와 IDE 설정을 제외하여 인덱싱 데이터를 최소화한다.

## 1. 소통 및 언어 규칙
- **언어**: 모든 대화, 분석, 질문, 에러 보고는 **한국어**로 진행한다.
- **토큰 다이어트**: 인사말과 사설은 생략한다. 핵심 정보와 코드(Diff 위주)로만 응답한다. 작업을 마치면 `git diff` 기반 핵심 요약을 한국어로 보고한다.
- **사전 확인**: 분석 중 모호한 부분(스크롤 범위, 비율 유지, 로직 누락 등)은 구현 전 반드시 질문한다.
- **번역 기준**: 원문 문서가 영문이더라도 모든 로직과 기본 UI 리소스는 **한국어(ko)**를 최우선 기준으로 생성한다.

## 2. 기술 스택 및 아키텍처
- **Clean Architecture & Offline-First**: UI -> Domain -> Data 순서의 레이어 분리 및 로컬 DB 중심의 Offline-First 전략을 고수한다.
- **SSoT(Single Source of Truth)**: 모든 UI 상태는 로컬 DB(Room)를 최종 소스로 삼으며, AuthRepository는 외부(Firebase 등) 결과를 로컬에 동기화한다.
- **MVI Pattern**: `UiState`(불변), `UiIntent`(Sealed), `UiSideEffect`(단발성) 구조를 유지한다.
- **Naming Convention**: 
    - Entity: `[Name]Entity`
    - Repository 인터페이스: `[Name]Repository`
    - Repository 구현체: `Firebase[Name]Repository`, `Room[Name]Repository` 등

## 3. UI/UX 및 디자인 시스템 (sharedUI)
- **공통 컴포넌트 우선**: 모든 화면은 `sharedUI` 모듈의 컴포넌트(`SplitlyTopBar`, `SplitlyButton`, `SplitlyTextField` 등)를 최우선으로 사용한다.
- **신규 요소 도입**: 새로운 UI 요소는 반드시 기존 컴포넌트와 비교 분석 후 '공통 컴포넌트화' 과정을 거쳐 `sharedUI`에 먼저 반영한다.
- **Safe Area**: iOS(Notch/Home Indicator) 및 Android System Bars를 `WindowInsets.safeDrawing` 등으로 강제 반영한다.
- **스크롤 우선순위**: 화면 공간 부족 시 다음 순서로 스크롤을 적용한다:
    - 0순위: 중앙 메인 콘텐츠
    - 1순위: 리스트 형태 구성 요소
    - N순위: 기타 보조 뷰
- **HTML 매핑**: HTML의 `id`, `type`, `required` 등을 분석하여 `UiState` 필드와 유효성 검사 로직에 자동 매핑한다. (UI Architect와 Logic Expert가 공동 분석 후 Main Agent가 통합한다.)

## 4. 리소스 프로토콜
- **Material Icons**: 기본 아이콘 라이브러리를 최우선 사용한다.
- **Resource Request**: 커스텀 리소스가 필요한 경우, 구현 완료 후 아래 형식으로 요청한다.
    - `[대상 파일 | 추천 네이밍(ic_/img_) | 포맷 | 디자인 가이드]`

## 5. 글로벌 지역화 표준 (i18n/L10n)
- **Hardcoding 금지**: 코드 내 문자열 직접 입력은 엄격히 금지한다. 모든 텍스트는 `i18n Specialist`를 통해 리소스화한다.
- **포맷팅**: 국가별 숫자, 날짜, 통화 표기법을 준수하며, 외부 번역 데이터 컨버팅 시 Key의 일관성을 유지한다.
