# MoonDeveloper — Development Guide

> 모든 프로젝트에 적용하는 개발 표준.
> 프로젝트별 예외는 각 프로젝트의 CLAUDE.md 하단에 기록.

---

## 아키텍처

### Clean Architecture + MVI (권장) / MVVM (기존 호환)

```
presentation/   → Screen (Composable) + ViewModel + State + Intent
domain/         → UseCase + Repository(interface) + Entity
data/           → RepositoryImpl + DataSource + DTO
di/             → Koin Module 정의
```

**의존성 방향**: presentation → domain ← data. domain은 외부 의존성 없음.

### 디자인 패턴 전략

**MVI를 기본 패턴으로 채택한다.** 단방향 데이터 흐름 + 단일 State 객체가 Compose의 recomposition 모델과 가장 자연스럽게 맞고, 테스트 시 State 스냅샷 비교가 가능해 예측 가능한 테스트를 작성할 수 있다.

```
[MVI 흐름]
User Action → Intent → ViewModel.onIntent() → State 업데이트 → UI 리컴포지션
```

**적용 원칙**:
- 신규 프로젝트 (BetOnMe~): 처음부터 MVI 적용
- Splitly (기존): 기존 MVVM ViewModel은 유지, 신규 ViewModel만 MVI 패턴
- 전면 전환은 하지 않는다 (테스트 안정성 우선)

**MVI ViewModel 표준 구조**:

```kotlin
// State — 화면의 모든 상태를 단일 data class로
data class FeatureState(
    val items: List<Item> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

// Intent — 사용자 액션을 sealed class로
sealed class FeatureIntent {
    data class LoadItems(val filter: String) : FeatureIntent()
    data class DeleteItem(val id: String) : FeatureIntent()
    data object Refresh : FeatureIntent()
}

// ViewModel
class FeatureViewModel(
    private val getItemsUseCase: GetItemsUseCase
) : ViewModel() {
    private val _state = MutableStateFlow(FeatureState())
    val state: StateFlow<FeatureState> = _state.asStateFlow()

    fun onIntent(intent: FeatureIntent) {
        when (intent) {
            is LoadItems -> loadItems(intent.filter)
            is DeleteItem -> deleteItem(intent.id)
            is Refresh -> refresh()
        }
    }

    private fun loadItems(filter: String) {
        _state.update { it.copy(isLoading = true) }
        viewModelScope.launch {
            getItemsUseCase(filter)
                .onSuccess { items -> _state.update { it.copy(items = items, isLoading = false) } }
                .onFailure { e -> _state.update { it.copy(error = e.message, isLoading = false) } }
        }
    }
}

// Screen
@Composable
fun FeatureScreen(viewModel: FeatureViewModel) {
    val state by viewModel.state.collectAsState()
    // state.items, state.isLoading 등 사용
    Button(onClick = { viewModel.onIntent(FeatureIntent.Refresh) }) { ... }
}
```

**MVI 테스트 패턴** (기존 Fake 기반 유지):

```kotlin
@Test
fun `load items success`() = runTest {
    val vm = FeatureViewModel(FakeGetItemsUseCase(successItems))
    vm.onIntent(FeatureIntent.LoadItems("all"))
    advanceUntilIdle()
    assertEquals(successItems, vm.state.value.items)
    assertFalse(vm.state.value.isLoading)
}
```

### 패키지 구조

```
com.moondeveloper.{app}.{layer}.{feature}

예: com.moondeveloper.splitly.presentation.settlement
    com.moondeveloper.splitly.domain.usecase.ledger
    com.moondeveloper.betOnMe.data.repository.habit
```

### KMP expect/actual

- expect 선언 시 반드시 모든 플랫폼의 actual 함께 제공
- STUB 구현 시 TODO 주석 필수: `// TODO: Phase X에서 구현 예정 - [사유]`
- STUB 목록은 QA 체크리스트에서 별도 추적

---

## 기술 스택 표준

