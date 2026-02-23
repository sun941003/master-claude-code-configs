# Master Claude Code Configs

AI 코딩 어시스턴트(Claude Code, JetBrains Junie)의 공용 설정을 관리하는 레포지토리.

## 구조

```
├── CLAUDE.md                       # 공통 Claude Code 지침 (프로젝트에 복사)
├── .claude/
│   ├── agents/                     # 공통 에이전트
│   │   ├── kmp-architect.md        # 아키텍처/코드리뷰 (Opus)
│   │   ├── compose-ui-builder.md   # UI 구현 (Sonnet)
│   │   ├── test-engineer.md        # 테스트 (Sonnet)
│   │   └── devops-runner.md        # 빌드/배포 (Sonnet)
│   ├── commands/                   # 공통 커맨드
│   │   ├── build-check.md          # Android+iOS 빌드 확인
│   │   ├── convert-design.md       # HTML→Compose 변환
│   │   └── implement-feature.md    # 전체 레이어 기능 구현
│   └── skills/
│       └── kmp-patterns/SKILL.md   # expect/actual 패턴 가이드
├── kotlin/                         # (레거시) Kotlin/KMP 프로젝트 공용
│   ├── CLAUDE_COMMON.md            # 마스터 규칙 (레거시 심볼릭 링크용)
│   ├── CONVENTIONS.md              # 공용 코딩 컨벤션
│   ├── GLOBAL_SKILLS.md            # 공용 스킬 정의
│   └── agents/                     # 레거시 서브에이전트 정의
├── .claudeignore                   # 공용 .claudeignore 템플릿
└── README.md
```

## 사용법

프로젝트 루트에서 `claude-init` 실행 (`.zshrc`에 정의):

```bash
claude-init          # Kotlin 프로젝트 (기본)
claude-init swift    # Swift 프로젝트 (향후)
```

### claude-init이 수행하는 작업

1. `CLAUDE.md` 복사 (공통 베이스 → 프로젝트에서 전용 섹션 추가 가능)
2. `.claude/agents/` 에이전트 파일 심볼릭 링크
3. `.claude/commands/` 커맨드 파일 심볼릭 링크
4. `.claude/skills/` 스킬 파일 심볼릭 링크
5. `.claude/hardware_specs.md` 하드웨어 스펙 생성
6. `.junie/guidelines.md` Junie 가이드라인 병합 생성

### 프로젝트 전용 파일 (claude-init 대상 아님)

프로젝트별로 `.claude/` 내에 추가하는 파일은 master에 포함하지 않는다:
- 프로젝트 전용 에이전트 (예: `firebase-backend.md`)
- 프로젝트 전용 스킬 (예: `ureen-design-system/`)
- `CLAUDE.md` 하단의 프로젝트 전용 섹션

## 명칭 정의

| 용어 | 의미 | 위치 |
|------|------|------|
| **공용 (Shared)** | 모든 프로젝트에 적용되는 규칙/에이전트/스킬 | 이 레포 (`master-claude-code-configs/`) |
| **프로젝트 (Local)** | 특정 프로젝트에만 적용 | 각 프로젝트 폴더 (CLAUDE.md 하단, 전용 agents/skills) |

## 전략 문서

`docs/` 디렉토리에 MoonDeveloper 전략 문서가 있습니다.
작업 유형별 참조 가이드는 [INDEX.md](INDEX.md)를 확인하세요.
