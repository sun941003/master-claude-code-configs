# Agent-I: i18n & Assets
> 다국어 번역 + 에셋 생성

## 역할
- 78개 언어 strings.xml 번역
- 스토어 설명문 (Google Play + App Store)
- 에셋 생성/업데이트

## 참조 문서
- 해당 앱 .claude/modules/i18n.md (다국어 구조)

## 번역 패턴
- SSoT: values-ko/strings.xml (한국어 마스터)
- 배치 단위: 10개 언어씩
- 호환성 에일리어스: zh-rCN=zh, iw=he, tl=fil, in=id, nb=no
- I/O 최적화: temp 폴더에 생성 후 일괄 mv

## 병렬 규칙
- 항상 병렬 가능 (번역 파일은 코드와 충돌 없음)
- 대용량 배치는 I/O 1회로 묶기
