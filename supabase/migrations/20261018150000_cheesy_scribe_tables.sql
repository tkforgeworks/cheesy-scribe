-- Cheesy Scribe's own tables (CHEESE-60), after the forge_accounts
-- migration. Two dedicated tables in the shape of forge_core's entries
-- template (supabase/templates/entries.sql): the client supplies id and
-- updated_at so a phone can write offline and push later with the newest
-- change winning; deleted_at is a tombstone kept so other devices learn
-- about the deletion. Decisions recorded on CHEESE-60.
--
--   notes     one row per tasting note; data = TastingNote.toJson() minus
--             the derived search text, plus an integer schemaVersion
--   profiles  one row per user (id = user_id): memberSince and the recent
--             searches; display name lives in accounts.username
--
-- The kind column is constant per table: forge_core's repository filters
-- on it, and keeping it means the same code reads both tables.
--
-- Protections, beyond row-level security scoping every row to its owner:
-- data must be a JSON object of at most 64 KB that carries an integer
-- schemaVersion (a tombstone is exactly {}); updated_at may not be more
-- than a day in the future; created_at is stamped by the server and, like
-- id and user_id, cannot be changed afterwards. The authenticated role is
-- granted DML only, never DDL, so nothing a client sends through the API
-- can alter or drop a table (the smoke file proves it).

create or replace function public.cheesy_scribe_payload_ok(data jsonb, deleted_at timestamptz)
returns boolean
language sql
immutable
as $$
  select jsonb_typeof(data) = 'object'
     and pg_column_size(data) <= 65536
     and (
       (deleted_at is not null and data = '{}'::jsonb)
       -- coalesce: a missing key makes jsonb_typeof null, and a null check
       -- result would pass the constraint.
       or (deleted_at is null
           and coalesce(jsonb_typeof(data -> 'schemaVersion'), '') = 'number'
           and coalesce(data ->> 'schemaVersion', '') ~ '^[0-9]+$')
     );
$$;

comment on function public.cheesy_scribe_payload_ok(jsonb, timestamptz) is
  'cheesy-scribe: a live row carries a JSON object <= 64 KB with an integer schemaVersion; a tombstone is {}.';

-- Server-stamped, immutable identity columns.
create or replace function public.cheesy_scribe_guard_row()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := now();
  else
    new.id := old.id;
    new.user_id := old.user_id;
    new.created_at := old.created_at;
  end if;
  return new;
end;
$$;

-- notes --------------------------------------------------------------------

create table if not exists public.notes (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null default 'tasting_note'
    constraint notes_kind check (kind = 'tasting_note'),
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null
    constraint notes_updated_at_sane check (updated_at <= now() + interval '1 day'),
  deleted_at timestamptz,
  constraint notes_payload_ok check (public.cheesy_scribe_payload_ok(data, deleted_at))
);

comment on table public.notes is
  'cheesy-scribe: one tasting note per row; client-supplied id and updated_at, tombstones kept.';

create index if not exists notes_user_updated on public.notes (user_id, updated_at, id);
create index if not exists notes_user_kind on public.notes (user_id, kind);

drop trigger if exists notes_guard_row on public.notes;
create trigger notes_guard_row
  before insert or update on public.notes
  for each row execute function public.cheesy_scribe_guard_row();

alter table public.notes enable row level security;

drop policy if exists "notes: own rows" on public.notes;
create policy "notes: own rows"
  on public.notes for all
  to authenticated
  using ((select auth.uid()) = user_id and public.forge_account_active())
  with check ((select auth.uid()) = user_id and public.forge_account_active());

revoke all on public.notes from anon, authenticated;
grant select, insert, update, delete on public.notes to authenticated;

-- profiles -----------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null default 'profile'
    constraint profiles_kind check (kind = 'profile'),
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null
    constraint profiles_updated_at_sane check (updated_at <= now() + interval '1 day'),
  deleted_at timestamptz,
  constraint profiles_one_per_user check (id = user_id),
  constraint profiles_payload_ok check (public.cheesy_scribe_payload_ok(data, deleted_at))
);

comment on table public.profiles is
  'cheesy-scribe: one row per user (id = user_id) for memberSince and recent searches.';

create index if not exists profiles_user_updated on public.profiles (user_id, updated_at, id);

drop trigger if exists profiles_guard_row on public.profiles;
create trigger profiles_guard_row
  before insert or update on public.profiles
  for each row execute function public.cheesy_scribe_guard_row();

alter table public.profiles enable row level security;

drop policy if exists "profiles: own row" on public.profiles;
create policy "profiles: own row"
  on public.profiles for all
  to authenticated
  using ((select auth.uid()) = user_id and public.forge_account_active())
  with check ((select auth.uid()) = user_id and public.forge_account_active());

revoke all on public.profiles from anon, authenticated;
grant select, insert, update, delete on public.profiles to authenticated;
