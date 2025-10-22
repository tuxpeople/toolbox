#!/usr/bin/env bash
# check-repo-checksum.sh
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <REPO_BASE_URL> <RPM_FILENAME>" >&2
  exit 1
fi

REPO="${1%/}"
RPM_FILE="$2"

# Tools prüfen
for t in curl gawk grep sed gunzip sha256sum sha1sum; do
  if ! command -v "$t" >/dev/null 2>&1; then
    echo "Fehlt: $t" >&2
    exit 2
  fi
done

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Repo: $REPO"
echo "Paket: $RPM_FILE"
echo

# 1) repomd.xml laden
curl -fsSL --retry 3 --retry-delay 1 --compressed \
  -H 'Cache-Control: no-cache' \
  -o "$TMPDIR/repomd.xml" \
  "$REPO/repodata/repomd.xml"

# 2) primary.xml.gz finden
PRIMARY_GZ_PATH="$(gawk '
  /<data[^>]*type="primary"/,/<\/data>/ {
    if (match($0, /href="([^"]+)"/, m)) { print m[1]; exit }
  }' "$TMPDIR/repomd.xml")"

if [[ -z "$PRIMARY_GZ_PATH" ]]; then
  echo "Konnte primary.xml.gz nicht finden." >&2
  exit 3
fi

# 3) primary.xml.gz laden & entpacken
curl -fsSL --retry 3 --retry-delay 1 --compressed \
  -H 'Cache-Control: no-cache' \
  -o "$TMPDIR/primary.xml.gz" \
  "$REPO/$PRIMARY_GZ_PATH"

gunzip -f "$TMPDIR/primary.xml.gz"
PRIMARY_XML="$TMPDIR/primary.xml"

# 4) erwartete Prüfsumme extrahieren
read -r EXPECTED_TYPE EXPECTED_SUM <<<"$(gawk -v file="$RPM_FILE" '
  BEGIN{ RS="</package>"; ORS=""; }
  {
    if ($0 ~ file) {
      if (match($0, /<checksum[^>]*type="([^"]+)"[^>]*>([0-9a-f]+)<\/checksum>/, m)) {
        printf "%s %s\n", m[1], m[2];
        exit
      }
    }
  }' "$PRIMARY_XML")"

if [[ -z "${EXPECTED_SUM:-}" ]]; then
  echo "Kein Eintrag für $RPM_FILE in primary.xml gefunden." >&2
  exit 4
fi

echo "Erwartete Prüfsumme ($EXPECTED_TYPE): $EXPECTED_SUM"

# 5) RPM laden & prüfen
curl -fsSL --retry 3 --retry-delay 1 --compressed \
  -H 'Cache-Control: no-cache' \
  -o "$TMPDIR/$RPM_FILE" \
  "$REPO/$RPM_FILE"

case "$EXPECTED_TYPE" in
  sha256) ACTUAL_SUM="$(sha256sum "$TMPDIR/$RPM_FILE" | gawk '{print $1}')" ;;
  sha1)   ACTUAL_SUM="$(sha1sum   "$TMPDIR/$RPM_FILE" | gawk '{print $1}')" ;;
  *)
    echo "Unbekannter Checksum-Typ: $EXPECTED_TYPE" >&2
    exit 5
    ;;
esac

echo "Gefundene Prüfsumme ($EXPECTED_TYPE): $ACTUAL_SUM"
echo

if [[ "$EXPECTED_SUM" == "$ACTUAL_SUM" ]]; then
  echo "✅ PASS – Prüfsummen stimmen überein."
else
  echo "❌ FAIL – Prüfsummen unterscheiden sich!"
fi

