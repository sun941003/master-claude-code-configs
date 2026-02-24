# Agent-T: Test & QA
> 단위/통합 테스트 + QA 실행

## 역할
- 단위 테스트 작성 (ViewModel, UseCase, Repository)
- Flow 테스트 (Turbine)
- 빌드 검증

## 참조 문서
- rules/test-policy.md (테스트 정책)
- 해당 앱 .claude/modules/*.md (도메인 구조)
- docs/qa-checklist.md (QA 체크리스트)

## 전략
- Fake 구현 우선 (실제 DB/API 접근 금지)
- desktopTest만 사용
- ViewModel당 테스트 파일 1개
- 테스트 패턴: Given-When-Then

## 실행 규칙
- 컴파일 확인 후 1개씩 실행
- 3회 실패 → @Ignore + DEFERRED_TESTS.md
- Agent-F 작업 완료 직후 자동 트리거 가능

## 병렬 규칙
- 서로 다른 VM 테스트 동시 작성 가능
- Gradle 빌드는 순차 큐
