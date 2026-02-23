# MoonDeveloper 인프라 전략 (INFRASTRUCTURE.md)

> **작성일**: 2026-02-23
> **현재 장비**: MacBook Air M4 (24GB/256GB) + Synology DS218+ NAS
> **목표**: 최소 비용으로 다중 장비/프로젝트 동기화 + 자동화 인프라

---

## 현재 아키텍처

```
[MacBook Air M4] ─── WiFi/유선 ─── [DS218+ NAS]
       │                                 │
       ├── 개발 (IDE, Claude Code)       ├── 파일 저장
       ├── 빌드 (Gradle, Xcode)          ├── 백업
       └── 배포 (로컬 빌드)              └── Docker 서비스
```

### 동기화 대상

| 유형 | 경로 | 동기화 방법 | 방향 |
|------|------|------------|------|
| 공통 설정 | master-claude-code-configs/ | sync.sh + Git | Mac → 각 레포 |
| 시크릿 | moondeveloper-secrets/ | git-crypt + Git | Mac ↔ GitHub (private) |
| 프로젝트 | splitly/, ureen/ | Git (GitHub) | Mac ↔ GitHub |
| NAS 백업 | /volume1/MoonDeveloper/ | Syncthing | Mac ↔ NAS |
| CLAUDE.md | 각 레포 루트 | sync.sh | master → 각 레포 |
| Claude Project | claude.ai 웹 | 수동 업로드 | Mac → Claude 웹 |

### 동기화 계층 구조

```
Layer 1: Git (GitHub)
  └── 코드, 설정 파일, 문서 → git push/pull로 동기화
  └── 모든 장비에서 접근 가능

Layer 2: sync.sh (로컬)
  └── master-claude-code-configs → 각 레포 CLAUDE.md 배포
  └── 템플릿 파일 (renovate.json, lefthook.yml) 배포
  └── Mac에서 수동 실행 또는 cron

Layer 3: Syncthing (NAS 허브)
  └── 실시간 파일 동기화 (Git 외 파일: 빌드 캐시, 에셋, 백업)
  └── NAS가 항상 켜있으므로 허브 역할

Layer 4: Claude Project Knowledge
  └── PROGRESS.md, QA 체크리스트 등
  └── API 미제공 → 수동 업로드 (sync.sh가 안내)
```

---

## Stage 1: 즉시 구축 ($0)

### 1-A. sync.sh

| 기능 | 설명 |
|------|------|
| CLAUDE.md 배포 | master-configs → 각 레포에 표준 CLAUDE.md 생성 |
| 템플릿 배포 | renovate.json, lefthook.yml, Dangerfile.ts 복사 |
| --dry-run | 변경 없이 계획만 출력 |
| --project | 특정 프로젝트만 동기화 |

```bash
# 전체 동기화
bash sync.sh

# 계획만 확인
bash sync.sh --dry-run

# Splitly만
bash sync.sh --project splitly
```

### 1-B. DS218+ Docker 서비스

| 서비스 | 포트 | 용도 | RAM |
|--------|------|------|-----|
| Syncthing | 8384 | 파일 동기화 허브 | 256MB |
| Gitea | 3000 | Git 미러 + 백업 | 384MB |
| Backup cron | - | 자동 백업 (매일 3AM) | 64MB |
| **합계** | | | **704MB / 2GB** |

### 1-C. MacBook Syncthing 설정

```bash
brew install syncthing
brew services start syncthing
# http://localhost:8384 에서 NAS 장치 추가
```

**동기화 폴더 설정:**

| MacBook 경로 | NAS 경로 | 방향 |
|-------------|----------|------|
| ~/AndroidStudioProjects/MoonDeveloper/master-claude-code-configs | /volume1/MoonDeveloper/configs | 양방향 |
| 빌드 캐시 (선택) | /volume1/MoonDeveloper/cache | Mac → NAS |

### 1-D. Tailscale (외부 접근)

```bash
# MacBook
brew install tailscale

# DS218+ (패키지 센터에서 설치)
# 또는 Docker: tailscale/tailscale 이미지

# 둘 다 같은 계정으로 로그인 → 자동 연결
# 카페/외부에서도 NAS 접근 가능
```

