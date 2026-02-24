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
