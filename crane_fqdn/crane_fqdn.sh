#!/bin/bash

# Script: crane_fqdn_oneliner.sh
# Verwendung: ./crane_fqdn_oneliner.sh <image>

set -euo pipefail

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << EOF
Crane FQDN Extractor - One-Liner Methode

VERWENDUNG:
    $0 <image>

BEISPIELE:
    $0 nginx:latest
    $0 registry.rancher.com/rancher/rancher:v2.10.3
    $0 gcr.io/project/image:tag

Das Script verwendet exakt Ihre Methode:
crane -v pull <image> /tmp/image.tgz &> >(grep "\\-\\->\\|<\\-\\-" | grep -o -E 'https?://[^,]+' | tr ',' '\\n' | cut -d'/' -f1-3 | sort -u)

EOF
    exit 0
fi

IMAGE="$1"

# Prüfen ob crane installiert ist
if ! command -v crane &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} crane ist nicht installiert!"
    echo -e "${BLUE}[INFO]${NC} Installation: go install github.com/google/go-containerregistry/cmd/crane@latest"
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} Extrahiere FQDNs für Image: $IMAGE"

# Temporäre Datei für das Image
TEMP_FILE=$(mktemp /tmp/crane_image_XXXXXX.tgz)

echo -e "${BLUE}[INFO]${NC} Führe crane -v pull aus..."

# Ihre originale Methode - exakt übernommen
FQDNS=$(crane -v pull "$IMAGE" "$TEMP_FILE" 2>&1 | \
    grep "\-\->\|<\-\-" | \
    grep -o -E 'https?://[^,]+' | \
    tr ',' '\n' | \
    cut -d'/' -f1-3 | \
    sed 's|https\?://||' | \
    sort -u)

# Cleanup
rm -f "$TEMP_FILE"

# Ergebnisse anzeigen
if [[ -n "$FQDNS" ]]; then
    echo
    echo -e "${GREEN}[SUCCESS]${NC} Gefundene FQDNs:"
    echo "=========================="
    echo "$FQDNS"
    echo "=========================="
    
    FQDN_COUNT=$(echo "$FQDNS" | wc -l)
    echo -e "${BLUE}[INFO]${NC} Insgesamt $FQDN_COUNT unique FQDNs gefunden"
    
    echo
    echo -e "${BLUE}[INFO]${NC} Für Firewall-Regel (komma-getrennt):"
    echo "$FQDNS" | tr '\n' ',' | sed 's/,$//'
    echo
else
    echo -e "${RED}[ERROR]${NC} Keine FQDNs gefunden!"
    exit 1
fi