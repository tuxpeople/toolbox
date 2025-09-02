# check-images - Container Image Availability Checker

Prüft die Verfügbarkeit von Container-Images in verschiedenen Container-Registries durch API-Aufrufe und gibt den Status jedes Images aus.

## 🎯 Zweck

Das `check-images` Tool verifiziert automatisch ob Container-Images in verschiedenen Registries verfügbar sind, ohne sie herunterladen zu müssen. Es unterstützt die wichtigsten öffentlichen und privaten Container-Registries und kann sowohl einzelne Images als auch grosse Listen von Images effizient prüfen. Besonders nützlich für CI/CD-Pipelines, Dependency-Checks und Container-Inventarisierung.

## 📋 Voraussetzungen

- **curl** - Für HTTP-Requests zu Registry-APIs
- **Bash 4.0+** - Für erweiterte Array-Funktionen
- **Internetverbindung** - Zugriff zu Container-Registries
- **Optional: Authentifizierung** - Personal Access Tokens für private Images

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/check-images

# Script ausführbar machen (falls noch nicht geschehen)
chmod +x check-images

# Zu PATH hinzufügen (optional)
sudo ln -s "$(pwd)/check-images" /usr/local/bin/check-images
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
check-images [OPTIONEN] [IMAGE_FILE]
```

### Parameter

| Option | Lang-Form | Beschreibung | Erforderlich |
|--------|-----------|--------------|--------------|
| `-f` | `--file FILE` | Datei mit Image-Namen | ❌* |
| `-i` | `--image IMAGE` | Einzelnes Image prüfen | ❌* |
| `-o` | `--output FORMAT` | Output-Format (text/json/csv) | ❌ |
| `-t` | `--timeout SECONDS` | HTTP-Timeout in Sekunden | ❌ |
| | `--github-pat TOKEN` | GitHub Personal Access Token | ❌ |
| `-v` | `--verbose` | Detaillierte Ausgabe | ❌ |
| `-n` | `--dry-run` | Nur anzeigen was gemacht würde | ❌ |
| | `--force` | Überschreibe ohne Nachfrage | ❌ |
| `-h` | `--help` | Hilfe anzeigen | ❌ |

*Entweder `--file` oder `--image` ist erforderlich

### Unterstützte Registries

| Registry | Beispiel | Authentifizierung |
|----------|----------|-------------------|
| Docker Hub | `nginx:latest`, `alpine:3.18` | Keine für öffentliche Images |
| Docker Hub (User) | `username/image:tag` | Keine für öffentliche Images |
| GitHub Container Registry | `ghcr.io/owner/repo:tag` | GitHub PAT für private |
| Red Hat Quay | `quay.io/prometheus/prometheus:latest` | Token für private |
| Google Container Registry | `gcr.io/project/image:tag` | Service Account für private |
| Kubernetes Registry | `registry.k8s.io/coredns/coredns:v1.10.1` | Keine |
| Amazon ECR Public | `public.ecr.aws/lambda/python:3.9` | Keine für öffentliche |

### Beispiele

```bash
# Einzelnes Image prüfen
check-images --image nginx:latest

# Mehrere Images aus Datei
echo "nginx:latest" > images.txt
echo "alpine:3.18" >> images.txt
echo "ubuntu:22.04" >> images.txt
check-images --file images.txt

# Mit verschiedenen Registries
check-images --image ghcr.io/actions/runner:latest
check-images --image quay.io/prometheus/prometheus:latest
check-images --image registry.k8s.io/coredns/coredns:v1.10.1

# Private GitHub Container Registry Images
export GITHUB_PAT="ghp_xxxxxxxxxxxxxxxxxxxx"
check-images --image ghcr.io/myorg/private-app:latest

# JSON Output für weitere Verarbeitung
check-images --file images.txt --output json > results.json

# CSV Output für Spreadsheet-Import
check-images --file images.txt --output csv > results.csv

# Verbose-Modus für Debugging
check-images --file images.txt --verbose

# Custom Timeout für langsame Registries
check-images --file images.txt --timeout 30

# Dry-Run um zu sehen was geprüft würde
check-images --file images.txt --dry-run --verbose
```

## 📄 Ausgabe-Beispiel

### Text-Format (Standard)
```bash
$ check-images --file images.txt

