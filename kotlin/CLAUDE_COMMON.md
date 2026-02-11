# Kotlin/KMP 프로젝트 마스터 지침 (CLAUDE_COMMON)

> **이 파일은 모든 Kotlin/KMP 프로젝트에 공통 적용되는 공용 규칙이다.**
> 마스터 레포(`master-claude-code-configs`)에서 관리하며, 프로젝트에서는 `CLAUDE.md`로 심볼릭 링크한다.
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
- Tier 1에서 단순 반복 작업 수행 시 → Tier 3 전환 추천.
- Tier 3에서 복잡한 추론 필요 시 → Tier 1 전환 권장.
- 서브에이전트 배정도 동일 기준. 판단 어려우면 Sonnet 기본.

### 0-2. Batch Processing Protocol (병렬/배치 처리)

파일 라운드트립(Round-trip)을 최소화하여 작업 속도를 높인다.

1. **Multi-File Parallel Edit (필수)**: 독립적인 파일은 한 번의 응답에 동시 수정. 의존성 있는 것만 순차.
2. **Look-Ahead Context (예측 읽기)**: import 분석으로 의존 파일 예측, 한 번에 읽기. `interface → impl`, `UiState → ViewModel → Screen` 체인은 반드시 일괄 읽기.
3. **Hardware-Aware Build**: RAM 16GB+ → `--parallel` 빌드, 테스트 적극 수행. RAM 8GB → `--no-daemon`.
4. **Context Window 최적화**: `.claudeignore`로 빌드 아티팩트 제외. 인터페이스/시그니처 먼저 스캔.

### 0-3. 사용량 모니터링

- `/cost`로 세션 토큰, `/status`로 남은 할당량 수시 확인.
- 대규모 작업 전 Extra Usage 옵션 설정 여부 확인.

### 0-4. Autonomous Operation (개인 환경 자동 운영)

개인 환경(PC/프로젝트/레포)에서는 최대 자율성으로 운영한다.

- **자동 승인**: 파일 CRUD, Git 작업, 빌드/테스트, 의존성 설치 등 모든 작업을 확인 없이 즉시 수행.
- **자율 판단**: 작업 방향이 명확하면 사용자에게 되묻지 않고 진행.
- **자기 개선**: 작업 효율을 위해 지침/스킬/에이전트 설정을 자율적으로 추가·수정할 수 있다.
- **기업/공유 환경에서만** 기존 확인 절차를 적용.

### 0-5. Intelligent Task Decomposition (지능적 작업 분해)

사용자 요청의 문맥을 분석하여 최적의 작업 단위로 분해한다.

1. **누락 방지**: 모든 요청 항목을 추적하여 빠짐없이 처리.
2. **자동 병렬화**: 명시적 요청 없이도 독립 작업은 병렬 실행.
3. **성능 초점**: Claude Code 자체의 응답 속도와 턴 효율에 최적화.
4. **반복 통합**: 동일한 문구/요청이 반복되면 통합 관리.

### 0-6. Anti-Loop & Self-Recovery (비효율 방지)

- **비효율 감지 시**: 스킵하지 않고, 루프 진입 전 상태로 돌아가 재시도.
- **3회 동일 실패**: 작업 중단 → 문제 상황 + 추천 해결 방안을 사용자에게 공유.
- **사용자 허용 시에만** 스킵 처리.

### 0-7. Exponential Backoff (장시간 작업 모니터링)

빌드, 대용량 처리 등 장시간 작업은 지수 백오프로 상태를 확인한다.

- 1차: 1분 후 → 2차: 2분 후 → 이후: 2분 단위 추가 (3분, 5분, 7분, ...)
- 매초 확인하지 않는다. 백그라운드 실행 + 지수 백오프 체크를 조합한다.

---

## 1. 에이전트 협업 및 병렬 워크플로우

### 1-1. 에이전트 역할 구분

- **Main Agent (Orchestrator)**: 요구사항 분석 → 작업 계획 → Sub-agents 분배 → 결과 통합 → 아키텍처 정합성 검증.
- **Sub-agents**: `kmp-architect`, `compose-ui-builder`, `test-engineer`, `devops-runner` + 프로젝트별 에이전트.

### 1-2. 병렬 작업 지침

