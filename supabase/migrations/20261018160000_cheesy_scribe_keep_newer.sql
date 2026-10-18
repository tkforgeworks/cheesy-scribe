-- Last write wins on the server too (CHEESE-62). The app compares stamps
-- before pushing, but two phones can still race; a BEFORE UPDATE trigger
-- that drops any write older than the row's current updated_at makes the
-- rule hold regardless of who arrives first. Upserts (insert … on conflict
-- do update) and markDeleted both arrive as updates, so an older deletion
-- loses to a newer edit and an older edit loses to a newer deletion.

create or replace function public.cheesy_scribe_keep_newer()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at < old.updated_at then
    return null; -- skip: the row already holds something newer
  end if;
  return new;
end;
$$;

comment on function public.cheesy_scribe_keep_newer() is
  'cheesy-scribe: an update whose updated_at is older than the stored one is ignored (last write wins).';

drop trigger if exists notes_keep_newer on public.notes;
create trigger notes_keep_newer
  before update on public.notes
  for each row execute function public.cheesy_scribe_keep_newer();

drop trigger if exists profiles_keep_newer on public.profiles;
create trigger profiles_keep_newer
  before update on public.profiles
  for each row execute function public.cheesy_scribe_keep_newer();
