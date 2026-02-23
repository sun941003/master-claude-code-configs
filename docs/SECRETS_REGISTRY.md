# MoonDeveloper — Secrets Registry

> 시크릿/키/인증서 중앙 관리 가이드.
> 실제 키 값은 이 문서에 포함하지 않음 → moondeveloper-secrets 프라이빗 레포에 저장.

---

## 방식: git-crypt + 프라이빗 레포

### 왜 git-crypt인가

```
∙ 무료 (1Password 월 $2.99 불필요)
∙ Git 기반 → 버전 관리 + 히스토리 + 어디서든 클론
∙ OS 무관 (맥/윈도우/리눅스 모두 가능)
∙ 맥미니 추가 시 마이그레이션 비용 0
∙ GPG 키만 있으면 어느 기기에서든 복호화
```

---

## 레포 구조

```
moondeveloper-secrets/ (GitHub Private)
├── .gitattributes          # git-crypt 대상 파일 지정
├── README.md               # 사용법 (암호화 안 됨)
│
├── apple/
│   ├── team_id.env         # 🔒 APPLE_TEAM_ID=...
│   ├── asc_api_key.env     # 🔒 ASC_KEY_ID, ASC_ISSUER_ID
│   ├── p12_password.env    # 🔒 P12_PASSWORD=...
│   └── cert_expiry.md      # 인증서 만료일 추적 (암호화 안 됨)
│
├── google/
│   ├── play_service_account.json  # 🔒 서비스 계정
│   ├── keystore.env        # 🔒 경로, 비밀번호, 별칭
│   └── keystore/           # 🔒 실제 .jks 파일
│
├── firebase/
│   ├── splitly.env         # 🔒 프로젝트 ID, Web API Key
│   └── ureen.env           # 🔒
│
├── admob/
│   └── app_ids.env         # 🔒 Android/iOS App ID
│
├── github/
│   └── tokens.env          # 🔒 PAT
│
├── slack/
│   └── webhooks.env        # 🔒 Webhook URLs
│
└── scripts/
    ├── load_all.sh         # 전체 환경변수 로드
    ├── load_project.sh     # 프로젝트별 로드 (splitly/ureen)
    └── verify_secrets.sh   # 키 유효성 검증
```

---

## 초기 설정 (1회)

### 1. git-crypt 설치

```bash
brew install git-crypt gnupg
```

### 2. GPG 키 생성 (없는 경우)

```bash
gpg --full-generate-key
# → RSA 4096, 이름, 이메일 입력
# → 키 ID 확인:
gpg --list-keys --keyid-format SHORT
```

### 3. 레포 생성 + git-crypt 초기화

```bash
gh repo create moondeveloper/moondeveloper-secrets --private
cd moondeveloper-secrets

git-crypt init
git-crypt add-gpg-user <GPG-KEY-ID>
```

### 4. .gitattributes 설정

```
# 암호화 대상
*.env filter=git-crypt diff=git-crypt
*.json filter=git-crypt diff=git-crypt
*.jks filter=git-crypt diff=git-crypt
*.p12 filter=git-crypt diff=git-crypt

# 암호화 제외 (명시적)
README.md !filter !diff
cert_expiry.md !filter !diff
*.sh !filter !diff
.gitattributes !filter !diff
```

### 5. 기존 키 마이그레이션

```bash
# Apple
echo "APPLE_TEAM_ID=667PKR9RY6" > apple/team_id.env
echo "ASC_KEY_ID=7D688H96F6" > apple/asc_api_key.env
echo "ASC_ISSUER_ID=656c7d95-5d6b-4b46-a200-0b8a157f5f11" >> apple/asc_api_key.env
echo "P12_PASSWORD=vega6732" > apple/p12_password.env

# 이하 각 서비스별 .env 파일 생성...

git add -A
git commit -m "feat: initial secrets setup"
git push
```

---

## 사용법

### 새 기기에서 복호화

```bash
git clone git@github.com:moondeveloper/moondeveloper-secrets.git
cd moondeveloper-secrets
git-crypt unlock  # GPG 키로 자동 복호화
```

### 환경변수 로드

