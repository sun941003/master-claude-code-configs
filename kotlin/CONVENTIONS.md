# Kotlin/KMP 공용 코딩 컨벤션 (CONVENTIONS.md)

> 아키텍처/비즈니스 규칙은 각 프로젝트의 `INSTRUCTIONS.md` 참조. 이 파일은 **코딩 스타일**에 집중.

---

## 1. 코드 스타일

- 기존 프로젝트의 인덴트/네이밍 규칙을 엄격히 따른다.
- `commonMain` 코드 작성을 최우선. 플랫폼별 코드는 `expect`/`actual`로 분리.
- Material3 전용 (`material3.*`). M2 사용 금지.
- 모든 공개 Composable은 `modifier: Modifier = Modifier`를 첫 번째 파라미터로.
- Stateless 원칙: 상태는 호이스팅. `@Preview` 지원을 위해 DI 독립 Composable 분리.

---

## 2. 새 화면 추가 체크리스트

1. MVI 5파일 동시 생성 (`UiState`, `UiIntent`, `UiSideEffect`, `ViewModel`, `Screen`).
2. DI: ViewModel 모듈에 `viewModelOf(::NameViewModel)`.
3. 네비게이션: 프로젝트 네비게이션 구조에 라우트 추가.
4. 문서: `INSTRUCTIONS.md` 화면 목록 업데이트.

---

## 3. ViewModel 패턴

```kotlin
class XxxViewModel(/* DI 주입 */) : ViewModel() {
    private val _uiState = MutableStateFlow(XxxUiState())
    val uiState: StateFlow<XxxUiState> = _uiState.asStateFlow()

    private val _sideEffect = Channel<XxxUiSideEffect>()
    val sideEffect: Flow<XxxUiSideEffect> = _sideEffect.receiveAsFlow()

    fun onIntent(intent: XxxUiIntent) { when (intent) { ... } }
}
```

- Screen: `collectAsStateWithLifecycle()`. 문자열 → `UiMessage` sealed class.

---

## 4. expect/actual 추가 가이드

1. `commonMain` → `expect` 선언.
2. `androidMain` → `actual` (Activity 필요 시: DI singleton + `initializeXxxContext` 패턴).
3. `iosMain` → `actual` (`object XxxBridge` 싱글톤 + 콜백 클로저, `@OptIn(ExperimentalForeignApi::class)`).
4. 양 플랫폼 빌드 검증 후 `INSTRUCTIONS.md` expect/actual 테이블 추가.

---

## 5. Room DB 마이그레이션

1. `Database.kt` version +1 → `autoMigrations` 추가.
2. 새 컬럼: 반드시 `@ColumnInfo(defaultValue = "...")` 지정.
3. `schemas/` 디렉터리에 새 스키마 JSON 자동 생성 확인.

---

## 6. 에러 디버깅 전략

| 에러 유형 | 접근 방법 |
|----------|----------|
| Compose 렌더링 | `@Preview` 확인, `Modifier` 체인 순서 점검 |
| DI 주입 실패 | 모듈 등록 순서, `get()` vs `inject()` 점검 |
| Room 마이그레이션 | AutoMigration 체인, `defaultValue` 누락 확인 |
| 리소스 빌드 실패 | `composeResources/` 경로 확인, Gradle 캐시 클리어 |
| Theme 충돌 | `ComponentActivity` 확인 (AppCompat 금지) |
| 플랫폼 크래시 | expect/actual 분기 확인, 네이티브 API 검증 |
