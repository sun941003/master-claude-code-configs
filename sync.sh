#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MoonDeveloper Sync Script
# master-claude-code-configs → 모든 프로젝트 레포 동기화
#
# 사용법: bash sync.sh [--dry-run] [--project splitly]
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# ━━━ 설정 ━━━
MOON_DIR="/Users/mcs/AndroidStudioProjects/MoonDeveloper"
CONFIGS_DIR="$MOON_DIR/master-claude-code-configs"
DRY_RUN=false
TARGET_PROJECT=""

# 동기화 대상 레포 목록
PROJECTS=(
  "splitly"
  "ureen/ureen"
  # "betOnMe"  # 생성 후 주석 해제
)

# ━━━ 인자 파싱 ━━━
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --project) TARGET_PROJECT="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: bash sync.sh [--dry-run] [--project splitly]"
      echo "  --dry-run    변경하지 않고 계획만 출력"
      echo "  --project    특정 프로젝트만 동기화"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "╔══════════════════════════════════════════╗"
echo "║     MoonDeveloper Sync Script            ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if $DRY_RUN; then
  echo "🔍 DRY RUN 모드 — 변경 없이 계획만 출력"
  echo ""
fi

# ━━━ 소스 확인 ━━━
if [ ! -d "$CONFIGS_DIR" ]; then
  echo "❌ master-claude-code-configs 미발견: $CONFIGS_DIR"
  exit 1
fi

# ━━━ CLAUDE.md 생성 (docs에서 조합) ━━━
generate_claude_md() {
  local project=$1
  local project_name=$(basename "$project")
  local output_file="$MOON_DIR/$project/CLAUDE.md"

  cat << 'HEADER'
# CLAUDE.md — MoonDeveloper 공통 지침

> 이 파일은 master-claude-code-configs에서 자동 생성됩니다.
> 직접 수정하지 마세요. sync.sh로 관리됩니다.
> 마지막 동기화: SYNC_DATE

HEADER

  # 공통 개발 가이드
  echo "## 아키텍처 & 개발 원칙"
  echo ""
  echo "- 신규 앱: MVI (Model-View-Intent) 패턴"
  echo "- Splitly: 기존 MVVM 유지, 신규 ViewModel만 MVI"
  echo "- 테스트: desktopTest only, 5분 타임아웃, FAIL 3회 → @Ignore + TODO"
  echo "- 작업 전: gradle --stop 필수"
  echo "- Import 포함 완전한 파일 단위 코드 작성"
  echo "- 패키지: com.moondeveloper.{app}.{layer}.{feature}"
  echo ""

  # 테스트 규칙
  echo "## 테스트 규칙"
  echo ""
  echo "- desktopTest만 사용 (allTests 금지)"
  echo "- 5분 컴파일 + 실행 타임아웃"
  echo "- Fake 구현 우선, 1 agent = 1 ViewModel"
  echo "- 3회 실패 → @Ignore + TODO + DEFERRED_TESTS.md 기록"
  echo ""

  # 세션 관리
  echo "## 세션 관리"
  echo ""
  echo "- 작업 시작: PROGRESS.md 확인"
  echo "- 작업 중: PROGRESS.md 실시간 갱신"
  echo "- 작업 종료: '진행 현황 업데이트해줘'로 갱신 요청"
  echo "- 브랜치: dev에서 작업, main 머지는 사용자 확인 후"
  echo ""

  # 기술 스택
  echo "## 기술 스택"
  echo ""
  echo "| 영역 | 기술 |"
  echo "|------|------|"
  echo "| UI | Compose Multiplatform + Material 3 |"
  echo "| DI | Koin 4.1.1 |"
  echo "| DB | Room KMP v5 |"
  echo "| Auth | Firebase Auth |"
  echo "| Build | Kotlin 2.3.0, AGP 8.11.2 |"
  echo "| CI | GitHub Actions + lefthook + Danger |"
  echo ""

  # 자동화 도구
  echo "## 자동화 도구"
  echo ""
  echo "- lefthook: pre-push desktopTest 자동 실행"
  echo "- Danger JS: PR 리뷰 (테스트 누락, i18n, STUB 감지)"
  echo "- Renovate: 의존성 자동 업데이트 (매주 주말)"
  echo "- Gradle Build Cache: CI 빌드 30-50% 단축"
  echo ""

  # 프로젝트별 추가 정보
  echo "## 프로젝트별 참고"
  echo ""
  case "$project_name" in
    splitly)
      echo "- 경로: /Users/mcs/AndroidStudioProjects/MoonDeveloper/splitly"
      echo "- 스펙: docs/PROJECT_SPEC_v2.md"
      echo "- 웹: https://splitlyapp.net"
      echo "- Firebase: splitly-aea8c"
      echo "- 현재: Phase 12 (배포 전 고도화)"
      ;;
    ureen)
      echo "- 경로: /Users/mcs/AndroidStudioProjects/MoonDeveloper/ureen/ureen/"
      echo "- 스펙: docs/ureen_기능명세서_v1_0.md"
      echo "- 상태: Step 0~15 완료, 홀딩 중"
      echo "- 기능명세서 외 요청 시 '기능명세서 업데이트 필요?' 확인 필수"
      ;;
    *)
      echo "- 프로젝트별 정보 없음"
      ;;
  esac
}

