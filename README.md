# Master Claude Code Configs

AI 코딩 어시스턴트(Claude Code, JetBrains Junie)의 공용 설정을 관리하는 레포지토리.

## 구조

```
├── kotlin/                  # Kotlin/KMP 프로젝트 공용
│   ├── CLAUDE_COMMON.md     # 마스터 규칙 (프로젝트에서 CLAUDE.md로 심볼릭 링크)
│   ├── CONVENTIONS.md       # 공용 코딩 컨벤션
│   ├── GLOBAL_SKILLS.md     # 공용 스킬 정의
│   └── agents/              # 서브에이전트 정의
├── .claudeignore            # 공용 .claudeignore 템플릿
└── README.md
```

## 사용법

프로젝트 루트에서 `claude-init` 실행 (`.zshrc`에 정의):

```bash
claude-init          # Kotlin 프로젝트 (기본)
claude-init swift    # Swift 프로젝트 (향후)
```

### claude-init이 수행하는 작업

1. `CLAUDE.md` → `CLAUDE_COMMON.md` 심볼릭 링크 생성
2. `.claude/agents/` 에이전트 파일 심볼릭 링크
3. `.claude/hardware_specs.md` 하드웨어 스펙 생성
4. `.junie/guidelines.md` Junie 가이드라인 병합 생성

## 명칭 정의

| 용어 | 의미 | 위치 |
|------|------|------|
| **공용 (Shared)** | 모든 프로젝트에 적용되는 규칙/스킬 | 이 레포 (`master-claude-code-configs/`) |
| **프로젝트 (Local)** | 특정 프로젝트에만 적용 | 각 프로젝트 폴더 (`INSTRUCTIONS.md`, `SKILLS.md` 등) |
