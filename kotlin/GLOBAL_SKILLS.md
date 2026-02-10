# Global Skills (범용 스킬 정의)

> 모든 Kotlin/KMP 프로젝트에서 사용 가능한 공통 스킬.
> 프로젝트별 특화 스킬은 각 프로젝트의 `SKILLS.md`에서 정의한다.

---

## 1. batchRefactor

**목적**: 여러 파일의 패키지 이동/변경/이름 변경을 스크립트로 한 번에 처리한다.

**트리거 조건**: 패키지 구조 변경, 클래스 리네이밍, 대규모 import 경로 수정이 필요할 때.

**실행 절차**:
1. 변경 대상 파일 목록을 Glob/Grep으로 수집한다.
2. 변경 계획(Before → After)을 사용자에게 표 형태로 제시한다.
3. 승인 후, 모든 파일을 **병렬로 동시 수정**한다 (Batch Processing Protocol 적용).
4. `./gradlew :composeApp:assembleDebug`로 빌드 검증한다.
5. `git diff --stat`으로 변경 요약을 보고한다.

**주의사항**:
- 수정 전 반드시 `git status`로 clean 상태를 확인한다.
- import 구문 변경 시 IDE 자동 정리와 충돌하지 않도록 전체 파일의 import를 일괄 처리한다.

---

## 2. checkHardware

**목적**: 현재 시스템의 하드웨어 리소스를 확인하여 빌드/테스트 전략을 결정한다.

**트리거 조건**: 최초 세션 시작 시 또는 빌드 성능 이슈 발생 시.

**실행 절차**:
1. 시스템 정보 수집:
   - `sysctl -n hw.memsize` (macOS RAM)
   - `sysctl -n hw.ncpu` (CPU 코어 수)
   - `df -h .` (디스크 여유 공간)
2. 결과에 따른 전략 제시:
   - **RAM 16GB+**: Gradle daemon 활성화, `--parallel` 빌드, 로컬 테스트 적극 수행.
   - **RAM 8GB**: Gradle daemon 비활성화(`--no-daemon`), 빌드와 테스트를 분리 실행.
   - **RAM 4GB 이하**: 로컬 빌드 최소화, 코드 검증은 정적 분석 위주.
3. `.claude/hardware_specs.md`에 결과를 캐시하여 이후 세션에서 재사용한다.

---

## 3. checkRateLimit

**목적**: 현재 작업의 토큰 소모량을 예측하고, 주간 한도 초과 위험 시 경고한다.

**트리거 조건**: 대규모 작업 시작 전, 또는 사용자가 명시적으로 요청 시.

**실행 절차**:
1. 현재 세션의 토큰 사용량을 `/cost`로 확인한다.
2. 예정된 작업의 규모를 추정한다:
   - 파일 수정 수: 파일 당 약 2-5k 토큰
   - 빌드 검증: 약 1-2k 토큰
   - 서브에이전트 작업: 에이전트 당 약 5-15k 토큰
3. 추정 결과를 사용자에게 보고한다.
4. 한도 초과 위험이 있으면 작업 분할 또는 모델 다운그레이드를 제안한다.

---

## 4. switchMode

**목적**: 사용자에게 현재 작업에 적합한 모델 전환을 안내한다.

**트리거 조건**: Dynamic Model Tiering 규칙에 따라 모델 불일치가 감지될 때.

**실행 절차**:
1. 현재 작업의 복잡도를 판단한다 (Tier 1/2/3).
2. 현재 사용 중인 모델과 비교한다.
3. 불일치 시 전환 명령어를 안내한다:
   - Tier 1 (Max) 전환: `/model opus`
   - Tier 2 (Standard) 전환: `/model sonnet`
   - Tier 3 (Eco) 전환: `/model haiku`
4. 전환 이유와 예상 토큰 절약량을 함께 설명한다.

---

## 5. scanArchitecture

**목적**: 프로젝트의 아키텍처 정합성을 빠르게 검증한다.

**트리거 조건**: 신규 프로젝트 세션 시작 시, 또는 대규모 리팩토링 후.

