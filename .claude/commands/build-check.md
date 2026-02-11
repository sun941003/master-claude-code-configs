---
description: Android + iOS 빌드 확인 및 에러 자동 수정
allowed-tools: [Bash(./gradlew *), Read, Write, Edit]
---

1. `./gradlew :composeApp:assembleDebug 2>&1` → 에러 시 수정 → 재시도 (3회)
2. 성공 후 `./gradlew :composeApp:linkDebugFrameworkIosSimulatorArm64 2>&1` → 동일
3. 보고: Android, iOS, 수정 파일
