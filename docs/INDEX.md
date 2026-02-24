# MoonDeveloper — 문서 인덱스

> master-configs/docs/ 전체 문서 목록 및 역할 정의.
> **최종 업데이트**: 2026-02-24

---

## 문서 체계

```
VISION.md (최상위 — 모든 문서가 이 비전에 정렬)
├── DEVELOPMENT_GUIDE.md    — 어떻게 만드는가
├── TOOLCHAIN_STRATEGY.md   — 어떤 도구로 만드는가
├── LIBRARY_STRATEGY.md     — 무엇을 재사용하는가
├── APP_PORTFOLIO.md        — 무엇을 만드는가
├── MONETIZATION.md         — 어떻게 수익화하는가
├── SECRETS_REGISTRY.md     — 시크릿을 어떻게 관리하는가
├── INFRASTRUCTURE.md       — 인프라를 어떻게 구성하는가
└── moondeveloper_strategy_masterplan_v2_2.md  — 병렬 실행 계획 (별도)
```

---

## 문서 목록

| # | 문서 | 역할 | 참조 시점 |
|---|------|------|----------|
| 1 | **[VISION.md](VISION.md)** | 미션, 핵심 원칙, 목표, 성공 지표, 포트폴리오 현황 | 방향 판단 시 |
| 2 | **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** | 아키텍처(MVI/MVVM), 테스트 전략, 코드 컨벤션, Phase 프로세스, i18n, UI/UX | 코드 작성 시 |
| 3 | **[TOOLCHAIN_STRATEGY.md](TOOLCHAIN_STRATEGY.md)** | CI/CD, Fastlane, 슬랙, 하드웨어, Claude↔CC 동기화, 자동화 확장 | 인프라 작업 시 |
| 4 | **[LIBRARY_STRATEGY.md](LIBRARY_STRATEGY.md)** | 모듈 추출 계획(moon-*), 오픈소스, 다국어 하이브리드, 앱 템플릿 | 신규 앱 착수 시 |
| 5 | **[APP_PORTFOLIO.md](APP_PORTFOLIO.md)** | 앱별 현황/전략, BetOnMe 기획, Go/No-Go 체크리스트, 크로스프로모션 | 앱 기획 시 |
| 6 | **[MONETIZATION.md](MONETIZATION.md)** | 3층 수익 구조, 가격 프레임워크, Paywall UX, 수익 예측, ASO | 수익화 설계 시 |
| 7 | **[SECRETS_REGISTRY.md](SECRETS_REGISTRY.md)** | git-crypt 설정, 시크릿 레포 구조, 관리 대상 목록, CI/CD 연동 | 키/인증서 작업 시 |
| 8 | **[INFRASTRUCTURE.md](INFRASTRUCTURE.md)** | 인프라 구성 상세 | 환경 설정 시 |

### 별도 문서

| 문서 | 역할 | 비고 |
|------|------|------|
| **moondeveloper_strategy_masterplan_v2_2.md** | Splitly 배포 홀딩 → 병렬 개발 전략, Phase 12 상세, 사업자등록 체크리스트 | v2.2 (2026-02-23) |

---

## 문서 갱신 규칙

| 트리거 | 갱신 대상 |
|--------|----------|
| Phase 전환 | VISION (포트폴리오), APP_PORTFOLIO (현황) |
| 신규 앱 착수 | APP_PORTFOLIO, LIBRARY_STRATEGY |
| 인프라 변경 | TOOLCHAIN_STRATEGY, INFRASTRUCTURE |
| 시크릿 추가/갱신 | SECRETS_REGISTRY |
| 수익 모델 변경 | MONETIZATION |
| 개발 규칙 변경 | DEVELOPMENT_GUIDE |
| 전략 방향 전환 | masterplan 새 버전 작성 |

---

## 현재 상태 스냅샷 (2026-02-24)

- **Splitly**: P11 ⏸️ (사업자등록 대기) + P12 100% 완료. 테스트 922개.
- **ureen**: 홀딩 (Step 0-15 완료)
- **BetOnMe**: 기획 전 (Splitly 출시 후 착수)
- **자동 테스팅**: L1-L2 완료, Maestro E2E ⏸️ (실기기 연결 이슈)
- **문서 싱크**: 커밋 521f5d6 (2026-02-24)
