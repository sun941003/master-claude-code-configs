import { danger, warn, fail, message } from "danger"

// 1. 테스트 파일 변경 없이 소스만 변경 시 경고
const srcChanges = danger.git.modified_files.filter(f => f.includes("/src/"))
const testChanges = danger.git.modified_files.filter(f => f.includes("Test"))
if (srcChanges.length > 0 && testChanges.length === 0) {
  warn("소스 변경이 있지만 테스트 파일 변경이 없습니다.")
}

// 2. strings.xml 변경 시 다국어 체크 알림
const i18nChanges = danger.git.modified_files.filter(f => f.includes("strings.xml") || f.includes("locales/"))
if (i18nChanges.length > 0) {
  message("다국어 파일 변경 감지. i18n 검증 스크립트 실행을 권장합니다.")
}

// 3. STUB/TODO 추가 감지
const checkStubs = async () => {
  const diffResults = await Promise.all(
    danger.git.modified_files.map(f => danger.git.diffForFile(f))
  )
  const newStubs = diffResults.filter(d => d && (d.added.includes("STUB") || d.added.includes("TODO")))
  if (newStubs.length > 0) {
    warn("새 STUB/TODO가 추가되었습니다. QA 체크리스트 업데이트를 확인하세요.")
  }
}
checkStubs()

// 4. 큰 PR 경고
if (danger.github.pr.additions + danger.github.pr.deletions > 1000) {
  warn("PR이 1000줄 이상입니다. 분할을 검토하세요.")
}