---

## Stage 2: N100 미니 PC 추가 ($130, 수익 $500+ 시)

### 추천 장비

| 모델 | 가격 | CPU | RAM | 저장 | 비고 |
|------|------|-----|-----|------|------|
| **Beelink EQ12** | ~$130 | N100 4코어 | 16GB | 500GB SSD | 가성비 최고 |
| Beelink S12 Pro | ~$160 | N100 | 16GB | 500GB | EQ12 업그레이드 |
| MINISFORUM UN100D | ~$180 | N100 | 16GB | 512GB | 더블 랜 |

### N100 용도

```
[MacBook Air M4] ←─ Syncthing ─→ [DS218+] ←─ Syncthing ─→ [N100 Mini PC]
       │                              │                          │
       └── 개발 주력                   └── 백업/저장              ├── GitHub Actions runner
                                                                  ├── Gradle remote cache
                                                                  └── Docker 테스트 환경
```

### N100 설정 (Ubuntu Server)

```bash
# GitHub Actions self-hosted runner
# → Actions 분 소모 0, macOS 10배 과금 해소 (Linux runner)
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.xxx/...
./config.sh --url https://github.com/sun941003/splitly --token YOUR_TOKEN

# Gradle remote build cache
docker run -d -p 5071:5071 gradle/build-cache-node:latest
# build.gradle.kts에 추가:
# buildCache { remote<HttpBuildCache> { url = uri("http://n100:5071/cache/") } }
```

### 비용 효과

| 항목 | 전 | 후 |
|------|-----|-----|
| GitHub Actions | 3000분/월 (macOS 10배 과금) | 무제한 (self-hosted) |
| 빌드 시간 | 매번 clean build | remote cache 30-50% 단축 |
| 전기 | - | ~$3/월 (10-15W) |
| 월 순비용 | $0 | -$3 전기 + Actions 절약 |

---

## Stage 3: Mac Mini M4 ($599+, 수익 $2K+ 시)

### Mac Mini가 필요한 이유

N100으로 할 수 **없는** 것:
- iOS 빌드 (Xcode, macOS 전용)
- iOS 시뮬레이터 Maestro 테스트
- Fastlane iOS 배포

### 추천 구성

| 모델 | 가격 | RAM | 저장 | 비고 |
|------|------|-----|------|------|
| **Mac Mini M4 (기본)** | $599 | 16GB | 256GB | 최소. 외장 SSD 필수 |
| **Mac Mini M4 (추천)** | $799 | 24GB | 512GB | Xcode + 시뮬 여유 |
| Mac Mini M4 Pro | $1,399 | 24GB | 512GB | 최고 성능 |

### Mac Mini 아키텍처

```
[MacBook Air M4] ←─ Syncthing ─→ [DS218+] ←─ Syncthing ─→ [Mac Mini M4]
       │                              │                          │
       └── 모바일 개발                 └── 백업/NAS              ├── macOS CI runner
                                                                  ├── Xcode Archive 자동화
                                                                  ├── Fastlane 배포
                                                                  ├── Maestro iOS 테스트
                                                                  ├── Gradle remote cache
                                                                  └── N100 역할 전부 흡수
```

### N100 → Mac Mini 마이그레이션

```bash
# 1. Docker 서비스 이전 (docker-compose.yml 그대로)
scp -r n100:~/docker-services/ macmini:~/docker-services/
ssh macmini "cd ~/docker-services && docker-compose up -d"

# 2. GitHub Actions runner 재등록
# N100 runner 삭제 → Mac Mini에 새 runner 등록
# macOS runner이므로 iOS 빌드도 가능!

# 3. Syncthing 폴더 재설정
# NAS Syncthing UI에서 N100 장치 제거 → Mac Mini 장치 추가

# 4. Tailscale 자동 합류
brew install tailscale && tailscale up
```

**마이그레이션 소요 시간: ~1시간**

---

## DS218+ 수명 & NAS 업그레이드 경로

### DS218+ 한계점

