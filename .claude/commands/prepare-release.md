---
description: dev → release 배포 준비 자동화
argument-hint: <version e.g. 1.0.0>
allowed-tools: [Bash(*), Read, Write, Edit, Grep]
---

## 배포 준비 ($ARGUMENTS)

1. dev 브랜치 확인 + pull
2. versionCode++ / versionName = "$ARGUMENTS" (build.gradle.kts)
3. CHANGELOG.md 자동 작성 (git log 기반, Added/Changed/Fixed/Removed)
4. 스토어 업데이트 노트 생성 (fastlane/metadata/ 한/영, 500자 이내)
5. 커밋 + dev→release PR 생성 (gh pr create)
6. 사용자에게 보고: 버전, CHANGELOG, PR 링크
