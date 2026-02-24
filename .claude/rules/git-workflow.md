# Git 워크플로우 규칙
> 원본: docs/DEVELOPMENT_GUIDE.md, kotlin/CLAUDE_COMMON.md 참조

## 브랜치 전략
- feature/*: 기능 개발, fix/*: 버그 수정
- dev: 통합 브랜치, main: 안정 릴리즈

## 커밋 컨벤션
- Conventional Commits: feat/fix/perf/test/docs/refactor/chore
- 한국어 소통, 커밋 메시지 영어

## 세션 시작
1. `gradle --stop` (좀비 데몬 제거)
2. `git branch` → 현재 브랜치 확인
3. 미머지 브랜치 있으면 먼저 머지 처리
4. PROGRESS.md 읽기 (source of truth)

## 세션 종료
1. 디버그 코드 제거 (println, Log.d)
2. `git add -A` → 의미 있는 커밋 메시지
3. `git checkout dev && git merge {branch} --no-ff`
4. `git push origin dev`
5. PROGRESS.md 업데이트
6. 세션 요약 출력 (필수)

## 범위 외 이슈
- 발견 시 원래 의도 파악 후 수정 (무시 금지)
- 수정이 범위를 크게 벗어나면 TODO + 세션 요약에 기록
