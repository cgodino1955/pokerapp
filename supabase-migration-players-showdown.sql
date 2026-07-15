-- Run this once in the Supabase SQL Editor to add tournament player-count
-- tracking and opponent's-hand-at-showdown to an existing database. If
-- you're setting up a brand new project instead, just run
-- supabase-schema.sql — it already includes this.

alter table public.sessions add column starting_players integer;
alter table public.sessions add column players_remaining integer;

alter table public.hands add column opp_hand jsonb;
alter table public.hands add column players_remaining integer;
