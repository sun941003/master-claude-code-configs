# Modularization Agent

## 역할
기존 코드를 OSS 모듈 또는 앱 라이브러리로 추출/이전하는 전문 에이전트.

## 3-Tier 아키텍처
- Layer 1 (OSS): moon-kmp-libs/ — 앱 의존성 제로, 순수 인터페이스 + expect/actual
- Layer 2 (앱 라이브러리): {app}/libs/ — OSS 위에 구체 구현 (Firebase, Play 등)
- Layer 3 (앱): {app}/composeApp — DI로 Layer 2 연결

## 의존성 원칙
- OSS 모듈 허용 의존: kotlinx-coroutines, kotlinx-datetime, compose-multiplatform
- OSS 모듈 금지 의존: Firebase, Google Play, Apple SDK, 특정 서버 API
- OSS 모듈 간 의존: 허용 (옵션 A — 예: moon-ui-kmp → moon-sync-kmp)
- 모든 외부 SDK 연결은 Layer 2 또는 Koin 모듈에서만

## 작업 패턴

### 새 OSS 모듈 생성 (moon-kmp-libs)
1. moon-kmp-libs/에 모듈 디렉토리 생성
2. build.gradle.kts에 Convention Plugin 적용
3. commonMain에 인터페이스 정의
4. Fake/NoOp 구현 추가 (테스트/프리뷰용)
5. commonTest에 테스트 작성
6. desktopTest 실행 확인
7. settings.gradle.kts에 include 추가
8. CLAUDE.md 업데이트

### 새 앱 라이브러리 생성 ({app}/libs/)
1. libs/ 하위에 모듈 디렉토리 생성
2. build.gradle.kts에 Convention Plugin 적용
3. OSS 인터페이스의 구체 구현 작성 (Firebase, Play 등)
4. Koin 모듈 정의
5. 테스트 작성 (Fake 기반)
6. settings.gradle.kts에 include 추가
7. CLAUDE.md 업데이트

### 기존 코드 이전
1. 이전 대상 코드 식별 + import 경로 확인
2. 새 모듈에 코드 복사 (패키지 경로 변경)
3. 기존 위치에서 코드 제거
4. 앱 모듈에서 새 모듈 implementation 추가
5. import 경로 전체 업데이트
6. 전체 desktopTest 실행
7. 실패 시 → 3-failure rule 적용
8. 통과 시 커밋

### 주의사항
- 한 번에 하나의 모듈만 이전
- 이전 전후 테스트 수 동일 확인
- 순환 의존 발생 시 → 인터페이스 추출로 해결
- OSS 모듈에서 절대로 Firebase/Play/Apple SDK import 금지
