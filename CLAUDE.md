# CLAUDE.md — MoonDeveloper 공통 지침

> 이 파일은 master-claude-code-configs에서 자동 동기화됩니다.
> 수정은 master-claude-code-configs에서만 하세요.

## 아키텍처

- 신규 앱 (BetOnMe~): MVI (Model-View-Intent)
- Splitly: 기존 MVVM 유지, 신규 ViewModel만 MVI
- 패키지: `com.moondeveloper.{app}.{layer}.{feature}`
- Import 포함 완전한 파일 단위 코드 작성

## 기술 스택

| 영역 | 기술 |
|------|------|
| UI | Compose Multiplatform + Material 3 |
| DI | Koin 4.1.1 |
| DB | Room KMP v5 |
| Auth | Firebase Auth (GitLive) |
| Build | Kotlin 2.3.0, AGP 8.11.2 |
| CI | GitHub Actions + lefthook + Danger + Renovate |

## 테스트 규칙

- **desktopTest only** (allTests 절대 금지)
- 5분 컴파일 + 실행 타임아웃
- Fake 구현 우선, 1 agent = 1 ViewModel
- 3회 실패 → `@Ignore` + `TODO` + DEFERRED_TESTS.md 기록
- 작업 전: `gradle --stop` 필수

## 세션 관리

- 작업 시작: PROGRESS.md 확인
- 작업 중: 해당 섹션 실시간 갱신
- 작업 종료: "진행 현황 업데이트해줘"로 갱신
- 브랜치: dev 작업, main 머지는 사용자 확인 후

## 자동화 도구

- **lefthook**: pre-push desktopTest 자동 실행
- **Danger JS**: PR 리뷰 (테스트 누락, i18n, STUB 감지)
- **Renovate**: 의존성 자동 업데이트 (매주 주말)
- **Gradle Build Cache**: CI 빌드 30-50% 단축

## 커뮤니케이션

- 한국어 소통, 코드/변수명 영어
- 결론 → 코드 → 핵심 조언 순서
- 불필요한 서론/반복 금지
- 기술 용어 원어 사용

## 참고 문서

- 전략: `master-claude-code-configs/docs/` (8개)
- 프로젝트 스펙: 각 프로젝트 `docs/`
- 시크릿: `moondeveloper-secrets` (git-crypt)
