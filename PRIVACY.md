# Cheesy Scribe data inventory

What Cheesy Scribe collects, why, and how each store form wants it declared.
Update this file **before** any new SDK or field ships, and keep the privacy
policy (`https://tkforgeworks.com/privacy/cheesy-scribe/`) and the Play Data
safety form in step with it. Rows marked *forge_core* come with the shared
packages and are the same in every tkforgeworks app; Cheesy Scribe's own
rows follow them. Started from forge-core's `docs/privacy/PRIVACY.template.md`
(CHEESE-66, 2026-10-18).

Cheesy Scribe is local-first: notes live on the phone and the app works
without an account. Signing in is optional and only turns on backup.

## Accounts and sync (forge_core)

Collected only once the user signs in. Without an account nothing leaves
the device except what the feedback form sends on Send.

| Data | Purpose | Google Play Data safety | Apple privacy label (when iOS ships) | Retained |
| --- | --- | --- | --- | --- |
| Email address | Account identity; sign-in, confirmation and reset mail | Personal info → Email address | Contact Info → Email Address | Until the account is deleted |
| Username (optional, user-entered) | Display on the account page | Personal info → Name | Contact Info → Name | Until the account is deleted |
| Account ID (Supabase user id) | Authentication, linking data to the account | Personal info → User IDs | Identifiers → User ID | Until the account is deleted |
| Google account identity (if used or linked) | Sign-in | Personal info → User IDs | Identifiers → User ID | Until unlinked or deleted |
| Tasting notes (the app's entries) | App functionality: backup and sync between the user's devices | App activity → Other user-generated content | User Content → Other User Content | Until deleted in the app or with the account |

Declared for every row: **linked to the user**, **not used for tracking**,
**encrypted in transit**, **deletable on request** (in-app from Account, and
at `https://tkforgeworks.com/privacy/cheesy-scribe/delete-account/`).
Processors: [Supabase](https://supabase.com/privacy) (database and
authentication, Pro plan, hosted in the United States, us-east-1),
[Resend](https://resend.com/legal/privacy-policy) (sign-in and deletion
emails), Google (Sign in with Google, when chosen). Deleted data is purged
within a few minutes, and in any case within 24 hours: the purge runs at
once and a job retries every 15 minutes. Nothing is kept, anonymised or
otherwise.

## Feedback relay

| Data | Purpose | Google Play Data safety | Retained |
| --- | --- | --- | --- |
| Feedback topic, rating, comments; reply email if given; app version, Android version, device model | Support | Personal info → Other info (email if given); App info and performance → Other | In the support inbox while useful; deleted on request |

Sent only when the user taps Send (CHEESE-51); relayed by a Cloudflare Pages
Function at tkforgeworks.com to the support inbox through Resend. Not
linked to the account.

## Cheesy Scribe's own rows

| Data | Purpose | Google Play Data safety | Retained |
| --- | --- | --- | --- |
| A tasting note's fields: cheese name, maker, origin, price and unit, milk, rind, texture, rating, flavor scores, free-text notes, verdict, tasting date, chosen style, change time | The note itself (`TastingNote.toJson()` plus a `schemaVersion`), backed up only for a signed-in user who owns the note | App activity → Other user-generated content | Until deleted in the app or with the account |
| Profile row: "member since" date and the recent search terms | Keeps the Account page and the search box the same across the user's phones | App activity → Other user-generated content (search history) | Until the account is deleted |

Notes made while signed out belong to the phone and are uploaded only when
the user chooses to add them to the account. Theme and units are per device
and never leave the phone. The derived search haystack is rebuilt locally
and never uploaded.

## Not collected

No analytics, advertising, crash-reporting or tracking SDKs. No location,
contacts, photos, or device identifiers beyond what Android itself reports
to Google Play. The feedback form's device model and OS version are sent
only with a feedback message.

## Store compliance checklist (before any build with sign-in reaches testers)

- [x] Google and email/password sign-in on Android (CHEESE-61; Apple when an iOS app exists)
- [x] In-app account deletion in the same build as sign-in (CHEESE-65, `v0.3.0-rc.7`)
- [x] Deletion page and form live at `tkforgeworks.com/privacy/cheesy-scribe/delete-account/` (TKFW-83, website PR #28); URL entered in Play Console (App content → Account deletion) and in Data safety (Tim, 2026-10-18)
- [ ] Privacy policy live at `tkforgeworks.com/privacy/cheesy-scribe/`, naming Supabase and its region, Resend, the purge window and both deletion paths (TKFW-83; merge with the 0.3.0 release)
- [x] This inventory current
- [x] Data safety form re-submitted (Tim, Console, 2026-10-18)
- [x] Play App access: a reviewer account (an email/password test account on the real project, no 2FA) with instructions (Tim, Console, 2026-10-18)
- [x] Google Cloud consent screen flipped from Testing to In production (Tim, 2026-10-18)
- [x] Supabase Auth email templates, SMTP and rate limits set; Resend sender verified (2026-10-18)
- [x] Server functions never log `data`; Edge Function logs carry ids only (forge-core)