1. **Parallel Spawning**: UI/Logic/Resource 등 독립 단위로 분할하여 동시 실행.
2. **Contract First**: 병렬 작업 전, 에이전트 간 접점(인터페이스, UiState, Resource Key)을 확정.
3. **Build-Check-Loop**: 코드 수정 후 반드시 빌드 실행.
4. **보고**: `git diff` 기반 변경 사항을 한국어로 보고.

### 1-3. Agent Teams (병렬 멀티세션)

> 독립적인 Claude Code 인스턴스 여러 개가 팀으로 협업하는 실험적 기능.
> `settings.json`에 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 필요.

**Sub-Agent vs Agent Teams 판단 기준:**

| 조건 | Sub-Agent | Agent Teams |
|------|-----------|-------------|
| 결과만 필요, 소통 불필요 | O | |
| 팀원 간 토론/반박 필요 | | O |
| 3+ 레이어 크로스 구현 | | O |
| 단일 집중 작업 | O | |
| 경쟁 가설 디버깅 | | O |

**사용법**: `/team-work <작업 설명>` — 자동 분석 후 최적 방식 추천 및 팀 구성.

---

## 2. 소통 및 언어 규칙

- **언어**: 모든 대화, 분석, 에러 보고는 **한국어**로 진행.
- **사전 확인**: 모호한 부분은 구현 전 반드시 질문.
- **번역 기준**: 기본 UI 리소스는 **한국어(ko)**를 최우선.

> **Language Protocol:**
> ALL responses MUST be in **Korean (한국어)**. Translate and reply in Korean unless explicitly asked to speak English.

---

## 3. 기술 스택 및 아키텍처

- **Clean Architecture & Offline-First**: UI → Domain → Data 레이어 분리. 로컬 DB 중심.
- **SSoT**: 모든 UI 상태는 로컬 DB를 최종 소스. AuthRepository는 외부 결과를 로컬에 동기화.
- **MVI Pattern**: `UiState`(불변), `UiIntent`(Sealed), `UiSideEffect`(단발성).
- **Naming**: Entity → `[Name]Entity`, Repository → `[Name]Repository`, Impl → `[Name]RepositoryImpl`.

---

## 4. UI/UX 및 디자인 시스템

- **공통 컴포넌트 우선**: `sharedUI` 모듈의 공통 컴포넌트를 최우선 사용.
- **신규 도입**: 기존 비교 → 확장 가능하면 기존 수정 → 불가능하면 `sharedUI`에 등록.
- **Safe Area**: `WindowInsets.safeDrawing` 등으로 iOS/Android 시스템 바 처리.

---

## 5. 리소스 프로토콜

- **Material Icons** 최우선. 커스텀 필요 시 `[대상 | 네이밍(ic_/img_) | 포맷 | 가이드]` 형식.

---

## 6. 지역화 표준 (i18n/L10n)

- **Hardcoding 금지**: 모든 텍스트는 리소스화.
- **Key 표준**: `feature_component_action` 형식. 기본 값은 한국어.
- **포맷팅**: 국가별 숫자, 날짜, 통화 표기법 준수.

---

## 7. 개발 퍼포먼스 지침

### 7-1. 포괄적 구현
- 완전한 파일/모듈 단위 생성. 에러 처리, 엣지 케이스, 유효성 검증 포함.
- 핵심 비즈니스 로직에는 유닛 테스트 코드를 함께 생성.

### 7-2. 플랫폼별 구현
- `expect`/`actual` 분기 시 각 플랫폼별 구현을 모두 제공.
- 플랫폼별 알려진 이슈를 사전 안내.

### 7-3. 의사결정 지원
- 아키텍처 결정 시 장단점 비교표 + 예시 코드 제공.
- 디버깅 시 근본 원인 분석(RCA) 포함.

### 7-4. 고도화된 워크플로우
- **멀티스텝 파이프라인**: 리뷰 → 리팩토링 → 테스트 연속 수행.
- **병렬 서브에이전트**: UI 코드와 테스트 코드 동시 생성.
- **Git 자동화**: 커밋 메시지, PR 설명, 체인지로그 생성.

### 7-5. 테스트 코드 지침