# ━━━ 동기화 실행 ━━━
SYNCED=0
SKIPPED=0

for project in "${PROJECTS[@]}"; do
  project_name=$(basename "$project")
  project_path="$MOON_DIR/$project"

  # 특정 프로젝트만 대상일 때
  if [ -n "$TARGET_PROJECT" ] && [ "$project_name" != "$TARGET_PROJECT" ]; then
    continue
  fi

  if [ ! -d "$project_path" ]; then
    echo "⏭️  $project_name — 디렉토리 없음, 스킵"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  echo "━━━ $project_name ━━━"

  # CLAUDE.md 동기화
  CLAUDE_FILE="$project_path/CLAUDE.md"
  SYNC_DATE=$(date '+%Y-%m-%d %H:%M')

  if $DRY_RUN; then
    echo "  📝 [DRY] CLAUDE.md 생성 예정: $CLAUDE_FILE"
  else
    generate_claude_md "$project" | sed "s/SYNC_DATE/$SYNC_DATE/" > "$CLAUDE_FILE"
    echo "  ✅ CLAUDE.md 동기화됨"
  fi

  # renovate.json 동기화 (없는 레포에만)
  RENOVATE_SRC="$CONFIGS_DIR/templates/renovate.json"
  RENOVATE_DST="$project_path/renovate.json"
  if [ -f "$RENOVATE_SRC" ] && [ ! -f "$RENOVATE_DST" ]; then
    if $DRY_RUN; then
      echo "  📝 [DRY] renovate.json 복사 예정"
    else
      cp "$RENOVATE_SRC" "$RENOVATE_DST"
      echo "  ✅ renovate.json 복사됨"
    fi
  fi

  # lefthook.yml 동기화 (없는 레포에만)
  LEFTHOOK_SRC="$CONFIGS_DIR/templates/lefthook.yml"
  LEFTHOOK_DST="$project_path/lefthook.yml"
  if [ -f "$LEFTHOOK_SRC" ] && [ ! -f "$LEFTHOOK_DST" ]; then
    if $DRY_RUN; then
      echo "  📝 [DRY] lefthook.yml 복사 예정"
    else
      cp "$LEFTHOOK_SRC" "$LEFTHOOK_DST"
      echo "  ✅ lefthook.yml 복사됨"
    fi
  fi

  # Dangerfile.ts 동기화 (없는 레포에만)
  DANGER_SRC="$CONFIGS_DIR/templates/Dangerfile.ts"
  DANGER_DST="$project_path/Dangerfile.ts"
  if [ -f "$DANGER_SRC" ] && [ ! -f "$DANGER_DST" ]; then
    if $DRY_RUN; then
      echo "  📝 [DRY] Dangerfile.ts 복사 예정"
    else
      cp "$DANGER_SRC" "$DANGER_DST"
      echo "  ✅ Dangerfile.ts 복사됨"
    fi
  fi

  SYNCED=$((SYNCED + 1))
  echo ""
done

# ━━━ Claude Project Knowledge 안내 ━━━
echo "━━━ Claude Project Knowledge 동기화 ━━━"
echo ""
echo "📋 수동 업데이트 필요 파일:"
echo "   1. PROGRESS.md → Claude 프로젝트에 업로드"
echo "      위치: $MOON_DIR/splitly/PROGRESS.md"
echo ""
echo "   자동화 불가 사유: Claude Project Knowledge는 API 미제공"
echo ""

# ━━━ 결과 ━━━
echo "╔══════════════════════════════════════════╗"
echo "║  동기화 결과                              ║"
echo "║  ✅ 동기화: ${SYNCED}개 프로젝트           ║"
echo "║  ⏭️  스킵: ${SKIPPED}개 프로젝트           ║"
echo "╚══════════════════════════════════════════╝"

if $DRY_RUN; then
  echo ""
  echo "💡 실제 실행하려면: bash sync.sh (--dry-run 없이)"
fi
