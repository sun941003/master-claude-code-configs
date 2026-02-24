# 코드 스타일 규칙
> 원본: kotlin/CONVENTIONS.md 참조

## 패키지 구조
- `com.moondeveloper.{app}.{layer}.{feature}`
- layer: domain, data, presentation, di, util, platform

## 코드 작성
- Import 포함 완전한 파일 단위 코드 제공
- KMP: expect/actual 양 플랫폼 코드 함께 작성
- 신규 앱: MVI (Model-View-Intent) 아키텍처
- Splitly: 기존 MVVM 유지, 신규 ViewModel만 MVI

## DI (Koin)
- 모듈 구조: AppModule, ViewModelModule, RepositoryModule, UseCaseModule, NetworkModule, ServiceModule
- ViewModel: `viewModel { VM(get(), get(), ...) }` 패턴
- Repository: `single<Interface> { Impl(get()) }` 패턴
- UseCase: `factory { UC(get()) }` 패턴

## UI
- Compose Multiplatform + Material 3 전용
- 디자인 없이 UI 코드 작성 금지
- Stateless Composable 원칙 (State hoisting)

## 네이밍
- PascalCase: 클래스, camelCase: 함수/변수, UPPER_SNAKE: 상수, snake_case: 리소스
