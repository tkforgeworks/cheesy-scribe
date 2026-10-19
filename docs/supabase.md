# Supabase: what the project holds and how it got there

Cheesy Scribe's backend (0.3.0, CHEESE-11) is one Supabase project on the
Pro plan in us-east-1, project ref `pqcpiggcmuspmbdhwiij`, created by Tim.
Everything in it is reproducible from this repo plus the dashboard
settings listed at the end.

## What lives in `supabase/`

| Path | Owner | Notes |
| --- | --- | --- |
| `migrations/2026101812…_forge_accounts.sql`, `…13…_forge_purge.sql`, `…14…_forge_web_deletion.sql` | forge_core | Copied by `dart run forge_core:sync_supabase` at the pinned tag; never edited here |
| `functions/forge-purge`, `forge-delete-request`, `forge-delete-confirm`, `_shared/mail.ts` | forge_core | Same |
| `templates/*.html`, `templates/README.md`, `templates/entries.sql` | forge_core | Mail templates (pasted into the dashboard) and the table template the app's tables follow |
| `forge_core.lock` | generated | Version and file hashes; `test/supabase_drift_test.dart` fails if a copy drifts |
| `migrations/20261018150000_cheesy_scribe_tables.sql` | this app | `notes` and `profiles` (CHEESE-60) |
| `smoke/cheesy_scribe_tables.sql` | this app | Exercises the app tables as a throwaway user and rolls back |

When the forge_core pin moves: `dart run forge_core:sync_supabase`, commit
the result, and deploy whatever changed (forge-core's
`docs/supabase-deploy.md` is the runbook).

## The app's tables (CHEESE-60)

Decisions are on the ticket. In short: a dedicated `notes` table, one row
per tasting note, and a `profiles` table, one row per user (`id =
user_id`) for `memberSince` and the recent searches; the display name is
`accounts.username`. Both follow forge_core's `entries` template shape so
`core.entries<T>(table: …)` reads them: client-supplied `id` and
`updated_at` (last write wins, device clocks trusted), `deleted_at`
tombstones with `data = {}`, a constant check-constrained `kind`.

`data` is `TastingNote.toJson()` without the derived search text, plus an
integer `schemaVersion` (starts at 1, migrated in Dart on read). The
server enforces: JSON object, at most 64 KB, integer `schemaVersion`
unless tombstone; `updated_at` at most a day in the future; `created_at`
stamped by the server and immutable along with `id` and `user_id`
(trigger). Row-level security scopes every row to its owner and to an
account not pending deletion (`forge_account_active()`), and the
`authenticated` role has DML grants only: no request through the API can
alter or drop a table. The smoke file proves each of these, including
that SQL-looking text in a note is stored verbatim.

## How migrations reach the project

No local Postgres and no CLI link on this box. Each migration is applied
through the Management API's query endpoint with Tim's project-scoped
access token (`~/.supabase/access-token`; scopes: Database + Migrations
read-write, Edge Functions + Secrets read-write, Project Settings read),
then recorded:

```sql
insert into supabase_migrations.schema_migrations (version, statements, name)
values ('<timestamp>', array[$sql$<file contents>$sql$], '<name>');
```

so a later `supabase db push` sees it as applied. Before applying, the
smoke file is run with the migration prepended inside one transaction that
rolls back; after applying, the smoke file alone, again rolled back.
Applied so far (all recorded): the three forge migrations (2026-10-18) and
`20261018150000_cheesy_scribe_tables` (2026-10-18).

Edge Functions deploy with `supabase functions deploy <name> --project-ref
pqcpiggcmuspmbdhwiij --use-api --no-verify-jwt` (no link needed); secrets
with `supabase secrets set … --project-ref …`. Both done for the three
forge functions; see forge-core's `docs/supabase-deploy.md` §3 for the
list. The CLI is installed at `~/.supabase/bin` and reads the same token.

## Dashboard-only settings (Tim)

- Authentication → Providers: Google on (Web client ID + secret), Email on
  with confirmation required, minimum length 8, leaked-password check on;
  "Allow manual linking" on.
- Authentication → SMTP: Resend (`smtp.resend.com`, sender
  `accounts@tkforgeworks.com`, name "Cheesy Scribe").
- Authentication → URL configuration: Site URL
  `https://tkforgeworks.com/privacy/cheesy-scribe/`; Redirect URLs
  `https://tkforgeworks.com/apps/cheesy-scribe/auth/` (the App Link,
  CHEESE-68, exactly as the app sends it, trailing slash included) and,
  until the legacy filter goes, `com.tkforgeworks.cheesyscribe://auth-callback`
  (the application id **without its underscore**: a URL scheme cannot
  contain one, see CHEESE-61).
- Authentication → Email templates: the files under `supabase/templates/`.

The project-scoped token lacks `project_admin_write`, so these cannot be
changed from here. Auth logs need `analytics_logs_read`, also absent;
Resend keeps every sent mail's body, which is how mail-link problems were
diagnosed.
