# Build configuration

The account features (0.3.0, CHEESE-11) talk to a Supabase project whose
URL, publishable key and Google Web OAuth client ID reach the app as
`--dart-define`s. The values are public by design (they ship inside the APK)
but are never committed.

- `dev.example.json` — the shape. Copy it to `dev.json` (gitignored) and
  fill in the values from the Supabase project settings and Google Cloud
  (1Password holds them), then run

  ```sh
  flutter run --dart-define-from-file=config/dev.json
  ```

- `release.json` (gitignored) — what the release pipeline writes from the
  `DART_DEFINES_JSON` repository secret before `scripts/release/
  build-android.sh` runs; the script passes it with
  `--dart-define-from-file` when it exists.

A build without either file still works: the app runs local-only and the
Account page says backup isn't available in this build. CI's test and
analyze runs never have one.