[INFO] check-images - Container Image Availability Checker
[INFO] Verarbeite Images aus Datei: images.txt
nginx:latest -> ✅ exists
alpine:3.18 -> ✅ exists
ubuntu:22.04 -> ✅ exists
ghcr.io/actions/runner:latest -> ✅ exists
ghcr.io/private/app:latest -> 🔒 requires authentication
nonexistent/image:tag -> ❌ not found
quay.io/prometheus/prometheus:latest -> ✅ exists
[INFO] Verarbeitung abgeschlossen!

📊 Statistiken:
   📦 Gesamt geprüft: 7
   ✅ Gefunden: 5
   ❌ Nicht gefunden: 1
   🔒 Authentifizierung erforderlich: 1
   ⚠️ Fehler: 0
   ⏭️ Übersprungen: 0

[SUCCESS] Alle Images erfolgreich geprüft!
```

### JSON-Format
```bash
$ check-images --file images.txt --output json

[
  {"image":"nginx:latest","status":"found","http_code":200},
  {"image":"alpine:3.18","status":"found","http_code":200},
  {"image":"ubuntu:22.04","status":"found","http_code":200},
  {"image":"ghcr.io/private/app:latest","status":"auth_required","http_code":401},
  {"image":"nonexistent/image:tag","status":"not_found","http_code":404}
]
```

### CSV-Format
```bash
$ check-images --file images.txt --output csv

image,status,http_code
nginx:latest,found,200
alpine:3.18,found,200
ubuntu:22.04,found,200
ghcr.io/private/app:latest,auth_required,401
nonexistent/image:tag,not_found,404
```

### Verbose-Ausgabe
```bash
$ check-images --image nginx:latest --verbose

[VERBOSE] Prüfe Image: nginx:latest
[VERBOSE]   Registry: docker.io
[VERBOSE]   Namespace: library
[VERBOSE]   Image: nginx
[VERBOSE]   Tag: latest
[VERBOSE]   API-URL: https://registry.hub.docker.com/v2/repositories/library/nginx/tags
nginx:latest -> ✅ exists
```

## 🔧 Funktionsweise

### Image-Parsing
Das Tool analysiert Image-Namen und extrahiert Registry, Namespace und Tag:

```bash
# Verschiedene Image-Formate
nginx:latest                    # docker.io/library/nginx:latest
nginx                          # docker.io/library/nginx:latest (Tag: latest)
username/app:v1.2.3           # docker.io/username/app:v1.2.3
ghcr.io/owner/repo:tag        # ghcr.io/owner/repo:tag
quay.io/prometheus/prometheus  # quay.io/prometheus/prometheus:latest
gcr.io/project/app:tag        # gcr.io/project/app:tag
```

### Registry-API-Aufrufe
Für jede Registry werden spezifische API-Endpoints verwendet:

```bash
# Docker Hub
curl -s "https://registry.hub.docker.com/v2/repositories/library/nginx/tags"

# GitHub Container Registry
curl -s -H "Authorization: Bearer $GITHUB_PAT" \
  "https://ghcr.io/v2/owner/repo/tags/list"

# Quay.io
curl -s "https://quay.io/api/v1/repository/prometheus/prometheus/tag/"

# Google Container Registry
curl -s "https://gcr.io/v2/project/image/tags/list"
```

### Status-Codes
- **200** - Image existiert und ist verfügbar
- **401/403** - Authentifizierung erforderlich (private Image)
- **404** - Image nicht gefunden
- **429** - Rate Limit erreicht (automatische Pause)
- **Timeout** - Netzwerk-Timeout oder Registry nicht erreichbar

## 🏢 Anwendungsfälle

### CI/CD-Pipeline Integration
```bash
# In GitLab CI oder GitHub Actions
check-images --file required-images.txt --output json > image-check.json

# Exit-Code für Pipeline-Steuerung
if ! check-images --file required-images.txt; then
  echo "Einige Images sind nicht verfügbar!"
  exit 1
fi
```

### Kubernetes Deployment Vorbereitung
```bash
# Alle Images aus Kubernetes Manifests prüfen
grep -r "image:" k8s-manifests/ | \
  sed 's/.*image: *//' | \
  sort -u > deployment-images.txt