**실행 절차**:
1. 레이어 의존성 검증: Data → Domain ← UI 단방향 흐름 확인.
2. 패키지 구조 검증: `domain/`, `data/`, `presentation/` 분리 확인.
3. 네이밍 규칙 검증: Entity, Repository, UseCase 접미사 준수 여부.
4. 미사용 파일 탐지: import되지 않는 클래스/인터페이스 식별.
5. 결과를 표 형태로 보고한다.

---

## 6. generateBoilerplate

**목적**: MVI 화면 구현에 필요한 보일러플레이트 코드를 한 번에 생성한다.

**트리거 조건**: 새로운 화면(Feature) 추가 요청 시.

**실행 절차**:
1. 사용자로부터 화면 이름(예: `Settings`)을 입력받는다.
2. 프로젝트의 `SKILLS.md`에 `addNewScreen` 스킬이 정의되어 있으면 해당 스킬의 템플릿을 따른다.
3. 기본 생성 파일 (5개):
   - `[Name]UiState.kt` - 불변 상태 데이터 클래스
   - `[Name]UiIntent.kt` - Sealed class 이벤트
   - `[Name]UiSideEffect.kt` - 단발성 이벤트
   - `[Name]ViewModel.kt` - StateFlow 기반 ViewModel
   - `[Name]Screen.kt` - Composable 화면
4. Koin DI 모듈에 ViewModel을 등록한다.
5. 네비게이션 그래프에 라우트를 추가한다.
6. 빌드 검증 후 결과를 보고한다.

> 프로젝트별 `addNewScreen` 스킬이 코드 템플릿까지 포함하므로, 해당 스킬이 존재하면 우선 참조한다.

---

## 7. addDataLayer

**목적**: 새로운 데이터 모델에 필요한 전체 Data Layer 체인을 한 번에 생성한다.

**트리거 조건**: 새로운 도메인 엔티티/데이터 모델이 필요할 때.

**실행 절차**:
1. 사용자로부터 모델 이름과 필드 정의를 입력받는다.
2. 다음 파일들을 **병렬로** 생성한다:

   ```
   생성 파일 체인:
   domain/model/[Name].kt              # Domain 모델 (data class, 불변)
   data/local/entity/[Name]Entity.kt   # Room Entity (@Entity, @PrimaryKey)
   data/local/dao/[Name]Dao.kt         # Room DAO (CRUD 쿼리)
   domain/repository/[Name]Repository.kt  # Repository 인터페이스
   data/repository/[Name]RepositoryImpl.kt  # Repository 구현체
   ```

3. `EntityMappers.kt`에 양방향 변환 함수를 추가한다:
   ```kotlin
   fun [Name]Entity.toDomain() = [Name](...)
   fun [Name].toEntity() = [Name]Entity(...)
   ```

4. `SplitlyDatabase.kt`에 Entity와 DAO를 등록한다.
5. DI 모듈에 등록한다:
   - `AppModule.kt`: DAO singleton 추가
   - `RepositoryModule.kt`: Repository 바인딩 추가
6. DB 버전을 +1하고 AutoMigration을 추가한다.
7. 빌드 검증 후 결과를 보고한다.

**주의사항**:
- 새 컬럼에는 반드시 `@ColumnInfo(defaultValue = "...")` 지정 (AutoMigration 필수).
- Entity의 Enum 필드는 `type.name` (저장), `Enum.valueOf(type)` (복원)으로 변환.
- JSON 복합 객체는 `Json.encodeToString()`/`Json.decodeFromString()` 사용.

---

## 8. addExpectActual

**목적**: 새로운 플랫폼별 구현(expect/actual)을 안전하게 추가한다.

**트리거 조건**: 플랫폼별 네이티브 API 접근이 필요한 기능 추가 시.

**실행 절차**:
1. 기능 요구사항을 분석하여 `expect` 시그니처를 설계한다.
2. 다음 파일들을 **동시에** 생성한다:

   ```
   commonMain/[path]/[Name].kt          # expect 선언
   androidMain/[path]/[Name].android.kt  # actual (Android)
   iosMain/[path]/[Name].ios.kt          # actual (iOS)
   ```

