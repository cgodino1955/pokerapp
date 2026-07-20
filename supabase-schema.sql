-- Run this once in the Supabase SQL Editor (Project > SQL Editor > New query)
-- to set up the table Poker Hand Tracker stores hands in.

create extension if not exists pgcrypto;

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  started_at bigint not null,
  ended_at bigint,
  label text,
  starting_players integer,
  players_remaining integer,
  created_at timestamptz not null default now()
);

create index sessions_user_id_started_idx on public.sessions (user_id, started_at desc);

-- At most one open (ended_at is null) session per user — prevents a
-- double-tap on "Start Night" or two open tabs from silently creating two
-- "active" nights at once.
create unique index one_active_session_per_user on public.sessions (user_id) where ended_at is null;

alter table public.sessions enable row level security;

create policy "select_own_sessions"
  on public.sessions for select
  using (auth.uid() = user_id);

create policy "insert_own_sessions"
  on public.sessions for insert
  with check (auth.uid() = user_id);

create policy "update_own_sessions"
  on public.sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create table public.hands (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  session_id uuid references public.sessions(id) on delete set null,
  ts bigint not null,
  position text,
  sb text,
  bb text,
  hole jsonb,
  preflop jsonb,
  flop jsonb,
  turn jsonb,
  river jsonb,
  result text,
  showdown boolean,
  opp_hand jsonb,
  players_remaining integer,
  notes text,
  created_at timestamptz not null default now()
);

create index hands_user_id_ts_idx on public.hands (user_id, ts desc);
create index hands_session_id_idx on public.hands (session_id);

-- Row-level security: each signed-in user can only see, insert, and delete
-- their own hands. This is what makes "private per person" actually private
-- — it's enforced by Postgres itself, not just by app-level filtering.
alter table public.hands enable row level security;

create policy "select_own_hands"
  on public.hands for select
  using (auth.uid() = user_id);

create policy "insert_own_hands"
  on public.hands for insert
  with check (auth.uid() = user_id);

create policy "delete_own_hands"
  on public.hands for delete
  using (auth.uid() = user_id);
