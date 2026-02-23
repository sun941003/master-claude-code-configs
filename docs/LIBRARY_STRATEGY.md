# MoonDeveloper — Library Strategy

> 모듈 추출, 오픈소스, 다국어, 앱 템플릿 전략.
> 목표: "한 번 만든 건 다시 안 만든다"

---

## 모듈화 원칙

### 왜 모듈화하는가

Splitly 개발에 10+ Phase가 걸렸다. BetOnMe에서 IAP, Auth, Premium, AdMob, 다국어를 또 처음부터 만들면 같은 시간이 든다. 공통 기능을 독립 모듈로 추출하면 신규 앱 MVP를 6-10주 내에 완성할 수 있다.

### 추출 기준

```
추출한다:
  ∙ 2개+ 앱에서 동일하게 사용하는 기능
  ∙ 비즈니스 로직이 없는 인프라 코드
  ∙ 플랫폼별 expect/actual이 안정화된 코드

추출하지 않는다:
  ∙ 앱 고유 비즈니스 로직 (정산 계산, 습관 내기 등)
  ∙ 아직 1개 앱에서만 사용하는 기능
  ∙ 빈번하게 변경되는 불안정한 인터페이스
```

---

## 추출 대상 모듈 (Phase별)

### Phase 1: BetOnMe 착수 시 추출 (Splitly에서)

| 모듈 | 내용 | Splitly 소스 | 재사용 절감 |
|------|------|-------------|-----------|
| **moon-iap** | Google/Apple 인앱 결제 래퍼 | `data/billing/` | 2-3주 → 2일 |
| **moon-auth** | Firebase Auth + Google/Apple 로그인 | `data/auth/` | 1-2주 → 1일 |
| **moon-premium** | 프리미엄 상태 관리 + Paywall 로직 | `domain/premium/` | 1-2주 → 1일 |
| **moon-admob** | AdMob 배너/전면/보상형 래퍼 | `data/ads/` | 1주 → 0.5일 |

### Phase 2: 3번째 앱(NoSpend) 시 추출

| 모듈 | 내용 |
|------|------|
| **moon-i18n** | 하이브리드 다국어 (번들+온디맨드+Room) |
| **moon-analytics** | Firebase Analytics 이벤트 래퍼 |
| **moon-ui** | 공통 Compose 컴포넌트 (버튼, 카드, Empty State) |
| **moon-config** | Firebase Remote Config 래퍼 |

### Phase 3: 안정화 후

| 모듈 | 내용 |
|------|------|
| **moon-crash** | Crashlytics 래퍼 + 커스텀 로깅 |
| **moon-network** | Ktor 기반 네트워크 + 오프라인 큐 |
| **moon-storage** | Firebase Storage 래퍼 |

---

## 모듈 구조 표준

### 디렉토리

```
moon-iap/
├── build.gradle.kts
├── src/
│   ├── commonMain/kotlin/com/moondeveloper/iap/
│   │   ├── IapManager.kt          # expect class
│   │   ├── IapProduct.kt          # data class
│   │   ├── IapResult.kt           # sealed class
│   │   └── PurchaseVerifier.kt    # interface
│   ├── androidMain/kotlin/.../
│   │   └── IapManager.android.kt  # actual (Google Billing)
│   └── iosMain/kotlin/.../
│       └── IapManager.ios.kt      # actual (StoreKit 2)
├── README.md
├── CHANGELOG.md
└── LICENSE (Apache 2.0)
```

### API 설계 원칙

```
1. 최소 인터페이스: 앱이 알아야 할 것만 노출
2. 콜백 없음: suspend 함수 + Flow 기반
3. DI 친화: Koin Module 제공, 앱에서 install만
4. 플랫폼 추상화: commonMain에서 모든 로직 호출 가능
5. 에러 처리: Result<T> 반환, 앱에서 처리 방식 결정
```

### 사용 예시

```kotlin
// 앱의 di/IapModule.kt
val iapModule = module {
    single { IapManager(get()) }  // moon-iap 제공
}

// 앱의 domain/usecase/PurchasePremiumUseCase.kt
class PurchasePremiumUseCase(private val iapManager: IapManager) {
    suspend operator fun invoke(productId: String): Result<IapResult> {
        return iapManager.purchase(productId)
    }
}
```