| 항목 | DS218+ | 문제 시점 |
|------|--------|----------|
| RAM | 2GB (비확장) | Docker 3개+ 시 |
| CPU | ARM RTD1296 | x86 이미지 불가 |
| 베이 | 2-bay | 저장 확장 한계 |
| 지원 | DSM 7.2까지 | ~2027-2028 예상 |

### 업그레이드 시점 판단

```
DS218+ 유지 조건:
  ✅ Docker 서비스 3개 이하
  ✅ 총 RAM 사용 < 1.5GB
  ✅ 파일 동기화 + 백업 용도

업그레이드 신호:
  ⚠️ Docker OOM 빈번
  ⚠️ Syncthing 동기화 지연
  ⚠️ 저장 공간 부족 (2-bay 한계)
```

### NAS 업그레이드 후보 (필요 시)

| 모델 | 가격 | RAM | 베이 | 비고 |
|------|------|-----|------|------|
| DS224+ | ~$300 | 2GB (32GB 확장) | 2-bay | DS218+ 직접 후속 |
| DS423+ | ~$500 | 2GB (32GB 확장) | 4-bay | RAID 확장성 |

**마이그레이션**: Synology → Synology는 HDD 이전만으로 완료 (DSM 설정 자동 복원)

---

## 장비별 역할 매트릭스

| 역할 | MacBook Air | DS218+ | N100 (Stage 2) | Mac Mini (Stage 3) |
|------|:-----------:|:------:|:--------------:|:------------------:|
| 코드 개발 | ✅ 주력 | | | |
| IDE (AS/Xcode) | ✅ | | | ✅ 원격 가능 |
| Android 빌드 | ✅ | | ✅ CI | ✅ CI |
| iOS 빌드 | ✅ | | ❌ | ✅ CI |
| 웹 빌드 | ✅ | | ✅ CI | ✅ CI |
| Gradle cache | | | ✅ 서버 | ✅ 서버 |
| 파일 동기화 허브 | | ✅ | | |
| 자동 백업 | | ✅ | | |
| Git 미러 | | ✅ Gitea | | |
| GitHub Runner | | | ✅ Linux | ✅ macOS |
| Maestro Android | ✅ 실기기 | | | |
| Maestro iOS | ✅ 시뮬 | | | ✅ 시뮬 |
| Fastlane 배포 | | | | ✅ |
| 항시 가동 | | ✅ | ✅ | ✅ |

---

## 보안 원칙

1. **Tailscale**: 장비 간 통신은 반드시 Tailscale VPN 경유
2. **git-crypt**: 시크릿은 암호화 상태로만 Git 저장
3. **NAS 접근**: DSM 2FA 활성화, SSH 키 인증만 허용
4. **포트 노출**: 외부 포트 개방 금지 (Tailscale로 대체)
5. **백업 3-2-1**: 3개 복사본, 2개 매체, 1개 오프사이트 (GitHub)

---

## 실행 순서

### 지금 즉시
- [x] sync.sh 생성
- [ ] DS218+ Docker 설정 (setup_nas_infra.sh)
- [ ] MacBook Syncthing 설치
- [ ] Tailscale 양쪽 설치
- [ ] Gitea GitHub 미러 설정

### 수익 $500+ 시
- [ ] N100 미니 PC 구매
- [ ] Ubuntu Server + Docker 설치
- [ ] GitHub Actions self-hosted runner
- [ ] Gradle remote build cache

### 수익 $2K+ 시
- [ ] Mac Mini M4 구매 (24GB/512GB 추천)
- [ ] N100 → Mac Mini 마이그레이션
- [ ] Fastlane iOS 자동 배포
- [ ] Xcode 시뮬레이터 Maestro 자동화

---

## 월간 운영 비용

| Stage | 전기 | 서비스 | 합계 |
|-------|------|--------|------|
| Stage 1 (현재) | ~$2 (NAS) | $0 | **$2/월** |
| Stage 2 (+N100) | ~$5 | $0 | **$5/월** |
| Stage 3 (+Mac Mini) | ~$8 | $0 | **$8/월** |

> 모든 서비스 self-hosted → 월간 SaaS 비용 $0
