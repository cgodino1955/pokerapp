-- Run this once in the Supabase SQL Editor (Project > SQL Editor > New query)
-- to set up the table Poker Hand Tracker stores hands in.

create extension if not exists pgcrypto;

create table public.hands (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
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
  notes text,
  created_at timestamptz not null default now()
);

create index hands_user_id_ts_idx on public.hands (user_id, ts desc);

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