---

## 오픈소스 전략

### 원칙

```
공개한다:
  ∙ 인프라/유틸리티 모듈 (moon-iap, moon-auth 등)
  ∙ 단독으로 유용한 기능 단위
  ∙ 비즈니스 로직이 포함되지 않은 코드

공개하지 않는다:
  ∙ 앱별 비즈니스 로직
  ∙ 수익화 전략/가격 정책 코드
  ∙ 시크릿/인증 정보
```

### 라이센스

- Apache 2.0 (상업적 사용 허용, 특허 보호)
- README에 MoonDeveloper 크레딧 + 사용 앱 목록

### 릴리즈 전략

```
1. Splitly에서 검증 완료된 코드만 추출
2. 독립 레포로 분리 (moon-iap, moon-auth 등)
3. Maven Central / GitHub Packages 배포
4. 시맨틱 버저닝 (1.0.0 → 1.1.0 → 2.0.0)
5. CHANGELOG.md 필수 유지
6. CI: PR → 빌드 + 테스트 → 머지 시 자동 배포
```

### 기대 효과

```
∙ 개발자 브랜드 구축 (MoonDeveloper = CMP 모듈 제공자)
∙ 커뮤니티 피드백으로 품질 향상
∙ GitHub 스타/기여자 → 채용/인지도에 도움
∙ 스폰서십 가능성 (장기)
```

---

## 다국어 하이브리드 전략

### 구조

```
[앱 번들 포함 — 설치 시 즉시 사용]
├── en (영어 — 기본 폴백)
├── ko (한국어 — 개발자 모국어)
├── 디바이스 언어 (Android App Bundle이 자동 포함)
└── 공통 UI 키 ~200개 (버튼, 네비게이션, 에러 메시지)

[온디맨드 — 첫 실행 또는 언어 변경 시]
├── 해당 언어 전체 번역 파일 다운로드 (50-200KB)
├── Room DB에 키-값 저장
├── 버전 관리 → 변경분만 델타 업데이트
└── 이후 오프라인에서도 사용 가능
```

### 사용자 경험

```
1. 설치 → 즉시 사용 (추가 다운로드 프롬프트 없음)
2. 언어 변경 시 → "번역 다운로드 중..." (1-2초, 스피너)
3. 오프라인에서도 마지막 다운로드된 언어 사용 가능
4. 앱 업데이트 없이 번역 수정/추가 반영 가능
```

### 번역 키 체계

```
{app}.{feature}.{key}
  splitly.settlement.total_amount
  betOnMe.habit.streak_days

common.{category}.{key}
  common.button.save
  common.button.cancel
  common.error.network
  common.error.auth_failed
  common.nav.home
  common.nav.settings
```

- `common.*`: 앱 간 공유, 한 번만 번역
- `{app}.*`: 앱 전용, 별도 번역
- 뉘앙스 차이 → context 태그: `common.button.save[formal]`, `common.button.save[casual]`

### 번역 레포 구조

```
moondeveloper-i18n/
├── common/
│   ├── en.json
│   ├── ko.json
│   └── ... (78개+ 언어)
├── splitly/
│   ├── en.json
│   └── ...
├── betOnMe/
│   ├── en.json
│   └── ...
├── scripts/
│   ├── validate.py      # 누락 키, 포맷 불일치 체크
│   ├── translate.py      # AI 번역 배치
│   └── export.py         # 앱별 번들/서버 파일 생성
└── README.md
```

### 기술 구현

```
[서버/CDN 측]
∙ Firebase Remote Config 또는 자체 CDN (GitHub Pages도 가능)
∙ 언어별 JSON 파일 호스팅
∙ 버전 메타데이터 (마지막 업데이트 timestamp)

[앱 측]
∙ 앱 시작 → 로컬 DB 버전 vs 서버 버전 비교
∙ 변경 있으면 → 백그라운드 다운로드 + Room DB 저장
∙ UI에서 키 조회: LocalizedStringProvider.get("common.button.save")
∙ 폴백 체인: Room DB → 번들 리소스 → en 기본값

[moon-i18n 모듈 API]
class LocalizedStringProvider(
    private val roomDao: TranslationDao,
    private val bundleProvider: BundleStringProvider,
    private val remoteSync: RemoteTranslationSync
) {
    fun get(key: String): String
    fun getFormatted(key: String, vararg args: Any): String
    suspend fun syncIfNeeded()
    fun currentLanguage(): String
    fun setLanguage(code: String)
}
```

