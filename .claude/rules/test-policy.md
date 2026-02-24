# 테스트 정책
> 원본: docs/DEVELOPMENT_GUIDE.md 참조

## 빌드 & 실행
- `desktopTest`만 사용 (allTests 절대 금지 — 크로스플랫폼 빌드로 CPU 폭주)
- 컴파일 타임아웃: 5분
- 실행 타임아웃: 5분
- 작업 전 `gradle --stop` 필수

## 작성 순서
1. Fake 구현 먼저 작성
2. 컴파일 확인
3. 테스트 1개씩 실행 (`--tests "*.ClassName"`)
4. ViewModel당 에이전트 1개 분리

## 실패 처리 (3회 규칙)
동일 테스트 3회 실패 시:
1. `@Ignore` + TODO 주석 (사유 + 재현 조건)
2. `DEFERRED_TESTS.md`에 기록
3. 다음 작업으로 진행

> 완벽한 테스트가 목표지만 루프보다 진행이 우선

## Hardening Phase 테스트 규칙 (추가)
- 모듈별 테스트 독립 실행 보장 (다른 모듈 실패 전파 금지)
- 전체 desktopTest 30분 상한 — 초과 시 느린 테스트 식별
- Analytics 이벤트 테스트: DebugView 또는 FakeTracker 기반
- UI 테스트(Maestro): Flow YAML은 CC 작성, 실행은 실기기에서
