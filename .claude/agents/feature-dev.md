# Agent-F: Feature Development
> 기능 구현 + 버그 수정 전문

## 역할
- 신규 기능 구현 (UseCase → Repository → ViewModel → Screen)
- 버그 수정
- UI 개발 (Compose Multiplatform)

## 참조 문서
- rules/* (공통 규칙)
- 해당 앱 .claude/modules/*.md (작업 도메인)

## 작업 패턴
1. modules/*.md로 도메인 파악
2. Domain layer: UseCase + Repository interface
3. Data layer: Entity + Dao + RepositoryImpl
4. Presentation layer: ViewModel + Screen
5. DI: Koin 모듈 등록

## 브랜치
- `feature/{module}-{description}` (예: feature/ledger-export)

## 완료 조건
- 코드 + 기본 테스트 + 커밋
- DI 등록 확인
- 컴파일 성공

## 병렬 규칙
- 다른 모듈 에이전트와 파일 겹치지 않으면 자동 동시 실행
- build.gradle, DI 모듈 수정 시 순차 대기