---

## 앱 템플릿 (Boilerplate)

### 목적

신규 앱 시작 시 0에서 시작하지 않고, 검증된 구조로 즉시 시작.

### 포함 내용

```
moon-app-template/
├── composeApp/
│   ├── src/commonMain/
│   │   ├── App.kt                  # 앱 진입점
│   │   ├── di/AppModule.kt         # Koin 기본 모듈
│   │   ├── presentation/
│   │   │   ├── navigation/NavGraph.kt
│   │   │   ├── theme/AppTheme.kt   # Material 3 테마
│   │   │   └── screens/HomeScreen.kt
│   │   ├── domain/                  # 빈 구조
│   │   └── data/                    # 빈 구조
│   ├── src/androidMain/
│   └── src/iosMain/
├── iosApp/                          # Xcode 프로젝트
├── web/                             # Next.js (선택)
├── build.gradle.kts                 # 모듈 의존성 사전 설정
├── gradle.properties                # 최적화 설정 포함
├── .github/workflows/ci.yml        # CI 파이프라인
├── lefthook.yml                     # Git Hooks
├── renovate.json                    # 의존성 자동 업데이트
├── Dangerfile.ts                    # PR 자동 리뷰
├── CLAUDE.md                        # Claude Code 지침
├── .claude/                         # agents/commands/skills (심링크)
├── PROGRESS.md                      # 진행 추적 (빈 템플릿)
├── SESSION_LOG.md                   # 세션 로그 (빈 템플릿)
└── docs/
    └── PROJECT_SPEC.md              # 프로젝트 스펙 (빈 템플릿)
```

### 사전 설정된 것

```
∙ moon-iap, moon-auth, moon-premium, moon-admob 의존성
∙ moon-i18n 하이브리드 다국어 기본 구조
∙ Firebase Auth + Firestore + Crashlytics + Analytics 초기화
∙ Koin DI 기본 구성
∙ Material 3 테마 (다크모드 포함)
∙ MVI ViewModel 기본 패턴
∙ CI/CD + lefthook + Danger + Renovate
∙ 테스트 인프라 (desktopTest 구조 + Fake 베이스)
```

### 사용법

```bash
# 1. 템플릿 클론
gh repo create moondeveloper/betOnMe --template moon-app-template

# 2. 프로젝트 설정
# package name, app name, Firebase 프로젝트 연결 등 수정

# 3. claude-init 실행
claude-init  # → CLAUDE.md + agents/commands/skills 심링크

# 4. 개발 시작
# PROGRESS.md에 Phase 1 작성 → CC로 구현 시작
```

---

## 실행 타임라인

```
[Phase B-1: BetOnMe 착수 시]
☐ moon-iap 추출 (Splitly billing/ → 독립 모듈)
☐ moon-auth 추출
☐ moon-premium 추출
☐ moon-admob 추출
☐ 앱 템플릿 v1 생성
☐ BetOnMe에서 검증

[Phase B-2: 안정화]
☐ moon-i18n 추출 (하이브리드 다국어)
☐ moondeveloper-i18n 번역 레포 구축
☐ 공통 UI 번역 키 정의 (~200개)
☐ Maven Central / GitHub Packages 배포 검토

[Phase C: 확장]
☐ moon-ui, moon-analytics, moon-config 추출
☐ 오픈소스 공개 (3개+)
☐ 앱 템플릿 v2 (전체 자동화 포함)
```

---

## 관련 문서

- [VISION.md](VISION.md) — 비전, 목표, 원칙
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) — 개발 표준, MVI, 테스트
- [TOOLCHAIN_STRATEGY.md](TOOLCHAIN_STRATEGY.md) — CI/CD, 도구, 인프라
- [APP_PORTFOLIO.md](APP_PORTFOLIO.md) — 앱별 전략, BetOnMe 계획

