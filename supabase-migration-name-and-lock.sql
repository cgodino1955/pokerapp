-- Run this once in the Supabase SQL Editor. If you're setting up a brand
-- new project instead, just run supabase-schema.sql — it already includes
-- this.

-- Step 1: if a double-tap or duplicate tab ever created more than one
-- "open" (ended_at is null) session, close all but the most recently
-- started one. Safe to run even if you don't currently have duplicates.
update public.sessions
set ended_at = (extract(epoch from now()) * 1000)::bigint
where ended_at is null
  and id not in (
    select id from public.sessions
    where ended_at is null
    order by started_at desc
    limit 1
  );

-- Step 2: add the night name field.
alter table public.sessions add column label text;

-- Step 3: enforce at most one open session per user going forward.
create unique index one_active_session_per_user on public.sessions (user_id) where ended_at is null;
