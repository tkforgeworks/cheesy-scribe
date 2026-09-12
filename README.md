# cheesy-scribe

An app based on the tasting note book from [33Books](https://www.33books.com), specifically for cheese tastings. Track, record, and look back at your favorite cheeses of all time.

## Status

Pre-release. Flutter / Material 3, **Android only**, local-first (notes stay on the device). The plan and
ticket map are in [`docs/CHEESE-1-decomposition.md`](docs/CHEESE-1-decomposition.md); the design handoff is
in [`docs/design_handoff_cheesy_scribe/`](docs/design_handoff_cheesy_scribe/).

## Development

Flutter 3.47.2 (stable), Android SDK, JDK 17+. The application id is `com.tkforgeworks.cheesy_scribe`.

```sh
flutter pub get
flutter run                                          # on a connected device or a running emulator
dart format --output=none --set-exit-if-changed .    # the three checks CI runs, from the repo root
flutter analyze
flutter test
```

CI consumes the org's reusable [`ci-flutter.yml`](https://github.com/tkforgeworks/.github/blob/main/.github/workflows/ci-flutter.yml);
the check reports as `ci / ci`. Note that `dart format` checks every `.dart` file in the repo, which is why the
handoff's reference Dart files carry a `.txt` suffix.

## Contributing / branch policy

This repo follows the TK ForgeWorks branching model ([`docs/branching-and-release.md`](https://github.com/tkforgeworks/.github/blob/main/docs/branching-and-release.md)):

- `main` is the released state and only moves by merging a release PR.
- Work accumulates on the current release branch, `v0.1.0/main`.
- Topic branches are named `v0.1.0/CHEESE-N-short-topic` and PR into the release branch, never into `main`.
- Commit subjects are the changelog: `CHEESE-N: Imperative summary`, with `CHEESE-N: Fix ...` for bug fixes.

Both branches are protected by repository rulesets per [`docs/branch-protection-ruleset.md`](https://github.com/tkforgeworks/.github/blob/main/docs/branch-protection-ruleset.md): `main` is PR-only with no force-push, no deletion, and no bypass; `v*/main` blocks force-push and deletion. `main` also requires the `ci / ci` check to pass with the branch up to date.

Work is tracked in Jira project [CHEESE](https://tkforgeworks.atlassian.net/browse/CHEESE).

## Releasing

The org's tagless Flutter pipeline ([`release-flutter.yml`](https://github.com/tkforgeworks/.github/blob/main/.github/workflows/release-flutter.yml),
called by [`.github/workflows/release.yml`](.github/workflows/release.yml)). Every push to `main` or a `v*/main` branch runs
it and it decides for itself:

| `pubspec.yaml` version | on branch | result |
|---|---|---|
| `X.Y.Z-rc.N+B` | `vX.Y.Z/main` | prerelease `vX.Y.Z-rc.N` |
| `X.Y.Z+B` | `main` (via the release PR) | release `vX.Y.Z` |
| anything else, or the tag exists | — | no-op |

Version bumps are ordinary commits made by the bump helper (bash and PowerShell do the same thing):

```sh
scripts/release/bump-version.sh rc      # on v0.1.0/main: 0.1.0-rc.1+2, commit, push → CI publishes the prerelease
scripts/release/bump-version.sh final   # 0.1.0+3, commit, push, opens the release PR into main → merge cuts v0.1.0
```

The base version comes from the release-branch name; `+BUILD` (the Android `versionCode`) goes up on every bump.
The tag is created server-side when CI publishes, so nothing needs to bypass branch protection. Never hand-edit the
version or push tags. CI's jobs: check-release (the table above) → release notes (org `release-notes.yml`, one line
per `CHEESE-N:` commit subject, linked through the `JIRA_BASE_URL` repo variable) + `ci-flutter.yml` as the quality
gate → APK on `ubuntu-latest` → draft release, upload, publish.

The build script CI runs is the one you run locally; the artifact lands in `release/` (gitignored):

```sh
scripts/release/build-android.sh    # flutter build apk --release → release/cheesy-scribe-<v>-android.apk
```

- **Signing**: the APK is signed with the upload keystore named in `android/key.properties`. Both files are gitignored
  and live in 1Password; `scripts/release/new-android-keystore.sh` creates a fresh pair the first time (never
  regenerate one that has shipped — Android ties updates to the key). CI gets them from the repo secrets
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD` and `ANDROID_KEY_ALIAS`. Without `key.properties`,
  `flutter run --release` falls back to the debug key and the build script refuses.
- **Until the keystore exists** the pipeline runs in dry-run mode: `release.yml` passes `android-signing: optional`,
  and the published APK is debug-signed and named `…-android-debugsigned.apk`. It is not a distributable release,
  and because each CI runner generates its own debug key, it will not install *over* any other build (local or an
  earlier RC) — uninstall first, which wipes the journal. `v0.1.0-rc.1` was cut this way as a pipeline test. Once the
  secrets are set, remove that line; every RC after that updates in place.
- **Version**: `pubspec.yaml` `version: X.Y.Z[-rc.N]+BUILD`. `X.Y.Z[-rc.N]` names the tag and release; `+BUILD` is
  the Android `versionCode` and must go up on every APK that reaches a device — the bump helper does that.

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Image assets (logos, icons,
illustrations, screenshots) are **not** covered and are all rights reserved;
see [`NOTICE`](NOTICE).