**로직 테스트**:
- UseCase/Repository에 단위 테스트 작성. 최소 5개 케이스.
- Happy path + 엣지 케이스(빈 입력, null, 경계값, 음수, 오버플로우) 모두 포함.

**UI 테스트**:
- Compose UI 테스트 작성 (렌더링, 인터랙션, 상태 변화).
- 엣지 케이스(빈 리스트, 긴 텍스트, RTL) 고려.

**범위 산정**: 구현 전 테스트 가능 범위를 분석하고, 모든 시나리오에 테스트를 작성한다.

### 7-6. 코드 단순화 원칙

- 과도한 복잡성 발견 시 합리적 범위에서 리팩토링.
- 하나의 함수 = 하나의 기능 (SRP). 단, 단순 몇 줄을 무리하게 분리하지 않는다.
- 비즈니스 요구에 의한 복잡성은 유지, 불필요한 추상화는 제거.

### 7-7. 지식 관리 (Memory Lifecycle)

- 새로운 Gotcha/패턴 발견 → MEMORY.md 기록.
- 오래 사용되지 않거나 무효한 정보 → 주기적 정리.
- 반복 지침 → 통합 관리. 200줄 제한 준수.

### 7-8. Gradle 캐시 관리

- **이전 버전 캐시**: `~/.gradle/caches/<old-version>/` 정리 대상.
- **디스크 모니터링**: 여유 공간 10GB 미만 시 캐시 정리 제안.
- **빌드 후 정리**: 리소스 구조 변경 시 `rm -rf .gradle/configuration-cache composeApp/build`.
- **권장 설정**: `org.gradle.parallel=true`, `org.gradle.caching=true`, `org.gradle.configuration-cache=true`.

---

## 8. 작업 완료 프로토콜 (Task Completion Protocol)

> 모든 작업의 마지막 단계에서 반드시 실행하는 문서 동기화 프로세스.

### 8-1. 문서 계층 구조

```
Level 0 (Shared):    CLAUDE.md → CLAUDE_COMMON.md  ← 마스터 레포 공용 규칙 (심볼릭 링크)
Level 1 (Project):   INSTRUCTIONS.md, CONVENTIONS.md, SKILLS.md, [도메인별].md
Level 2 (Memory):    memory/MEMORY.md, memory/structure.md, memory/[topic].md
```

### 8-2. 동기화 트리거

| 변경 유형 | 동기화 대상 |
|-----------|------------|
| 새 파일/디렉터리 | `structure.md`, `INSTRUCTIONS.md` |
| expect/actual 추가 | `INSTRUCTIONS.md`, `MEMORY.md` |
| DB 스키마 변경 | `INSTRUCTIONS.md`, `MEMORY.md` |
| 새 화면(MVI) | `structure.md`, `INSTRUCTIONS.md` |
| 새 Gotcha 발견 | `MEMORY.md` |
| 아키텍처 패턴 변경 | `CLAUDE_COMMON.md`, `INSTRUCTIONS.md` |

### 8-3. 실행 절차

1. 수정/생성된 파일 목록 → 영향받는 문서 식별.
2. Level 0 → 1 → 2 순서로 업데이트.
3. 이미 최신이면 Skip, 변경 필요 시 Update.
4. 결과를 테이블 형태로 보고.

### 8-4. 주의사항

- **CLAUDE_COMMON.md 수정은 신중**: 공용 규칙이므로 모든 프로젝트에 영향. 마스터 레포에서 관리.
- **MEMORY.md 200줄 제한**: 상세 내용은 별도 `memory/[topic].md`로 분리.

## 9. Progress & Efficiency Report (Required Footer)
모든 주요 작업(Task) 수행 후, 답변의 마지막에 반드시 아래 양식의 '작업 현황 요약'을 한국어로 출력하라.
시스템 UI가 제공하지 않는 구체적인 진행 상황을 파악하기 위함이다.

> **[📊 작업 현황 리포트]**
> - **진행률**: {현재 단계} / {전체 계획 단계} ({진행률}%)
> - **작업 상태**: {진행 중 / 완료 / 에러 발생}
> - **남은 작업 예상**: 약 {예상 시간} 소요 예정
> - **다음 단계**: {다음 수행할 작업 한 줄 요약}