3. 각 플랫폼별 구현 시 주의사항:

   **Android**:
   - Activity 참조 필요 시: Koin singleton + `initializeXxxContext(activity)` 패턴
   - `registerForActivityResult()`: 반드시 `onCreate` 내에서 호출
   - `AppCompatDelegate` static 메서드는 `ComponentActivity`에서도 정상 동작

   **iOS**:
   - Swift 연동: `object XxxBridge` 싱글톤 + 콜백 클로저 패턴
   - `@OptIn(ExperimentalForeignApi::class)` opt-in 필요 시 명시
   - `NSDate`는 `timeIntervalSinceReferenceDate` 사용 (2001 기준)
   - `Clock.System` 대신 프로젝트의 `currentTimeMillis()` expect/actual 사용

4. DI 모듈(`ServiceModule.kt`)에 등록한다:
   ```kotlin
   single<[Name]> { create[Name]() }  // expect fun create[Name]() 활용
   ```
5. 양쪽 플랫폼 모두 빌드 검증한다.
6. `INSTRUCTIONS.md` §3 expect/actual 테이블에 추가한다.

---

## 9. syncI18nResources

**목적**: 다국어 리소스 파일을 마스터 파일 기준으로 전체 동기화한다.

**트리거 조건**: 새 문자열 키 추가, 기존 키 수정/삭제, 대규모 기능 추가 시.

**실행 절차**:
1. 변경 유형을 판별한다 (추가/수정/삭제).
2. 마스터 파일(한국어 `values-ko/strings.xml`)의 변경 사항을 확인한다.
3. 프로젝트의 `LOCALIZATION.md`에 정의된 워크플로우를 따른다.
4. **병렬 처리 전략**:
   - 10개 미만 키: 직접 전체 파일 순회하며 수정
   - 10개 이상 키: 서브에이전트를 활용한 배치 처리 (언어 그룹별 분할)
5. 호환성 에일리어스 동기화 (원본 → 별칭 복사):
   ```
   zh → zh-rCN, he → iw, fil → tl, id → in, no → nb
   ```
6. 검증:
   - 키 개수 일치 확인 (Master vs 모든 로케일)
   - 플레이스홀더(`%1$s` 등) 무결성 확인
   - 빌드 검증

**주의사항**:
- 플레이스홀더 순서/포맷은 절대 변경하지 않는다 (런타임 크래시 위험).
- 브랜드명(`Splitly`, `Google` 등)은 번역하지 않는다.
- XML 특수문자(`&`, `<`, `>`, `'`, `"`)는 반드시 이스케이프한다.
- `SupportedLanguages.kt`에 등록해야 앱 내 언어 선택 UI에 노출된다.

---

## 10. updateDependencies

**목적**: `libs.versions.toml` 기반으로 의존성을 안전하게 업데이트한다.

**트리거 조건**: 의존성 업데이트 요청, 보안 취약점 발견, 새 라이브러리 추가 시.

**실행 절차**:
1. `gradle/libs.versions.toml`의 현재 버전을 확인한다.
2. 업데이트 대상의 최신 안정 버전을 조사한다.
3. **호환성 매트릭스 검증**:

   | 업데이트 대상 | 반드시 함께 확인 |
   |-------------|---------------|
   | Kotlin | KSP 버전, Compose 컴파일러 호환성 |
   | Compose Multiplatform | Material3 버전, Kotlin 호환성 |
   | Room | SQLite 버전, KSP 버전 |
   | Firebase GitLive | Android BOM 버전과의 네이티브 호환성 |
   | Koin | Compose 통합 API 변경 여부 |
   | AGP | compileSdk/targetSdk, ProGuard 호환성 |

4. `libs.versions.toml` 수정 후 빌드 검증한다.
5. 필요 시 ProGuard 규칙을 업데이트한다.
6. `INSTRUCTIONS.md` 버전 테이블을 업데이트한다.

**주의사항**:
- Alpha/Beta 버전은 사용자 승인 후에만 적용한다.
- 메이저 버전 업데이트 시 Breaking Changes를 사전 분석한다.
- 한 번에 하나의 라이브러리만 업데이트하여 문제 발생 시 원인을 특정할 수 있도록 한다.

---

## 11. debugCrash

**목적**: 크래시/에러를 체계적으로 분석하고 근본 원인을 찾는다.

