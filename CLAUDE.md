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

## 세션 시작 프로토콜

모든 CC 세션은 아래 순서로 시작한다:

### 1. 환경 확인
- `gradle --stop` 실행 (좀비 데몬 제거)
- `git branch` → 현재 브랜치 확인
- 미머지 브랜치 있으면 먼저 머지 처리

### 2. 현재 상태 파악
- PROGRESS.md 읽기 (소스 오브 트루스)
- 현재 Phase/세션 확인
- 미해결 이슈 확인

### 3. 작업 범위 확인
- 프롬프트에 명시된 작업 범위만 수행
- 범위 외 이슈 발견 시: 원래 의도 파악 후 수정 (무시 금지)
- 수정이 작업 범위를 크게 벗어나면 TODO 주석 + 세션 요약에 기록

## 세션 종료 프로토콜

모든 CC 세션은 반드시 아래 순서로 끝낸다. 예외 없음.

### 1. 코드 정리
- 디버그 코드 (println, Log.d) 제거 확인
- 불필요한 import 정리

### 2. Git 커밋
- `git add -A`
- 의미 있는 커밋 메시지 (conventional commits: feat/fix/perf/test/docs)
- `git checkout dev && git merge {branch} --no-ff`
- `git push origin dev`

### 3. PROGRESS.md 업데이트
- 완료된 작업 상태 ✅로 변경
- 신규 이슈 발견 시 미해결 이슈 섹션에 추가
- 다음 작업 명시

### 4. 세션 요약 출력 (필수)

아래 형식으로 반드시 출력한다. 사용자가 이 요약을 Claude 웹에 붙여넣어 싱크한다.

```
=== CC 세션 완료 ===
프로젝트: {Splitly/ureen/BetOnMe}
브랜치: {branch} → dev 머지 완료
커밋: {hash} "{message}"

## 완료된 작업
- {작업 1}
- {작업 2}

## 발견된 이슈 (작업 범위 외)
- {이슈 1}: {사유} → TODO 추가 / 다음 세션

## PROGRESS.md 변경사항
- {변경 내용}

## 다음 작업
- {구체적인 다음 작업}

## Memory 갱신 필요 항목 (Claude 웹에서 업데이트)
- [A1-Splitly] {변경 내용} (변경 있는 경우만)
```

## 테스트 규칙 (KMP)

### 빌드 & 실행
- `desktopTest`만 사용 (allTests 절대 금지 — 크로스플랫폼 빌드로 CPU 폭주)
- 컴파일 타임아웃: 5분
- 실행 타임아웃: 5분
- 작업 전 `gradle --stop` 필수

### 작성 순서
1. Fake 구현 먼저 작성
2. 컴파일 확인
3. 테스트 1개씩 실행 (`--tests "*.ClassName"`)
4. ViewModel당 에이전트 1개 분리

### 실패 처리 (3회 규칙)
- 동일 테스트 3회 실패 시:
  1. `@Ignore` + TODO 주석 (사유 + 재현 조건)
  2. `DEFERRED_TESTS.md`에 기록
  3. 다음 작업으로 진행
- 완벽한 테스트가 목표지만 루프보다 진행이 우선
