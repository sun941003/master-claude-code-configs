---
name: kmp-patterns
description: KMP expect/actual 패턴 가이드. 플랫폼 분기 코드 작성 시 참조.
---

## 위치: expect=commonMain/.../platform/, actual=androidMain|iosMain/.../platform/

## 패턴
```kotlin
// commonMain
expect class PlatformThing { fun doSomething(): Result<String> }
// androidMain
actual class PlatformThing(private val context: Context) { actual fun doSomething() = runCatching { /*Android*/ } }
// iosMain
actual class PlatformThing { actual fun doSomething() = runCatching { /*iOS*/ } }
```

## 주의: expect에 init블록/함수본문 불가, actual은 동일 패키지, iOS에 Context 없음
