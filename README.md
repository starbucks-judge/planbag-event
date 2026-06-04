# Planbag 행사 등록 시스템 — 설치 가이드

## 파일 구성

| 파일 | 역할 | 접근자 |
|---|---|---|
| `index.html` | 관리자 메인 — 행사 목록 + 생성 | 관리자 (PC) |
| `register.html?id=<event_id>` | 참가자 등록 폼 | 참가자 (모바일) |
| `checkin.html?id=<event_id>` | QR 체크인 + 수동 검색 | 현장 스태프 |
| `nametag.html?id=<event_id>` | 명찰 출력 (76mm / 95mm) | 현장 스태프 |
| `dashboard.html?id=<event_id>` | 참가자 명단 + 통계 + CSV | 관리자 |

---

## 1단계 — Supabase 프로젝트 설정

1. [supabase.com](https://supabase.com) 접속 → 새 프로젝트 생성
2. SQL Editor에서 `supabase_schema.sql` 전체 실행
3. Settings → API 에서:
   - **Project URL** 복사 → `SUPABASE_URL`
   - **anon public key** 복사 → `SUPABASE_ANON_KEY`
   - ⚠️ service_role key는 절대 파일에 넣지 말 것

---

## 2단계 — 키 입력

5개 파일에서 아래 두 줄을 실제 값으로 교체:

```js
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

**파일 목록**: index.html, register.html, checkin.html, nametag.html, dashboard.html

---

## 3단계 — GitHub Pages 배포

```bash
# GitHub에 새 저장소 생성 (예: planbag-event)
git init
git add .
git commit -m "init: planbag event system"
git remote add origin https://github.com/starbucks-judge/planbag-event.git
git push -u origin main
```

GitHub 저장소 → Settings → Pages → main 브랜치 루트 선택 → Save

배포 URL 예시: `https://starbucks-judge.github.io/planbag-event/`

---

## 4단계 — Supabase RLS 설정 확인

`supabase_schema.sql`에 포함된 RLS 정책이 적용되었는지 확인:
- Authentication → Policies에서 각 테이블별 policy 확인
- `supabase_realtime` publication에 `registrations`, `checkin_logs` 추가됐는지 확인

---

## 운영 체크리스트

### 행사 생성 후
- [ ] index.html에서 행사 생성
- [ ] 등록 페이지 링크 복사 → 홍보 자료에 삽입
- [ ] 상태를 "접수 중"으로 변경

### 행사 당일
- [ ] checkin.html을 현장 스태프 기기에 열기
- [ ] nametag.html을 명찰 출력 PC에 열기
- [ ] 라벨 프린터 연결 확인 (76×76 또는 95×120 라벨지)

### 행사 후
- [ ] dashboard.html에서 CSV 내보내기
- [ ] 통계 스크린샷 클라이언트 보고서 첨부

---

## 명찰 출력 팁

### 76×76mm (실속형)
- 라벨지: 76×76mm 규격 (이미지 스티커 라벨지)
- 프린터: 일반 레이저/잉크젯 가능

### 95×120mm (고급형)
- 라벨지: A6 크기 명찰 용지
- 명찰홀더: 가로형 명찰케이스 + 목걸이줄

### 인쇄 시 주의
- 브라우저 인쇄 → 여백 "없음" 설정
- 크기: "실제 크기" 또는 "100%"
- 머리글/바닥글 끄기

---

## 향후 추가 예정 (Phase 2)
- 카카오 알림톡 발송
- 실시간 Q&A / 투표 / 경품추첨
- 참가자 CRM (리드 점수)
- 스탬프투어