| 영역 | 라이브러리 | 버전 기준 |
|------|-----------|----------|
| UI | Compose Multiplatform + Material 3 | 최신 안정 |
| DI | Koin | 4.1.1+ |
| DB | Room KMP | v5+ |
| Auth | Firebase Auth (GitLive) | 최신 |
| 네트워크 | Ktor | 최신 안정 |
| 직렬화 | kotlinx.serialization | 최신 |
| 빌드 | Kotlin 2.3.0+, AGP 최신 안정 | — |
| 웹 | Next.js (Splitly 기준) 또는 VanillaJS | — |

**버전 업그레이드 원칙**: 마이너 버전은 Phase 시작 시 일괄 업그레이드. 메이저 버전은 별도 Phase로 계획.

---

## 테스트 전략

### 규칙 (반드시 준수)

1. **desktopTest만 사용** — allTests, androidTest, iosTest 금지
2. **컴파일 5분 + 실행 5분 타임아웃** — 초과 시 강제 중단
3. **Fake 구현 선행** — Repository/UseCase의 Fake를 먼저 만들고, 컴파일 확인 후 테스트 작성
4. **ViewModel당 에이전트 1개** — 팀 작업 시 ViewModel별로 분리
5. **작업 전 `gradle --stop`** — 기존 데몬의 메모리 점유 방지

### 3-failure rule

```
1~3차 시도: 코드 수정 후 재실행
3차까지 실패:
  → @Ignore + TODO("사유 + 재현조건") 주석
  → DEFERRED_TESTS.md에 기록
  → 다음 Phase에서 일괄 해결
```

### 자동 테스트 3계층

```
Layer 1 (코드 변경 시): 관련 desktopTest 즉시 실행
Layer 2 (git push 시):  CI/CD → 전체 테스트 + 슬랙 알림
Layer 3 (릴리즈 전):    종합 검증 (보안/i18n/번들크기)
```

### 실행 명령어

```bash
# 특정 테스트
./gradlew :composeApp:desktopTest --tests "*HomeViewModelTest*"

# 전체 테스트 (5분 타임아웃)
timeout 300 ./gradlew :composeApp:desktopTest --no-daemon

# 웹 테스트
cd web && npm run test -- --reporter=verbose

# E2E (Maestro)
maestro test tests/maestro/

# 전체 한 번에
bash tests/scripts/run-all-tests.sh
```

---

## 코드 컨벤션

### 네이밍

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `SettlementViewModel` |
| 함수 | camelCase | `calculateSplit()` |
| 상수 | UPPER_SNAKE | `MAX_PARTICIPANTS` |
| 패키지 | 소문자 | `com.moondeveloper.splitly` |
| Composable | PascalCase | `SettlementScreen()` |
| 리소스 키 | snake_case | `btn_save`, `err_network` |

### Import 규칙

- 와일드카드 import 금지 (`import com.example.*`)
- 파일 제공 시 반드시 Import 포함 완전한 파일 단위로

### Git 규칙

- 브랜치: `feature/{phase}-{작업}`, `fix/{이슈}`, `test/{대상}`
- 커밋 메시지: `feat:`, `fix:`, `test:`, `docs:`, `refactor:`, `chore:`
- 작업 완료 시: `git add` → `commit` → `dev` 머지
- 이전 브랜치 미머지 시 먼저 머지 처리 후 새 작업 시작

---

## Phase 기반 개발 프로세스

### Phase 구조

```
Phase N: {테마}
├── N-1: 작업 1 (세션 1)
├── N-2: 작업 2 (세션 1-2)
├── ...
└── N-M: 작업 M (세션 X)
```

### 세션 관리

**시작 시**:
1. PROGRESS.md 확인 → 현재 상태 + 다음 작업 파악
2. 이전 SESSION_LOG.md 확인 → 마지막 작업 컨텍스트
3. 미머지 브랜치 확인 → 있으면 먼저 처리

**작업 중**:
- 주요 변경마다 SESSION_LOG.md 업데이트
- 기능 구현 후 관련 테스트 실행 (Layer 1)

