# MoonDeveloper — 공통 지침

> CMP 기반 1인 글로벌 앱 스튜디오. 이 레포는 모든 앱 프로젝트가 상속하는 공통 규칙을 관리한다.

## 앱 포트폴리오
| 앱 | 상태 | 비고 |
|-----|------|------|
| Splitly | Phase 12 (사업자등록 대기) | 정산+가계부, 922 테스트 |
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