check-images --file deployment-images.txt --verbose
```

### Docker Compose Validierung
```bash
# Images aus docker-compose.yml extrahieren
docker-compose config | grep -E "image:" | \
  awk '{print $2}' > compose-images.txt

check-images --file compose-images.txt
```

### Security Audit
```bash
# Alle verwendeten Images dokumentieren
check-images --file all-images.txt --output csv > image-inventory.csv

# JSON für weitere Analyse
check-images --file all-images.txt --output json | \
  jq '.[] | select(.status != "found")' > problematic-images.json
```

### Multi-Registry Image Discovery
```bash
# Images in verschiedenen Registries finden
cat > multi-registry-check.txt << EOF
nginx:latest
ghcr.io/actions/runner:latest  
quay.io/prometheus/prometheus:latest
gcr.io/distroless/static:latest
public.ecr.aws/lambda/python:3.9
EOF

check-images --file multi-registry-check.txt --timeout 20
```

## ⚠️ Hinweise

### Rate Limits
- **Docker Hub**: ~100 Requests/6h für anonyme Nutzer, ~5000/6h für authentifizierte
- **GitHub Container Registry**: Abhängig vom GitHub-Plan
- **Quay.io**: Verschiedene Limits je nach Account-Typ
- **Automatische Behandlung**: Bei HTTP 429 pausiert das Tool automatisch

### Authentifizierung
- **GitHub Container Registry**: Personal Access Token mit `read:packages` Scope
- **Private Docker Hub**: Aktuell nicht unterstützt (Feature-Request)
- **Quay.io Private**: Robot Accounts oder User Tokens
- **GCR Private**: Service Account Keys (aktuell nicht unterstützt)

### Performance
- **Sequential Processing**: Images werden nacheinander geprüft (keine Parallelisierung)
- **Timeout-Konfiguration**: Standard 10 Sekunden, anpassbar mit `--timeout`
- **Netzwerk-Abhängig**: Langsame Verbindungen können Timeouts verursachen
- **Memory Usage**: Minimal, auch bei grossen Image-Listen

## 🔍 Troubleshooting

### Häufige Probleme

#### Curl nicht gefunden
```bash
[ERROR] Fehlende Abhängigkeiten: curl
```
**Lösung**:
```bash
# macOS
brew install curl

# Ubuntu/Debian
sudo apt install curl

# CentOS/RHEL
sudo yum install curl
```

#### Timeout-Probleme
```bash
nginx:latest -> ⏰ timeout
```
**Lösungen**:
```bash
# Timeout erhöhen
check-images --file images.txt --timeout 30

# Netzwerk-Verbindung testen
curl -I https://registry.hub.docker.com

# Registry-Status prüfen
curl -s https://status.docker.com/api/v2/status.json
```

#### Rate Limit erreicht
```bash
nginx:latest -> ⏳ rate limited
[WARN] Rate limit erreicht - pausiere 5 Sekunden
```
**Lösungen**:
- Warten bis Rate Limit zurückgesetzt wird
- Authentifizierung verwenden (höhere Limits)
- Images in kleineren Batches prüfen

#### GitHub Container Registry Authentication
```bash
ghcr.io/private/repo:tag -> 🔒 requires authentication
```
**Lösungen**:
```bash
# Personal Access Token erstellen (Settings → Developer settings → Tokens)
# Mit 'read:packages' Scope

export GITHUB_PAT="ghp_xxxxxxxxxxxxxxxxxxxx"
check-images --image ghcr.io/private/repo:tag

# Oder direkt als Parameter
check-images --image ghcr.io/private/repo:tag --github-pat "ghp_xxx"
```

#### Unbekannte Registry
```bash
my-registry.com/app:latest -> ❓ Unknown registry: my-registry.com
```
**Lösung**: Das Tool versucht automatisch generische API-Pfade. Für spezielle Registries kann das Script erweitert werden.

### Debug-Befehle

```bash
# Verbose-Modus für detaillierte Informationen
check-images --image nginx:latest --verbose