**종료 시**:
1. SESSION_LOG.md 최종 업데이트
2. PROGRESS.md 해당 Phase/세션 상태 갱신
3. git add → commit → dev 머지
4. 다음 세션 시작 시 바로 이어갈 수 있는 "다음 작업" 명시

---

## 다국어 (i18n)

### 기본 원칙

- 모든 앱은 78개+ 언어 지원 (출시일부터)
- 하드코딩 문자열 금지 — 반드시 리소스 키 사용
- en, ko는 필수 기본 언어 (앱 번들 포함)
- 나머지 언어는 온디맨드 다운로드 (하이브리드 전략)

### 번역 키 구조

```
{app}.{feature}.{key}       → splitly.settlement.total_amount
common.{category}.{key}     → common.button.save, common.error.network
```

- `common.*` 키는 앱 간 공유 (moondeveloper-i18n 레포)
- 뉘앙스 차이가 있는 키는 context 태그 활용

### 검증

- 빌드 시 i18n 검증 스크립트 자동 실행
- 누락 키, 포맷 불일치, 인코딩 에러 체크

---

## UI/UX 프로세스

### 기본 원칙

- UI 코드는 디자인 없이 작성 금지 → 디자인 먼저 요청
- 글로벌 사용자 관점에서 문화적 고려사항 항시 체크
- 무료 사용자 경험을 해치지 않는 수익화 UX

### 기능 개발 시 자동 포함

새 기능 구현 요청 시 아래 항목을 함께 제공:
- 온보딩/첫 사용 플로우 제안
- 빈 상태(Empty State) 디자인
- 에러 메시지 UX 카피
- 접근성(a11y) 체크포인트
- CTA 문구 (다국어 고려)

### Phase별 UX 감사

- 사용자 여정 리뷰
- 이탈 포인트 분석
- 경쟁앱 벤치마킹
- 무료→프리미엄 전환 플로우 점검

---

## 요청/프롬프트 체크리스트

> Splitly 교훈: 불분명한 요청으로 인한 적용 누락 방지

### 기능 구현 요청 시 확인

```
☐ 어떤 화면에 추가되는가?
☐ 기존 기능과의 상호작용은?
☐ 에러 케이스 처리는?
☐ 다국어 키는 추가했는가?
☐ 테스트는 작성했는가?
☐ STUB인가, 완전 구현인가?
```

### 스토어/배포 작업 시 확인

```
☐ 에셋(스크린샷, 아이콘)이 실제 적용되었는가?
☐ 인코딩 에러 없는가? (다국어 설명문)
☐ 버전 코드/네임이 올바른가?
☐ 서명 설정이 올바른가?
☐ 모든 플랫폼(Android/iOS/Web)에 반영되었는가?
```

---

## 에러/피드백 관리

### KNOWN_ISSUES.md

알려진 이슈를 프로젝트별로 누적. 동일 에러 재발 시 이 문서 먼저 참조.

```
형식: 날짜 | 프로젝트 | 증상 | 원인 | 해결 | 재발방지
```

### LESSONS_LEARNED.md

개발 과정의 교훈 기록. 새 프로젝트 시작 시 참고.

```
형식: 날짜 | 카테고리 | 상황 | 교훈 | 적용
```

### 전파 규칙

- 프로젝트 A에서 해결한 이슈가 B에도 적용 가능 → KNOWN_ISSUES에 기록
- 공통 적용이 필요한 내용 → master-claude-code-configs에 반영
- 치명도 높음 → 자동 적용, 치명도 중간 → 제안 후 적용

---

## 관련 문서

- [VISION.md](VISION.md) — 비전, 목표, 원칙
- [TOOLCHAIN_STRATEGY.md](TOOLCHAIN_STRATEGY.md) — CI/CD, 도구, 인프라
- [LIBRARY_STRATEGY.md](LIBRARY_STRATEGY.md) — 모듈화, 오픈소스, 다국어

