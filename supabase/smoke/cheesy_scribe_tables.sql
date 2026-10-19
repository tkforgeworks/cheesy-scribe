-- Smoke test for 20261018150000_cheesy_scribe_tables.sql and
-- 20261018160000_cheesy_scribe_keep_newer.sql. Run inside one
-- transaction that rolls back, with the migration prepended on a project
-- that does not have it yet, or alone afterwards:
--   { echo 'begin;'; cat supabase/smoke/cheesy_scribe_tables.sql; echo 'rollback;'; } | <run on the project>
-- Needs the forge_accounts migration (forge_account_active()).

insert into auth.users (id, instance_id, aud, role, email, encrypted_password, created_at, updated_at,
        confirmation_token, recovery_token, email_change_token_new, email_change, email_change_token_current,
        phone_change, phone_change_token, reauthentication_token, raw_app_meta_data, raw_user_meta_data, is_sso_user, is_anonymous)
values ('00000000-0000-4000-8000-0000000000c1', '00000000-0000-0000-0000-000000000000',
        'authenticated', 'authenticated', 'cheese1@example.com', '', now(), now(),
        '', '', '', '', '', '', '', '', '{}', '{}', false, false),
       ('00000000-0000-4000-8000-0000000000c2', '00000000-0000-0000-0000-000000000000',
        'authenticated', 'authenticated', 'cheese2@example.com', '', now(), now(),
        '', '', '', '', '', '', '', '', '{}', '{}', false, false);

select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-4000-8000-0000000000c1","role":"authenticated"}', true);
set local role authenticated;

-- Own note: insert, upsert newer, tombstone. created_at is the server's.
insert into public.notes (id, user_id, data, updated_at, created_at)
values ('20000000-0000-4000-8000-000000000001', auth.uid(),
        '{"schemaVersion":1,"cheeseName":"Comté"}', '2026-10-18T10:00:00Z', '1999-01-01T00:00:00Z');
insert into public.notes (id, user_id, data, updated_at)
values ('20000000-0000-4000-8000-000000000001', auth.uid(),
        '{"schemaVersion":1,"cheeseName":"Comté 24"}', '2026-10-18T11:00:00Z')
on conflict (id) do update set data = excluded.data, updated_at = excluded.updated_at, deleted_at = excluded.deleted_at;
do $$
declare r public.notes;
begin
  select * into r from public.notes where id = '20000000-0000-4000-8000-000000000001';
  if r.data->>'cheeseName' <> 'Comté 24' then raise exception 'upsert did not replace'; end if;
  if r.created_at < now() - interval '1 minute' then raise exception 'client created_at was accepted: %', r.created_at; end if;
  if r.kind <> 'tasting_note' then raise exception 'kind default missing'; end if;
end $$;
-- An older write never replaces a newer row (keep_newer trigger): the
-- upsert below carries 10:30, the row holds 11:00, so nothing changes.
insert into public.notes (id, user_id, data, updated_at)
values ('20000000-0000-4000-8000-000000000001', auth.uid(),
        '{"schemaVersion":1,"cheeseName":"Stale"}', '2026-10-18T10:30:00Z')
on conflict (id) do update set data = excluded.data, updated_at = excluded.updated_at, deleted_at = excluded.deleted_at;
do $$
begin
  if (select data->>'cheeseName' from public.notes where id = '20000000-0000-4000-8000-000000000001') <> 'Comté 24' then
    raise exception 'an older write replaced a newer row';
  end if;
end $$;
-- An older deletion loses the same way.
update public.notes set data = '{}', deleted_at = '2026-10-18T10:45:00Z', updated_at = '2026-10-18T10:45:00Z'
  where id = '20000000-0000-4000-8000-000000000001';
do $$
begin
  if (select deleted_at from public.notes where id = '20000000-0000-4000-8000-000000000001') is not null then
    raise exception 'an older deletion replaced a newer row';
  end if;
end $$;
-- id and user_id cannot be rewritten (the trigger keeps the old values).
update public.notes set user_id = '00000000-0000-4000-8000-0000000000c2', id = '20000000-0000-4000-8000-0000000000ff'
  where id = '20000000-0000-4000-8000-000000000001';
