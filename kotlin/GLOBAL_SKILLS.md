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
3. 추정 결과를 사용자에게 보고한다:
   ```
   예상 토큰 소모: ~50k tokens
   현재 세션 누적: ~30k tokens
   권장 모델 Tier: Tier 2 (Sonnet)
   ```
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

**예시 출력**:
```
현재 작업: i18n 리소스 키 추가 (Tier 3 수준)
현재 모델: Opus (Tier 1)
→ 토큰 절약을 위해 `/model haiku` 전환을 추천합니다.
  예상 절약: 약 70% (Opus 대비)
```

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
2. 다음 5개 파일을 동시에 생성한다:
   - `[Name]UiState.kt` - 불변 상태 데이터 클래스
   - `[Name]UiIntent.kt` - Sealed class 이벤트
   - `[Name]UiSideEffect.kt` - 단발성 이벤트
   - `[Name]ViewModel.kt` - StateFlow 기반 ViewModel
   - `[Name]Screen.kt` - Composable 화면
3. Koin DI 모듈(`ViewModelModule.kt`)에 자동 등록한다.
4. 네비게이션 그래프에 라우트를 추가한다.
