#!/usr/bin/env bash
# Builds the Android release APK into release/. This is the script CI runs on
# ubuntu-latest (org release-flutter.yml); it is the same one you run locally.
#
# flutter build apk --release, signed with the upload keystore named in
# android/key.properties (create one with new-android-keystore.sh, or let
# release-flutter.yml write it from the ANDROID_KEYSTORE_* secrets). Without
# key.properties Gradle falls back to the debug key, and a debug-signed APK is
# not a release — so the script refuses, unless ANDROID_SIGNING=debug is set.
# release-flutter.yml sets that only when the caller opted into
# `android-signing: optional` (pipeline dry run before the keystore exists);
# the artifact is then named "-debugsigned" so nobody mistakes it.
#
# The version and build number come from pubspec.yaml (`version:
# X.Y.Z[-rc.N]+BUILD`; BUILD is the Android versionCode and must go up on
# every APK that reaches a device — bump-version.sh does that).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

suffix=""
if [[ ! -f android/key.properties ]]; then
  if [[ "${ANDROID_SIGNING:-}" == "debug" ]]; then
    echo "WARNING: android/key.properties is missing and ANDROID_SIGNING=debug — building a debug-signed APK (dry run, not for distribution)." >&2
    suffix="-debugsigned"
  else
    echo "android/key.properties is missing. Run scripts/release/new-android-keystore.sh (or restore the keystore + key.properties from 1Password). Set ANDROID_SIGNING=debug to build a debug-signed APK on purpose." >&2
    exit 1
  fi
fi

full="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | tr -d '[:space:]')"
app_version="${full%%+*}"
echo "Cheesy Scribe $full → APK version $app_version"

flutter build apk --release

mkdir -p release
apk="release/cheesy-scribe-$app_version-android$suffix.apk"
cp build/app/outputs/flutter-apk/app-release.apk "$apk"
ls -l "$apk"
