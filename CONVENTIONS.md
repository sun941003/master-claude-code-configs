# 프로젝트 코딩 컨벤션 및 아키텍처 가이드라인 (CONVENTIONS.md)

이 문서는 프로젝트의 일관된 코드 품질 유지와 효율적인 협업을 위한 기술 지침을 정의합니다. 모든 개발 및 에이전트 작업은 본 가이드라인을 최우선으로 준수해야 합니다.

---

## 1. 디렉토리 구조 및 아키텍처

본 프로젝트는 **Clean Architecture**와 **Offline-First 전략**을 기본 지침으로 채택합니다.

### 1-1. 데이터 레이어 (Data Layer)
- **Room Entity**: `composeApp/src/commonMain/kotlin/data/local/entity`
    - 모든 로컬 DB 테이블 정의는 해당 패키지에 위치하며 `~Entity` 접미사를 사용합니다.
- **Repository 구현체**: `composeApp/src/commonMain/kotlin/data/repository`
    - 도메인 레이어의 인터페이스를 구현하며, 데이터 소스(Local, Remote) 간의 조율을 담당합니다.

### 1-2. UI 레이어 (UI Layer)
- **공통 컴포넌트**: `sharedUI/src/commonMain/kotlin/components`
    - 모든 화면에서 재사용되는 UI 요소들은 `sharedUI` 모듈에서 관리합니다.

### 1-3. 아키텍처 패턴
- **Clean Architecture**: UI -> Domain(UseCase) -> Data 레이어 간의 의존성 단방향 흐름을 유지합니다.
- **Offline-First**: 앱은 항상 로컬 DB를 최우선 데이터 소스로 사용하며, 네트워크 데이터는 로컬 DB를 갱신하는 용도로만 활용합니다.

---

## 2. UI/디자인 시스템 원칙

모든 화면 구현 시 `sharedUI`에 정의된 공통 컴포넌트를 우선적으로 사용해야 합니다.

### 2-1. 주요 공통 컴포넌트 목록 및 사용 규칙
- **SplitlyTopBar**
    - 중앙 정렬 타이틀을 기본으로 합니다.
    - 플랫폼별(iOS/Android) 뒤로가기 아이콘 처리가 필수적으로 포함되어야 합니다.
- **SplitlyButton**
    - Primary Color(`#2b7cee`)를 사용합니다.
    - 클릭 시 로딩 상태(Loading State)에 대한 시각적 대응이 포함되어야 합니다.
- **SplitlyTextField**
    - Material3 기반으로 커스텀 스타일링된 텍스트 필드를 사용합니다.

### 2-2. 신규 디자인 요소 도입 프로세스
새로운 UI 요소가 필요한 경우, 즉시 새로 구현하지 않고 다음 과정을 거칩니다:
1. 기존 `sharedUI` 컴포넌트 중 유사한 기능이 있는지 비교 분석합니다.
2. 기능 확장이 가능한 경우 기존 컴포넌트를 수정합니다.
3. 완전히 새로운 요소인 경우, 해당 화면에 직접 구현하기 전 **'공통 컴포넌트화'** 과정을 거쳐 `sharedUI`에 먼저 등록합니다.

---

## 3. 데이터 및 인증(Auth) 규칙

### 3-1. Single Source of Truth (SSoT) 원칙
- UI 레이어는 항상 로컬 DB(Room)의 데이터를 관찰(Observe)하여 화면을 갱신합니다.
- 서버 API 호출 결과는 직접 UI로 전달되지 않으며, 반드시 로컬 DB를 거쳐야 합니다.

### 3-2. 인증(Auth) 흐름
- `AuthRepository`는 Firebase 등의 외부 인증 결과를 로컬 DB에 동기화하는 역할을 수행합니다.
- 사용자 인증 상태 또한 로컬 DB 또는 암호화된 로컬 저장소를 SSoT로 간주합니다.

### 3-3. 명명 규칙 (Naming Convention)
- **Room Entity**: `[Name]Entity` (예: `UserEntity`, `TransactionEntity`)
- **Repository 인터페이스**: `[Name]Repository` (예: `UserRepository`)
- **Repository 구현체**: 
    - Firebase 연동 시: `Firebase[Name]Repository`
    - Room 연동 시: `Room[Name]Repository`
    - 일반 구현체: `[Name]RepositoryImpl`

---

## 4. 코드 스타일 지침
- 모든 코드는 기존 프로젝트의 인덴트 및 네이밍 규칙을 엄격히 따릅니다.
- KMP 프로젝트의 특성을 고려하여 플랫폼 공통 코드(`commonMain`) 작성을 최우선으로 합니다.
