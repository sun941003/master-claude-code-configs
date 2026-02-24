# Hardening Phase 전략

## 개요
Splitly 출시 전 전체 프로젝트 내실 점검.
기존 Phase C(Feature 모듈) + Phase D(OSS 공개) + 신규 고도화 통합.

## 9 Steps
1. 버전 업데이트 + 빌드 환경 정비
2. 모듈 아키텍처 + Feature 모듈 분리
3. Analytics/Tracking 시스템 구현
4. 빌드 경고 정리 + deprecated 제거
5. 알려진 이슈 + 안정성 수정
6. Splitly 전체 리팩토링
7. OSS 문서화 + 배포 준비
8. 전체 테스트 재구축
9. 크로스 프로젝트 싱크 + 최종 점검

## 핵심 결정사항
- Firebase Performance Monitoring: 활성화 확정
- BigQuery Export: 유저 1만+ 후 검토
- Maven Central: 최종 테스트 시 병렬 배포
- CI/CD 실행: 3/1 이후 (macOS 10x 과금 리셋 후)
- 3/1 전까지: 예외처리/에러가능구간 개선에 집중