do $$
begin
  if not exists (select 1 from public.notes where id = '20000000-0000-4000-8000-000000000001' and user_id = auth.uid()) then
    raise exception 'identity columns were changed';
  end if;
end $$;
update public.notes set data = '{}', deleted_at = now(), updated_at = now()
  where id = '20000000-0000-4000-8000-000000000001';

-- SQL-looking text is just data.
insert into public.notes (id, user_id, data, updated_at)
values ('20000000-0000-4000-8000-000000000002', auth.uid(),
        '{"schemaVersion":1,"cheeseName":"Brie''); drop table public.notes; --","notes":"'' or 1=1"}', now());
do $$
begin
  if (select data->>'cheeseName' from public.notes where id = '20000000-0000-4000-8000-000000000002')
     <> 'Brie''); drop table public.notes; --' then
    raise exception 'payload text was altered';
  end if;
end $$;

-- Refused: another user's row, wrong kind, non-object, missing / non-integer
-- schemaVersion, oversized, far-future updated_at, tombstone with data.
do $$
begin
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-0000000000c2', '{"schemaVersion":1}', now());
    raise exception 'inserting for another user should fail';
  exception when insufficient_privilege then null; end;
  begin
    insert into public.notes (id, user_id, kind, data, updated_at)
    values ('20000000-0000-4000-8000-000000000004', auth.uid(), 'other', '{"schemaVersion":1}', now());
    raise exception 'wrong kind should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000005', auth.uid(), '[1,2,3]', now());
    raise exception 'non-object data should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000006', auth.uid(), '{"cheeseName":"x"}', now());
    raise exception 'missing schemaVersion should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000007', auth.uid(), '{"schemaVersion":"1"}', now());
    raise exception 'string schemaVersion should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000008', auth.uid(),
            jsonb_build_object('schemaVersion', 1, 'notes', repeat('x', 70000)), now());
    raise exception 'oversized data should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-000000000009', auth.uid(), '{"schemaVersion":1}', now() + interval '3 days');
    raise exception 'far-future updated_at should fail';
  exception when check_violation then null; end;
  begin
    insert into public.notes (id, user_id, data, updated_at, deleted_at)
    values ('20000000-0000-4000-8000-00000000000a', auth.uid(), '{"schemaVersion":1}', now(), now());
    raise exception 'tombstone with data should fail';
  exception when check_violation then null; end;
end $$;

-- No DDL through the API role.
do $$
begin
  begin
    execute 'drop table public.notes';
    raise exception 'authenticated must not be able to drop the table';
  exception when insufficient_privilege then null; end;
  begin
    execute 'alter table public.notes add column x int';
    raise exception 'authenticated must not be able to alter the table';
  exception when insufficient_privilege then null; end;
  begin
    execute 'truncate public.notes';
    raise exception 'authenticated must not be able to truncate the table';
  exception when insufficient_privilege then null; end;
end $$;

-- Profile: exactly one row, keyed by the user id.
insert into public.profiles (id, user_id, data, updated_at)
values (auth.uid(), auth.uid(), '{"schemaVersion":1,"memberSince":"2026-06-01","recentSearches":["blue"]}', now());
do $$
begin
  begin
    insert into public.profiles (id, user_id, data, updated_at)
    values ('20000000-0000-4000-8000-0000000000b1', auth.uid(), '{"schemaVersion":1}', now());
    raise exception 'a profile whose id is not the user id should fail';
  exception when check_violation then null; end;
  if (select count(*) from public.profiles) <> 1 then raise exception 'profile count %', (select count(*) from public.profiles); end if;
end $$;

-- Access ends the moment deletion is requested.
select public.request_account_deletion();
do $$
begin
  if (select count(*) from public.notes) <> 0 then raise exception 'notes still visible after deletion request'; end if;
  if (select count(*) from public.profiles) <> 0 then raise exception 'profile still visible after deletion request'; end if;
end $$;

reset role;
-- The other user sees nothing of the first.
select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-4000-8000-0000000000c2","role":"authenticated"}', true);
set local role authenticated;
do $$
begin
  if (select count(*) from public.notes) <> 0 then raise exception 'cross-user read'; end if;
end $$;
reset role;
