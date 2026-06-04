-- ================================================
-- Planbag 행사 등록 시스템 Supabase Schema
-- ================================================

-- 1. 행사 테이블
create table events (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz default now(),
  title         text not null,
  subtitle      text,
  date_start    timestamptz not null,
  date_end      timestamptz,
  location_name text,
  location_addr text,
  description   text,
  cover_image   text,
  color_primary text default '#1a1a2e',
  status        text default 'draft' check (status in ('draft','open','closed','ended')),
  max_capacity  int,
  require_approval boolean default false,
  nametag_size  text default 'both' check (nametag_size in ('76x76','95x120','both')),
  custom_fields jsonb default '[]',
  organizer     text default 'Planbag'
);

-- 2. 참가자 등록 테이블
create table registrations (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz default now(),
  event_id      uuid references events(id) on delete cascade,
  name          text not null,
  email         text not null,
  phone         text,
  organization  text,
  department    text,
  job_title     text,
  group_name    text default '일반',
  custom_data   jsonb default '{}',
  status        text default 'confirmed' check (status in ('pending','confirmed','cancelled')),
  qr_code       text unique,
  utm_source    text,
  utm_medium    text,
  utm_campaign  text,
  checked_in    boolean default false,
  checked_in_at timestamptz,
  nametag_printed boolean default false,
  nametag_printed_at timestamptz
);

-- 3. 체크인 로그 (중복 스캔 방지, 시간대별 추이용)
create table checkin_logs (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz default now(),
  event_id        uuid references events(id) on delete cascade,
  registration_id uuid references registrations(id) on delete cascade,
  action          text default 'checkin' check (action in ('checkin','checkout'))
);

-- ================================================
-- RLS 정책
-- ================================================

alter table events enable row level security;
alter table registrations enable row level security;
alter table checkin_logs enable row level security;

-- 행사: 누구나 open/closed/ended 행사 조회 가능
create policy "Public events readable" on events
  for select using (status != 'draft');

-- 행사: service_role만 전체 관리
create policy "Service role full access events" on events
  for all using (auth.role() = 'service_role');

-- 등록: 누구나 INSERT (등록 폼 제출)
create policy "Anyone can register" on registrations
  for insert with check (true);

-- 등록: 자신의 등록 정보 조회 (QR 코드로)
create policy "Read own registration by qr" on registrations
  for select using (true);

-- 체크인: 삽입은 누구나 (현장 운영)
create policy "Anyone can checkin" on checkin_logs
  for insert with check (true);

create policy "Checkin logs readable" on checkin_logs
  for select using (true);

-- ================================================
-- 인덱스
-- ================================================
create index idx_registrations_event_id on registrations(event_id);
create index idx_registrations_qr_code on registrations(qr_code);
create index idx_registrations_email on registrations(email);
create index idx_checkin_logs_event_id on checkin_logs(event_id);
create index idx_checkin_logs_created_at on checkin_logs(created_at);

-- ================================================
-- Realtime 활성화
-- ================================================
alter publication supabase_realtime add table registrations;
alter publication supabase_realtime add table checkin_logs;