# Registry API manuell testen
curl -s "https://registry.hub.docker.com/v2/repositories/library/nginx/tags" | head

# GitHub Token testen
curl -H "Authorization: Bearer $GITHUB_PAT" \
  "https://api.github.com/user"

# Dry-Run für Analyse
check-images --file images.txt --dry-run --verbose

# Einzelne Images isoliert testen
check-images --image problematic/image:tag --verbose --timeout 60
```

## 💡 Tipps & Tricks

### Input-Datei erstellen
```bash
# Aus Kubernetes YAML
grep -rho "image: .*" k8s/ | cut -d' ' -f2 | sort -u > k8s-images.txt

# Aus Docker Compose
docker-compose config | yq eval '.services[].image' - | sort -u > compose-images.txt

# Aus Dockerfile
grep -h "^FROM " */Dockerfile | awk '{print $2}' | sort -u > base-images.txt

# Manuell erstellen mit Kommentaren
cat > images.txt << EOF
# Base Images
nginx:latest
alpine:3.18
ubuntu:22.04

# Application Images  
ghcr.io/myorg/api:v1.2.3
quay.io/prometheus/prometheus:latest

# Monitoring Stack
grafana/grafana:latest
prom/node-exporter:latest
EOF
```

### Output-Verarbeitung
```bash
# Nur fehlende Images anzeigen
check-images --file images.txt | grep "❌"

# JSON nach Status filtern
check-images --file images.txt --output json | \
  jq '.[] | select(.status == "not_found") | .image'

# CSV für Excel/Google Sheets
check-images --file images.txt --output csv > inventory.csv

# Problematische Images in separate Datei
check-images --file images.txt | \
  grep -E "(❌|🔒|⚠️)" | \
  cut -d' ' -f1 > problematic-images.txt
```

### Automation und Scheduling
```bash
# Täglicher Check mit E-Mail-Benachrichtigung
#!/bin/bash
if ! check-images --file production-images.txt --output json > daily-check.json; then
  mail -s "Image Check Failed" admin@company.com < daily-check.json
fi

# Wöchentlicher Inventory-Report
0 8 * * 1 check-images --file all-images.txt --output csv > weekly-inventory-$(date +\%Y-\%m-\%d).csv
```

### Multi-Registry Strategies
```bash
# Registry-Fallbacks implementieren
cat > check-with-fallbacks.sh << 'EOF'
#!/bin/bash
for image in $(cat images.txt); do
  if check-images --image "$image" | grep -q "✅"; then
    echo "$image: OK"
  elif check-images --image "docker.io/$image" | grep -q "✅"; then
    echo "$image: Found in Docker Hub"
  else
    echo "$image: NOT FOUND"
  fi
done
EOF
chmod +x check-with-fallbacks.sh
```

## 📚 Verwandte Tools

### Ähnliche Tools in der Toolbox
- **crane-fqdn** - Container-Registry FQDN Extraktor
- **gitlab-clone** - GitLab Repository Synchronisation Tool
- **k8s-vuln** - Kubernetes Vulnerability Scanner

### Externe Container-Tools
- **skopeo** - Container Image Operations (inspect, copy, etc.)
- **crane** - Container Registry Toolkit von Google
- **docker manifest** - Multi-arch Image Manifests
- **regctl** - Registry Client für OCI/Docker Registries

### Registry-Clients
- **docker search** - Docker Hub Image Search
- **helm search** - Helm Chart Search
- **oras** - OCI Registry as Storage

## 🔄 Wartung und Updates

### Script-Updates
```bash
# Aktuellste Version holen
cd toolbox
git pull origin main

# Neue Features testen
check-images --help
```

### Registry-Support erweitern
Das Tool ist erweiterbar für neue Registries. Füge neue Fälle in der `get_registry_url()` Funktion hinzu:

```bash
# Beispiel für neue Registry
your-registry.com)
    echo "https://your-registry.com/v2/${namespace}/${image_name}/tags/list"
    ;;
```

### Performance-Optimierungen
- **Parallel Processing**: Kann durch `xargs -P` implementiert werden
- **Caching**: API-Responses können für wiederholte Prüfungen gecacht werden
- **Batch-APIs**: Einige Registries unterstützen Batch-Abfragen