# 성능 규칙
> 원본: docs/TOOLCHAIN_STRATEGY.md, docs/INFRASTRUCTURE.md 참조

## 하드웨어
- MBA M4 10코어 / 24GB RAM / 256GB SSD (용량 부족 빈번)

## Gradle 빌드
- `--parallel`, `org.gradle.jvmargs=-Xmx4g`
- K/N OOM → `-Xmx4g`
- testRelease 금지 (R8 + Robolectric 충돌)
- 빌드 전 `gradle --stop`
- 디스크 부족 시: `./gradlew clean` + `~/.gradle/caches` 정리

## 에이전트 병렬 실행
- 최대 동시 에이전트: 4개 (CPU 80% 상한)
- Gradle 데몬 동시 실행: 1개만 (빌드 큐)
- 에이전트당 JVM: Xmx2g, 전체 합계 16GB 이내
- 나머지 8GB = macOS + IDE + 브라우저
- CPU 100% 허용 (macOS UI 응답성 확인됨), 단 I/O 병목 회피
- 대용량 파일 작업(번역 78개 등)은 배치로 묶어 I/O 1회
- 동일 프로젝트에서 ./gradlew 동시 실행 금지