```bash
# 전체 로드
source ~/moondeveloper-secrets/scripts/load_all.sh

# 프로젝트별 로드
source ~/moondeveloper-secrets/scripts/load_project.sh splitly

# 사용
echo $APPLE_TEAM_ID
echo $ASC_KEY_ID
```

### load_all.sh 예시

```bash
#!/bin/bash
SECRETS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

for env_file in $(find "$SECRETS_DIR" -name "*.env" -type f); do
  set -a
  source "$env_file"
  set +a
done

echo "✅ $(find "$SECRETS_DIR" -name "*.env" | wc -l | tr -d ' ')개 시크릿 파일 로드됨"
```

### load_project.sh 예시

```bash
#!/bin/bash
PROJECT=$1
SECRETS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$PROJECT" ]; then
  echo "Usage: load_project.sh <splitly|ureen|betOnMe>"
  exit 1
fi

# 공통
source "$SECRETS_DIR/apple/team_id.env"
source "$SECRETS_DIR/apple/asc_api_key.env"
source "$SECRETS_DIR/github/tokens.env"
source "$SECRETS_DIR/slack/webhooks.env"

# 프로젝트별
if [ -f "$SECRETS_DIR/firebase/$PROJECT.env" ]; then
  source "$SECRETS_DIR/firebase/$PROJECT.env"
fi

echo "✅ $PROJECT 시크릿 로드됨"
```

### Fastlane에서 사용

```ruby
# Fastfile
lane :deploy_android do
  supply(
    json_key: ENV["PLAY_SERVICE_ACCOUNT_PATH"],
    track: "internal"
  )
end

lane :deploy_ios do
  api_key = app_store_connect_api_key(
    key_id: ENV["ASC_KEY_ID"],
    issuer_id: ENV["ASC_ISSUER_ID"],
    key_filepath: ENV["ASC_KEY_PATH"]
  )
  upload_to_testflight(api_key: api_key)
end
```

### CI/CD에서 사용

```yaml
# GitHub Actions
# git-crypt 키를 base64로 GitHub Secrets에 저장
# GIT_CRYPT_KEY: base64 인코딩된 git-crypt 키

steps:
  - uses: actions/checkout@v4
  - name: Decrypt secrets
    run: |
      echo "${{ secrets.GIT_CRYPT_KEY }}" | base64 -d > /tmp/git-crypt-key
      git-crypt unlock /tmp/git-crypt-key
      rm /tmp/git-crypt-key
  - name: Load secrets
    run: source scripts/load_all.sh
```

---

## 관리 대상 목록

| 서비스 | 키/정보 | 파일 | 갱신 주기 |
|--------|--------|------|----------|
| Apple | Team ID | apple/team_id.env | 변경 없음 |
| Apple | ASC Key ID + Issuer | apple/asc_api_key.env | 변경 없음 |
| Apple | p12 비밀번호 | apple/p12_password.env | 인증서 갱신 시 |
| Apple | 인증서 만료일 | apple/cert_expiry.md | 연 1회 확인 |
| Google | 서비스 계정 JSON | google/play_service_account.json | 변경 없음 |
| Google | 키스토어 | google/keystore/ | 변경 없음 |
| Firebase | splitly 설정 | firebase/splitly.env | 변경 없음 |
| Firebase | ureen 설정 | firebase/ureen.env | 변경 없음 |
| AdMob | App ID (Android/iOS) | admob/app_ids.env | 변경 없음 |
| GitHub | PAT | github/tokens.env | 90일 갱신 |
| Slack | Webhook URLs | slack/webhooks.env | 변경 없음 |

---

## 보안 규칙

```
1. .env 파일은 절대 앱 프로젝트에 복사하지 않음 → source로만 사용
2. 커밋 전 git-crypt status로 암호화 상태 확인
3. GPG 키 백업 필수 (외장 드라이브 또는 종이 백업)
4. GitHub PAT는 최소 권한 (repo + workflow만)
5. 팀 확장 시 → GPG 키 추가로 멤버 관리
6. 인증서 만료 → cert_expiry.md에 날짜 기록, 캘린더 알림
```

---

## 관련 문서

- [TOOLCHAIN_STRATEGY.md](TOOLCHAIN_STRATEGY.md) — CI/CD에서 시크릿 사용
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) — 빌드/배포 프로세스