**트리거 조건**: 앱 크래시, 런타임 에러, 예상치 못한 동작 보고 시.

**실행 절차**:
1. **에러 유형 분류**:

   | 유형 | 접근 방법 |
   |------|----------|
   | Compose 렌더링 | Recomposition 추적, Modifier 순서 점검 |
   | Koin 주입 실패 | 모듈 등록 순서, `get()` vs `inject()` 사용처 점검 |
   | Room 마이그레이션 | AutoMigration 체인, `defaultValue` 누락 확인 |
   | 리소스 빌드 실패 | composeResources 경로, Gradle 캐시 클리어 |
   | Theme 충돌 | Activity 부모 클래스 (ComponentActivity 필수) |
   | 플랫폼 크래시 | expect/actual 분기 확인, 네이티브 API 호출 검증 |

2. **Root Cause Analysis (RCA)**:
   - 스택 트레이스에서 프로젝트 코드 라인을 추출한다.
   - 관련 파일 체인(Screen → ViewModel → UseCase → Repository)을 역추적한다.
   - 최근 변경 사항(`git log --oneline -10`)과 대조한다.

3. 수정 사항을 구현하고 동일 시나리오에서 재현 불가를 검증한다.
4. 새로운 Gotcha가 발견되면 `MEMORY.md`에 기록한다.

---

## 12. comprehensiveTest

**목적**: 로직 테스트와 UI 테스트를 포괄적으로 작성한다.

**트리거 조건**: 새 기능 구현 완료 시, 테스트 작성 요청 시, 버그 수정 후 회귀 방지 시.

**실행 절차**:
1. **테스트 범위 산정**: 대상 코드의 공개 API, 분기 로직, 엣지 케이스를 분석한다.
2. **로직 테스트 작성**:
   - UseCase/Repository/ViewModel 단위 테스트.
   - 최소 5개 케이스: Happy path, 빈 입력, null/경계값, 음수/오버플로우, 에러 상황.
   - Mock 의존성은 Koin Test 또는 수동 Mock 사용.
3. **UI 테스트 작성** (요청 시):
   - Compose UI 테스트: 렌더링, 사용자 인터랙션, 상태 변화 검증.
   - 엣지 케이스: 빈 리스트, 긴 텍스트, RTL 레이아웃, 로딩/에러 상태.
4. **테스트 실행**: `./gradlew :composeApp:jvmTest` 또는 플랫폼별 테스트.
5. 실패 케이스가 있으면 원인 분석 후 수정.

**주의사항**:
- 테스트 파일은 `src/commonTest/` 또는 `src/jvmTest/`에 위치.
- Domain 레이어 테스트는 플랫폼 독립적이어야 한다.
- 테스트 네이밍: `should_[expected]_when_[condition]` 패턴.

---

## 13. gradleCacheCleanup

**목적**: Gradle 캐시와 빌드 아티팩트를 정리하여 디스크 공간을 확보한다.

**트리거 조건**: 디스크 여유 공간 10GB 미만, 빌드 오류 시 캐시 문제 의심, 사용자 요청 시.

**실행 절차**:
1. **디스크 상태 확인**:
   ```bash
   df -h /
   du -sh ~/.gradle/caches/ ~/.gradle/wrapper/ composeApp/build/
   ```
2. **이전 Gradle 버전 캐시 식별**:
   ```bash
   ls -d ~/.gradle/caches/*/  # 현재 사용 버전 이외의 디렉터리 식별
   ```
3. **안전한 정리 실행**:
   - 이전 버전 캐시: `rm -rf ~/.gradle/caches/<old-version>/`
   - 프로젝트 빌드: `rm -rf composeApp/build/`
   - Configuration Cache: `rm -rf .gradle/configuration-cache`
4. **정리 후 빌드 검증**: `./gradlew :composeApp:assembleDebug --no-build-cache`
5. 정리 결과(회수된 공간)를 보고한다.

**주의사항**:
- `~/.gradle/caches/modules-2/`는 의존성 아티팩트 → 삭제 시 재다운로드 필요.
- `~/.gradle/wrapper/`는 Gradle 배포판 → 현재 버전만 유지 가능.
- 정리 후 첫 빌드는 캐시 재생성으로 느릴 수 있다.
