# Container Registry FQDN Extractor

Ein einfaches Bash-Script, das alle FQDNs (Fully Qualified Domain Names) extrahiert, die beim Pullen eines Container-Images kontaktiert werden müssen. Perfekt für Firewall-Freischaltungen in Unternehmensumgebungen.

## 🎯 Zweck

Beim Pullen von Container-Images werden oft mehrere Endpunkte kontaktiert:

- Der Registry-Endpunkt selbst
- Authentifizierung-Server
- Blob-Storage-Endpunkte
- CDN-Server

Dieses Script erfasst automatisch alle diese Endpunkte durch Analyse des `crane -v pull` Outputs.

## 📋 Voraussetzungen

- **crane** muss installiert sein:
  ```bash
  go install github.com/google/go-containerregistry/cmd/crane@latest
  ```

## 🚀 Installation

1. Script herunterladen:

   ```bash
   curl -o crane_fqdn.sh https://raw.githubusercontent.com/tuxpeople/toolbox/crane_fqdn/crane_fqdn.sh
   chmod +x crane_fqdn.sh
   ```

2. Oder manuell erstellen und ausführbar machen:
   ```bash
   chmod +x crane_fqdn.sh
   ```

## 💻 Verwendung

### Grundlegende Syntax

```bash
./crane_fqdn.sh <image>
```

### Beispiele

**Docker Hub Images:**

```bash
./crane_fqdn.sh nginx:latest
./crane_fqdn.sh postgres:15
```

**Private Registries:**

```bash
./crane_fqdn.sh gcr.io/my-project/my-app:v1.0.0
./crane_fqdn.sh quay.io/prometheus/node-exporter:latest
```

**Enterprise Registries:**

```bash
./crane_fqdn.sh my-company.azurecr.io/app:latest
./crane_fqdn.sh 123456789.dkr.ecr.eu-west-1.amazonaws.com/my-app:v2.1.0
```

## 📄 Ausgabe-Beispiel

```bash
$ ./crane_fqdn.sh registry.rancher.com/rancher/rancher:v2.10.3

[INFO] Extrahiere FQDNs für Image: registry.rancher.com/rancher/rancher:v2.10.3
[INFO] Verwende Ihre elegante One-Liner Methode...
[INFO] Führe crane -v pull aus...

[SUCCESS] Gefundene FQDNs:
==========================
registry.rancher.com
registry-storage.suse.com
scc.suse.com
==========================
[INFO] Insgesamt 3 unique FQDNs gefunden

[INFO] Für Firewall-Regel (komma-getrennt):
registry.rancher.com,registry-storage.suse.com,scc.suse.com
```

## 🔧 Funktionsweise

Das Script verwendet eine elegante One-Liner-Methode:

```bash
crane -v pull "$IMAGE" "$TEMP_FILE" 2>&1 | \
    grep "\-\->\|<\-\-" | \
    grep -o -E 'https?://[^,]+' | \
    tr ',' '\n' | \
    cut -d'/' -f1-3 | \
    sed 's|https\?://||' | \
    sort -u
```

**Schritt für Schritt:**

1. `crane -v pull` - Führt einen verbose Pull durch und loggt alle HTTP-Requests
2. `grep "\-\->\|<\-\-"` - Filtert nur die HTTP-Request/Response-Zeilen
3. `grep -o -E 'https?://[^,]+'` - Extrahiert alle URLs
4. `tr ',' '\n'` - Trennt komma-getrennte URLs in separate Zeilen
5. `cut -d'/' -f1-3` - Behält nur Schema + Hostname (ohne Pfad)
6. `sed 's|https\?://||'` - Entfernt das http/https-Präfix
7. `sort -u` - Sortiert und entfernt Duplikate

## 🏢 Anwendungsfälle

### Firewall-Konfiguration

```bash
# FQDNs für nginx:latest ermitteln
./crane_fqdn.sh nginx:latest

# Output für Firewall-Team:
# docker.io,registry-1.docker.io,auth.docker.io,production.cloudflare.docker.com
```

### CI/CD Pipeline Vorbereitung

```bash
# Alle benötigten Endpunkte für ein Deployment ermitteln
for image in nginx:latest postgres:15 redis:7; do
    echo "=== $image ==="
    ./crane_fqdn.sh "$image"
    echo
done
```

### Registry-Migration

```bash
# Vergleich der Endpunkte zwischen alter und neuer Registry
./crane_fqdn.sh old-registry.com/app:v1.0
./crane_fqdn.sh new-registry.com/app:v1.0
```

## 🌐 Unterstützte Registries

Das Script funktioniert mit allen Container-Registries, einschließlich:

- **Docker Hub** (`docker.io`)
- **Google Container Registry** (`gcr.io`, `pkg.dev`)
- **Amazon ECR** (`*.dkr.ecr.*.amazonaws.com`)
- **Azure Container Registry** (`*.azurecr.io`)
- **Red Hat Quay** (`quay.io`)
- **GitHub Container Registry** (`ghcr.io`)
- **Private/Enterprise Registries** (Harbor, etc.)

## ⚠️ Hinweise

- **Echter Download**: Das Script führt einen echten Pull-Vorgang durch, um alle Netzwerk-Endpunkte zu erfassen
- **Temporäre Dateien**: Das heruntergeladene Image wird in `/tmp` gespeichert und automatisch gelöscht
- **Netzwerk-Zugang**: Benötigt Zugang zu den Registry-Endpunkten
- **Authentifizierung**: Für private Registries muss `crane auth login` vorher ausgeführt werden

## 🔍 Troubleshooting

### Häufige Probleme

**"crane ist nicht installiert"**

```bash
# Installation prüfen
which crane

# Installation
go install github.com/google/go-containerregistry/cmd/crane@latest
```

Alternative Installationsmethode auf Mac:

```bash
brew install crane
```

**"Keine FQDNs gefunden"**

```bash
# Authentifizierung für private Registry
crane auth login registry.example.com

# Manueller Test
crane manifest nginx:latest
```

**"Permission denied"**

```bash
# Script ausführbar machen
chmod +x crane_fqdn.sh
```

### Debug-Modus

Für detaillierte Ausgabe der crane-Logs:

```bash
# Manuell mit vollem Output
crane -v pull nginx:latest /tmp/test.tgz
```

## 📝 Lizenz

MIT License - Frei verwendbar für alle Zwecke.

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen!

## 📚 Siehe auch

- [crane Dokumentation](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane.md)
- [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)
- [Docker Registry HTTP API](https://docs.docker.com/registry/spec/api/)
