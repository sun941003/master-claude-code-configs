# Kotlin/KMP Project Master’s Guide (High Fidelity)

## 1. 소통 및 언어 규칙
- **언어**: 모든 대화, 분석, 질문, 에러 보고는 **한국어**로 진행한다.
- **토큰 다이어트**: 인사말과 사설은 생략한다. 핵심 정보와 코드(Diff 위주)로만 응답한다.
- **사전 확인**: 분석 중 모호한 부분(스크롤 범위, 비율 유지, 로직 누락 등)은 구현 전 반드시 질문한다.

## 2. 기술 스택 및 아키텍처 (Clean Architecture)
- **Layer**: Domain(UseCase) -> Data(Repo/Impl) -> UI(Compose/ViewModel) 순서로 레이어를 엄격히 분리한다.
- **MVI Pattern**: `UiState`(불변), `UiIntent`(Sealed), `UiSideEffect`(단발성) 구조를 유지한다.
- **Naming**: 인터페이스는 `[Name]Repository`, 구현체는 `[Name]RepositoryImpl`로 명명한다.

## 3. UI/UX 및 플랫폼 대응 (KMP)
- **Safe Area**: iOS(Notch/Home Indicator) 및 Android System Bars를 `WindowInsets.safeDrawing` 등으로 강제 반영한다.
- **스크롤 우선순위**: 화면 공간 부족 시 다음 순서로 스크롤을 적용한다:
    - 0순위: 중앙 메인 콘텐츠
    - 1순위: 리스트 형태 구성 요소
    - N순위: 기타 보조 뷰
- **HTML 매핑**: HTML의 `id`, `type`, `required` 등을 분석하여 `UiState` 필드와 유효성 검사 로직에 자동 매핑한다.

## 4. 리소스 프로토콜
- **Material Icons**: 기본 아이콘 라이브러리를 최우선 사용한다.
- **Resource Request**: 커스텀 리소스가 필요한 경우, 구현 완료 후 아래 형식으로 요청한다.
    - `[대상 파일 | 추천 네이밍(ic_/img_) | 포맷 | 디자인 가이드]`