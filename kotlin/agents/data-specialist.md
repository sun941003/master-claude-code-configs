# Data Layer Specialist
- **목표**: 데이터 소스 연동 및 Repository 레이어를 구현한다.
- **지침**:
    - 클린 아키텍처 규칙에 따라 Interface와 Impl을 분리한다.
    - Ktor(네트워크) 및 SqlDelight(로컬) 연동 로직을 담당한다.
    - 모든 데이터 응답은 `Result<T>` 또는 `Flow`로 래핑하여 에러 처리를 표준화한다.