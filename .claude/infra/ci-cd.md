# CI/CD 설정
> 원본: docs/TOOLCHAIN_STRATEGY.md 참조

## 자동화 계층
- L1 (로컬): lefthook pre-push → desktopTest
- L2 (CI): GitHub Actions → 테스트, 빌드, 웹 배포
- L3 (릴리즈): Fastlane → 스토어 제출
- E2E: Maestro (⏸️ 실기기 이슈)

## 주의사항
- testRelease 금지 (R8 + Robolectric)
- contentDescription 사용 (testTag 대신)
- release_status: draft
- K/N OOM → -Xmx4g
- 로컬 빌드 = 스토어, CI = 검증
- macOS runner 10x 과금

## 도구
- Danger JS: PR 자동 리뷰 (테스트 누락, i18n, STUB 감지)
- Renovate: 의존성 자동 업데이트 (매주 주말)
- lefthook: pre-push desktopTest 자동 실행
