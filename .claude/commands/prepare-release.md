---
description: "배포 준비 자동화 — 버전 관리 + CHANGELOG + PR 생성"
argument-hint: "<version: 1.0.0 | auto | patch | minor | major>"
allowed-tools: [Bash(*), Read, Write, Edit, Grep]
---

# 배포 준비: $ARGUMENTS

## Phase 1: 버전 결정

### 1-1. 현재 버전 읽기

Android versionCode와 versionName을 build.gradle.kts에서 추출:

```bash
GRADLE_FILE="composeApp/build.gradle.kts"
CURRENT_VERSION_CODE=$(grep -E "versionCode\s*=" "$GRADLE_FILE" | head -1 | grep -oE '[0-9]+')
CURRENT_VERSION_NAME=$(grep -E "versionName\s*=" "$GRADLE_FILE" | head -1 | grep -oE '"[^"]+"' | tr -d '"')
echo "Current Android: versionCode=$CURRENT_VERSION_CODE, versionName=$CURRENT_VERSION_NAME"
```

iOS 버전도 확인:

```bash
XCCONFIG="iosApp/Configuration/Config.xcconfig"
IOS_VERSION=$(grep MARKETING_VERSION "$XCCONFIG" | cut -d'=' -f2 | tr -d ' ')
IOS_BUILD=$(grep CURRENT_PROJECT_VERSION "$XCCONFIG" | cut -d'=' -f2 | tr -d ' ')
echo "Current iOS: MARKETING_VERSION=$IOS_VERSION, CURRENT_PROJECT_VERSION=$IOS_BUILD"
```

양 플랫폼 버전 불일치 시 경고 출력하고 Android 기준으로 통일.

### 1-2. 새 versionCode 계산 (항상 +1, 양 OS 동일)

```bash
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
echo "New versionCode/CURRENT_PROJECT_VERSION: $NEW_VERSION_CODE"
```

### 1-3. 새 versionName 결정

인자($ARGUMENTS) 분석:
- 구체적 버전 (예: "1.2.0"): 그대로 사용
- "auto": git diff 분석으로 자동 결정 (릴리즈 태그 필요)
- "patch": Z만 +1 (1.0.0 → 1.0.1)
- "minor": Y +1, Z = 0 (1.0.1 → 1.1.0)
- "major": X +1, Y = 0, Z = 0 (1.2.3 → 2.0.0)

#### "auto" 모드 git diff 분석:

마지막 릴리즈 태그 찾기:

```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
```

태그 없으면 → "⚠️ 릴리즈 태그가 없습니다. 수동 지정 필요: /prepare-release 1.0.0" 출력 후 중단.

태그 있으면 diff 통계 수집:
- CHANGED_FILES: *.kt, *.swift 변경 파일 수
- CHANGED_SCREENS: screen/page/view/dialog 포함 파일 변경 수
- TOTAL_SCREENS: 프로젝트 내 전체 화면 파일 수
- NEW_FILES: 신규 추가된 .kt 파일 수
- INSERTIONS/DELETIONS: 추가/삭제 라인 수
- FEAT_COUNT, FIX_COUNT, REFACTOR_COUNT: 커밋 메시지 기반 카운트
- BREAKING_COUNT: "breaking" 키워드 포함 커밋 수

버전 결정 기준:
- MAJOR: breaking change 존재 OR (전체 화면 60%+ 변경 AND 1000줄+ 변경)
- MINOR: feat 커밋 존재 OR 신규 파일 5개+ OR 300줄+ 변경
- PATCH: 그 외

분석 결과와 판단 근거를 상세히 출력.

#### 버전 숫자 계산:

```bash
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION_NAME"
case "$BUMP_TYPE" in
  major) NEW_VERSION="$((MAJOR + 1)).0.0" ;;
  minor) NEW_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
  patch) NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
esac
```

## Phase 2: 버전 적용 (Android + iOS 동시)

### 2-1. Android build.gradle.kts
versionCode와 versionName을 sed로 교체.

### 2-2. iOS Config.xcconfig
MARKETING_VERSION과 CURRENT_PROJECT_VERSION을 sed로 교체.

### 2-3. 양 플랫폼 일치 검증
업데이트 후 다시 읽어서 Android versionName == iOS MARKETING_VERSION, Android versionCode == iOS CURRENT_PROJECT_VERSION 확인.
불일치 시 ❌ 출력 + 수동 확인 요청.

## Phase 3: CHANGELOG.md 업데이트

마지막 태그부터 HEAD까지 커밋을 카테고리별 분류:
- Added: feat 커밋
- Changed: refactor, chore, ci, docs 커밋
- Fixed: fix 커밋

CHANGELOG.md 상단에 새 버전 섹션 삽입. 기존 내용 유지.

## Phase 4: 스토어 업데이트 노트 생성

CHANGELOG 기반 500자 이내 요약:
- fastlane/metadata/android/ko-KR/changelogs/{versionCode}.txt (한국어)
- fastlane/metadata/android/en-US/changelogs/{versionCode}.txt (영어)

## Phase 5: 커밋 + PR 생성

```bash
git add -A
git commit -m "chore: prepare release v$NEW_VERSION (build $NEW_VERSION_CODE)"
git push origin dev
gh pr create --base release --head dev \
  --title "Release v$NEW_VERSION" \
  --body "## Release v$NEW_VERSION (Build $NEW_VERSION_CODE)

$(CHANGELOG 상위 40줄)

### 자동 배포 대상
- ✅ Android AAB → Play Store 내부 테스트
- ✅ iOS IPA → TestFlight 내부 테스트

### Checklist
- [ ] CHANGELOG 확인
- [ ] 버전: v$NEW_VERSION (build $NEW_VERSION_CODE)
- [ ] 승인 → merge 시 양 OS 자동 배포 시작"
```

## Phase 6: 사용자 보고

```
📋 배포 준비 완료

📌 버전: v{NEW_VERSION} (build {NEW_VERSION_CODE})
📌 이전: v{OLD_VERSION} (build {OLD_CODE})
📌 bump: {타입} ({근거})

📝 CHANGELOG: Added {N}건, Changed {N}건, Fixed {N}건

🔗 PR: {URL}

✅ PR 승인 → merge 시:
  ├─ 🤖 Android AAB → Play Store 내부 테스트
  └─ 🍎 iOS IPA → TestFlight 내부 테스트
```
