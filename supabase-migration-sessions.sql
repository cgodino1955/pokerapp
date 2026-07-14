-- Run this once in the Supabase SQL Editor to add "night" (session) tracking
-- to an existing Poker Hand Tracker database that was set up before this
-- feature existed. If you're setting up a brand new project instead, just
-- run supabase-schema.sql — it already includes this.

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  started_at bigint not null,
  ended_at bigint,
  created_at timestamptz not null default now()
);

create index sessions_user_id_started_idx on public.sessions (user_id, started_at desc);

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

alter table public.hands add column session_id uuid references public.sessions(id) on delete set null;
create index hands_session_id_idx on public.hands (session_id);
