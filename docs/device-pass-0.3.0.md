# Device pass, 0.3.0 (CHEESE-67)

Tim runs no debug builds on his phone, so the pass ran across the release
candidates as each ticket landed, on his Pixel against the production
Supabase project (`pqcpiggcmuspmbdhwiij`). The RC named is the first build
on which the item passed; defects found on the way got their fix in the
next RC and are listed under it.

| Item | Result |
| --- | --- |
| Google sign-in | rc.1 |
| Email sign-up + confirmation mail | rc.1 created the account; the link reached the app on rc.3 (rc.1: scheme underscore sent links to the Site URL; rc.2: "no routes for location") |
| Forgot password → set a new password | rc.3; rc.4 fixed leaving set-password without saving (it had left the user signed in); unknown address reports success by design, conditional copy since rc.4 |
| Link Google to the email account; username; add a password | shipped in rc.7 (CHEESE-64), no defect reported on rc.7–rc.11 |
| Two devices, one account: create / edit / delete, Sync now | rc.5 (two accounts and the signed-out → account attach offer as well) |
| Same-note edit race across two devices | 2026-10-19 on two devices, no issue; `test/data/sync_service_test.dart` keeps it covered |
| Sign out: pushes, warns about unpushed changes, removes the account's notes, keeps signed-out notes | rc.5 (the ownership model replaced "keep notes + erase option", CHEESE-62) |
| Backup status row + Sync now in Settings and Account | rc.6 |
| In-app deletion → purge seen in the dashboard | rc.7 |
| Web deletion request + confirmation mail → purge | rc.7/rc.8 (first mail landed in spam once; DMARC, DKIM and SPF verified fine) |
| Forced sign-out when the account was deleted elsewhere | rc.8 (rc.7 left the phone signed in) |
| Mail links open the app directly | rc.9 App Link verified but Gmail kept GoTrue's 303 body as a tab; rc.10 token links, nothing left behind; rc.11 greets the verified link and an expired or reused one |
| Play Console: deletion URL, Data safety, reviewer account; Google Cloud consent screen published | 2026-10-18 (Tim) |

Not in this pass: the closed track stays on 0.2.0 for a two-week usability
review (CHEESE-50); 0.3.0 reaches it by hand later.
