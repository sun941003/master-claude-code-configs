# MoonDeveloper — 공통 지침

> CMP 기반 1인 글로벌 앱 스튜디오. 이 레포는 모든 앱 프로젝트가 상속하는 공통 규칙을 관리한다.

## 앱 포트폴리오
| 앱 | 상태 | 비고 |
|-----|------|------|
| Splitly | Phase 12 (사업자등록 대기) | 정산+가계부, 1094 테스트 |
| BetOnMe | 기획 전 | 습관 내기앱, Splitly 모듈 65% 재사용 |
| ureen | 홀딩 | 로또 추천앱, v1.0.0 출시 완료 |

## 공통 기술 스택
KMP (Kotlin 2.3.0) + Compose Multiplatform + Material 3 + Koin 4.1.1 + Room KMP / Firebase (GitLive) + GitHub Actions

## .claude/ 구조
| 디렉토리 | 용도 | 로드 방식 |
|----------|------|----------|
| rules/ | Git, 테스트, 코드스타일, 성능 규칙 | 모든 세션 자동 로드 |
| agents/ | 에이전트 정의 + 팀 프로토콜 | 팀 작업 시 로드 |
| infra/ | 하드웨어, 시크릿, CI/CD 요약 | 필요 시 참조 |
| strategy/ | 비전, 포트폴리오 요약 | 필요 시 참조 |

> rules/는 모든 앱 프로젝트에서 자동 상속된다. 앱별 CLAUDE.md에서 "공통 규칙은 master-claude-code-configs 참조"로 연결.

## 원본 문서
상세 전략은 `docs/` 참조 (8개 문서). `.claude/`는 세션용 요약본이며, `docs/`가 source of truth.

## Kotlin/KMP 공용 규칙
`kotlin/CLAUDE_COMMON.md` — 모든 KMP 프로젝트의 마스터 규칙
`kotlin/CONVENTIONS.md` — 코딩 컨벤션
`kotlin/GLOBAL_SKILLS.md` — 12개 공용 스킬

## 모듈화 규칙
- 3-Tier: OSS 라이브러리(moon-*) → 앱 라이브러리({app}-*) → 앱
- OSS 모듈은 앱 의존성 제로 (Firebase, Play 등 금지)
- Convention Plugin으로 빌드 설정 통일
- 상세: .claude/agents/modularization-agent.md 참조

---

## Storage Optimization

> 모든 프로젝트에 자동 적용됩니다. (claude-init으로 복사됨)

### File Generation Rules
- 임시 파일(`*.tmp`, `*.bak`, `*.orig`) → 작업 완료 즉시 삭제
- 중복 파일 생성 금지 — 기존 파일 수정 우선
- Dead code / 미사용 import → 발견 즉시 제거
- 로그 파일 → rotate 방식만 허용 (`maxFileSize` 필수)
- 캐시 디렉토리 → 명시적 경로 외 생성 금지

### Build Artifact Policy
- `build/` 디렉토리 → 작업 중 보존, 배포 직전 정리
- `.gradle/` 캐시 → **절대 삭제 금지** (재빌드 시간 급증)
- `iosApp/build/`, `.kotlin/` → 커밋 전 `.gitignore` 확인
- `./gradlew clean` → 명시적 요청 시에만 실행

### Dependency Management
- 새 라이브러리 추가 전 `libs.versions.toml` 중복 확인
- 버전 카탈로그 방식만 허용 (`implementation("...")` 직접 작성 금지)
- 미사용 의존성 → 분기마다 정리

### Asset Rules
- `*.png` 리소스 → WebP 변환 권장 (30% 이상 절감)
- `commonMain` 리소스 → 단일 소스 원칙, 플랫폼별 복사본 생성 금지
- 미사용 string/drawable → 분기마다 정리

### Storage Budget
| 항목 | 권장 상한 |
|---|---|
| 모듈 소스 합계 | 50MB 이하 |
| 리소스 (이미지/폰트) | 20MB 이하 |
| `.gradle/` 캐시 | 5GB 이하 |
| 로그 파일 | 10MB 이하 |

### After Each Task
1. 생성/수정 파일 목록 + 크기 출력
2. 정리 가능한 임시 파일 있으면 목록 제시 후 확인
3. 미사용 import 자동 정리
4. `build/` 외 경로 바이너리 잔류 여부 확인

### Never Do
- `.keystore` 파일 이동/삭제
- `local.properties` 수정
- `~/.gradle/` 루트 캐시 삭제
- Git 트래킹 중인 파일 무단 삭제
- 환경변수(`API_KEY`, `SECRET`) 하드코딩
