#!/usr/bin/env bash
# Creates the Android upload keystore and android/key.properties, once. Bash
# twin of lazy-sleeper-app's new-android-keystore.ps1 (same shape: PKCS12,
# RSA 2048, 10000 days, a generated 32-character password that is written to
# key.properties and never printed).
#
# One keystore for the life of the app: Android ties updates to the signing
# key, so a lost keystore means a new app id. Both files are gitignored. After
# running this, put android/upload-keystore.jks and android/key.properties in
# 1Password, then set the three repo secrets the release pipeline reads (the
# script prints the commands).
#
# Usage: scripts/release/new-android-keystore.sh [alias]   (default: upload)
set -euo pipefail

alias="${1:-upload}"
dname="CN=Cheesy Scribe, O=TK ForgeWorks"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
keystore="$root/android/upload-keystore.jks"
props="$root/android/key.properties"

if [[ -e "$keystore" ]]; then
  echo "$keystore already exists. Not overwriting a signing key." >&2
  exit 1
fi
if [[ -e "$props" ]]; then
  echo "$props already exists. Move it aside first." >&2
  exit 1
fi
command -v keytool >/dev/null || { echo "keytool not on PATH (install a JDK)." >&2; exit 1; }

password="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"

keytool -genkeypair -v -keystore "$keystore" -storetype PKCS12 -keyalg RSA -keysize 2048 \
  -validity 10000 -alias "$alias" -dname "$dname" -storepass "$password" -keypass "$password"

umask 077
printf 'storePassword=%s\nkeyPassword=%s\nkeyAlias=%s\nstoreFile=../upload-keystore.jks\n' \
  "$password" "$password" "$alias" > "$props"

cat <<MSG

Keystore:   $keystore
Properties: $props  (holds the store/key password, alias '$alias'; mode 600)
Save both files in 1Password now; neither is in git.

Then wire the release pipeline:
  gh secret set ANDROID_KEYSTORE_BASE64 --body "\$(base64 -w0 android/upload-keystore.jks)"
  gh secret set ANDROID_KEYSTORE_PASSWORD --body "\$(sed -n 's/^storePassword=//p' android/key.properties)"
  gh secret set ANDROID_KEY_ALIAS --body "$alias"
and remove the 'android-signing: optional' line from .github/workflows/release.yml.
MSG
