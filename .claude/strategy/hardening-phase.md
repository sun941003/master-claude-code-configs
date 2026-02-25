# Hardening Phase 전략

## 개요
Splitly 출시 전 전체 프로젝트 내실 점검.
기존 Phase C(Feature 모듈) + Phase D(OSS 공개) + 신규 고도화 통합.

## 상태: ✅ 완료 (2026-02-25)

## 9 Steps
1. ✅ 버전 업데이트 + 빌드 환경 정비 (CMP 1.10.0, AGP 8.11.2, Gradle 8.14.4)
2. ✅ 모듈 아키텍처 + Feature 모듈 분리 (+3 모듈: ocr, ledger, settlement)
3. ✅ Analytics/Tracking 시스템 구현 (82 포인트)
4. ✅ 빌드 경고 정리 + deprecated 제거 (소스 경고 0)
5. ✅ 알려진 이슈 + 안정성 수정 (DEBT 0건)
6. ✅ Splitly 전체 리팩토링 (디자인 토큰, 에러 패턴, 성능)
7. ✅ OSS 문서화 + 배포 준비 (README, KDoc 51파일, Dokka, Maven Central)
8. ✅ 전체 테스트 재구축
9. ✅ 크로스 프로젝트 싱크 + 최종 점검

## 최종 결과
- moon-kmp-libs: 7 OSS 모듈, 130 tests
- splitly: 9 KMP 모듈 + web, Analytics 82 포인트
- BLOCKER: 0건, DEBT: 0건
- 잔존: @Ignore 2건 (H8-03, 문서화), npm audit 19건 (Jest dev 의존성)

## 핵심 결정사항
- Firebase Performance Monitoring: 활성화 확정
- BigQuery Export: 유저 1만+ 후 검토
- Maven Central: publishToMavenLocal 검증 완료
- CI/CD 실행: 3/1 이후 (macOS 10x 과금 리셋 후)

## 다음 단계
1. 3/1: GitHub Actions CI/CD 풀 가동
2. Phase 11 재개: 사업자등록 완료 후 스토어 제출
3. 수동 QA: QA_CHECKLIST_v2 161항목
4. 비공개 테스트 + 정식 출시
