# check-repo-checksum

RPM Repository Checksum Validator - Prüft RPM-Paket-Prüfsummen gegen Repository-Metadaten.

## 🎯 Zweck

Dieses Tool lädt Metadata von einem YUM/DNF Repository, extrahiert die erwartete Prüfsumme für ein RPM-Paket, lädt das Paket herunter und vergleicht die tatsächliche mit der erwarteten Prüfsumme. Ideal für die Validierung von Repository-Integrität und Package-Authentizität.

## 📋 Voraussetzungen

### Erforderliche Tools
- `curl` - Für HTTP-Requests
- `gawk` - GNU AWK für XML-Parsing
- `grep` - Text-Suche
- `sed` - Stream-Editor
- `gunzip` - Für XML-Dekomprimierung
- `sha256sum` - SHA256-Prüfsummen
- `sha1sum` - SHA1-Prüfsummen

### Installation der Abhängigkeiten

**macOS:**
```bash
brew install coreutils gawk grep gnu-sed gzip
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install curl gawk grep sed gzip coreutils
```

**Linux (RHEL/CentOS):**
```bash
sudo yum install curl gawk grep sed gzip coreutils
```

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/check-repo-checksum

# Oder direkt herunterladen
curl -o check-repo-checksum https://raw.githubusercontent.com/tuxpeople/toolbox/main/check-repo-checksum/check-repo-checksum
chmod +x check-repo-checksum
```

## 💻 Verwendung

### Syntax

```bash
./check-repo-checksum <REPO_BASE_URL> <RPM_FILENAME> [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-v, --verbose` | Detaillierte Ausgabe mit allen Schritten |
| `-h, --help` | Hilfe anzeigen |

### Argumente

- **REPO_BASE_URL**: Basis-URL des Repositories (z.B. `https://repo.example.com/centos/7/x86_64`)
- **RPM_FILENAME**: Name der RPM-Datei (z.B. `nginx-1.20.1-1.el7.x86_64.rpm`)

## 📄 Ausgabe-Beispiel

### Erfolgreicher Checksum-Vergleich

```bash
$ ./check-repo-checksum https://repo.example.com/centos/7/x86_64 nginx-1.20.1-1.el7.x86_64.rpm

[INFO] Repository: https://repo.example.com/centos/7/x86_64
[INFO] Paket: nginx-1.20.1-1.el7.x86_64.rpm
[INFO] Erwartete Prüfsumme (sha256): a1b2c3d4e5f6...
[INFO] Gefundene Prüfsumme (sha256): a1b2c3d4e5f6...
[SUCCESS] Prüfsummen stimmen überein ✅
```

### Fehlgeschlagener Vergleich

```bash
$ ./check-repo-checksum https://repo.example.com/centos/7/x86_64 modified-package.rpm

[INFO] Repository: https://repo.example.com/centos/7/x86_64
[INFO] Paket: modified-package.rpm
[INFO] Erwartete Prüfsumme (sha256): a1b2c3d4e5f6...
[INFO] Gefundene Prüfsumme (sha256): 9z8y7x6w5v4u...
[ERROR] Prüfsummen unterscheiden sich! ❌
[ERROR] Erwartet: a1b2c3d4e5f6...
[ERROR] Erhalten: 9z8y7x6w5v4u...
```

### Verbose-Modus

```bash
$ ./check-repo-checksum https://repo.example.com/centos/7/x86_64 nginx-1.20.1-1.el7.x86_64.rpm --verbose

[VERBOSE] Temporäres Verzeichnis: /tmp/tmp.Xaz123
[INFO] Repository: https://repo.example.com/centos/7/x86_64
[INFO] Paket: nginx-1.20.1-1.el7.x86_64.rpm
[VERBOSE] Lade repomd.xml ...
[VERBOSE] Extrahiere primary.xml.gz Pfad ...
[VERBOSE] Primary XML Pfad: repodata/abc123-primary.xml.gz
[VERBOSE] Lade und entpacke primary.xml.gz ...
[VERBOSE] Extrahiere erwartete Prüfsumme für nginx-1.20.1-1.el7.x86_64.rpm ...
[INFO] Erwartete Prüfsumme (sha256): a1b2c3d4e5f6...
[VERBOSE] Lade RPM-Paket ...
[VERBOSE] Berechne tatsächliche Prüfsumme ...
[INFO] Gefundene Prüfsumme (sha256): a1b2c3d4e5f6...
[SUCCESS] Prüfsummen stimmen überein ✅
```

## 🔧 Funktionsweise

Das Tool führt folgende Schritte aus:

1. **repomd.xml laden**: Lädt die Repository-Metadaten vom angegebenen Repository
2. **primary.xml.gz Pfad extrahieren**: Findet den Pfad zur Paket-Liste im repomd.xml
3. **primary.xml.gz laden und entpacken**: Lädt und entpackt die komprimierte Paket-Liste
4. **Erwartete Prüfsumme extrahieren**: Sucht das RPM-Paket in der primary.xml und extrahiert die Prüfsumme
5. **RPM-Paket herunterladen**: Lädt das eigentliche RPM-Paket herunter
6. **Tatsächliche Prüfsumme berechnen**: Berechnet die Prüfsumme des heruntergeladenen Pakets
7. **Prüfsummen vergleichen**: Vergleicht erwartete mit tatsächlicher Prüfsumme

### Unterstützte Prüfsummen-Typen

- **SHA256** (empfohlen)
- **SHA1** (legacy)

## 🏢 Anwendungsfälle

### Repository-Integrität prüfen

```bash
# Prüfe ob ein Paket korrekt im Repository liegt
./check-repo-checksum https://mirror.example.com/centos/8/BaseOS/x86_64/os kernel-5.14.rpm
```

### CI/CD Pipeline Integration

```bash
#!/bin/bash
# Validiere Packages vor Deployment

REPO="https://internal-repo.company.com/prod/x86_64"
PACKAGES=(
    "app-server-2.3.1-1.el8.x86_64.rpm"
    "app-client-2.3.1-1.el8.x86_64.rpm"
)

for pkg in "${PACKAGES[@]}"; do
    if ! ./check-repo-checksum "$REPO" "$pkg"; then
        echo "Package validation failed: $pkg"
        exit 1
    fi
done

echo "All packages validated successfully"
```

### Mirror-Validierung

```bash
# Prüfe ob Mirror-Server korrekte Packages bereitstellt
ORIGINAL="https://official-repo.example.com/rhel/8/x86_64"
MIRROR="https://mirror.company.local/rhel/8/x86_64"

# Beide müssen gleiche Checksums liefern
./check-repo-checksum "$ORIGINAL" "package.rpm"
./check-repo-checksum "$MIRROR" "package.rpm"
```

### Automatisierte Repository-Tests

```bash
# Teste alle kritischen Packages in einem Repository
while read -r package; do
    echo "Testing: $package"
    if ./check-repo-checksum https://repo.example.com/prod/x86_64 "$package" --verbose; then
        echo "✅ $package OK"
    else
        echo "❌ $package FAILED"
        exit 1
    fi
done < critical-packages.txt
```

## ⚠️ Hinweise

### Sicherheit
- **Temporäre Dateien**: Werden automatisch nach Ausführung gelöscht (via `trap`)
- **Netzwerk-Zugriff**: Erfordert Zugriff zum Repository-Server
- **HTTPS empfohlen**: Verwende HTTPS-URLs für sichere Übertragung

### Performance
- **Retry-Mechanismus**: curl wiederholt Downloads bei Fehlern (3 Versuche)
- **Komprimierung**: Unterstützt gzip-komprimierte Übertragung
- **Cache-Control**: Verhindert veraltete Caches

### Fehlercodes
- `0` - Erfolg, Prüfsummen stimmen überein
- `1` - Ungültige Argumente oder Optionen
- `2` - Fehlende Abhängigkeiten
- `3` - Fehler beim Laden von Repository-Daten
- `4` - Paket nicht in Repository gefunden
- `5` - Fehler beim Laden des RPM-Pakets oder unbekannter Prüfsummen-Typ
- `6` - Prüfsummen unterscheiden sich

## 🔍 Troubleshooting

### Problem: "Fehlende Abhängigkeiten"

**Symptom:**
```
[ERROR] Fehlende Abhängigkeiten: gawk sha256sum
```

**Lösung:**
```bash
# macOS
brew install coreutils gawk

# Linux
sudo apt install gawk coreutils
```

### Problem: "Konnte repomd.xml nicht laden"

**Symptom:**
```
[ERROR] Konnte repomd.xml nicht laden von: https://...
```

**Mögliche Ursachen:**
- Repository-URL ist falsch
- Repository ist nicht erreichbar
- Netzwerk-Verbindung fehlt
- Repository erfordert Authentifizierung

**Lösung:**
```bash
# Prüfe Repository-URL im Browser
curl -I https://repo.example.com/centos/7/x86_64/repodata/repomd.xml

# Teste mit verbose für mehr Details
./check-repo-checksum https://repo.example.com/centos/7/x86_64 package.rpm --verbose
```

### Problem: "Kein Eintrag für RPM in primary.xml gefunden"

**Symptom:**
```
[ERROR] Kein Eintrag für package.rpm in primary.xml gefunden
```

**Mögliche Ursachen:**
- Package-Name ist falsch geschrieben
- Package existiert nicht im Repository
- Repository-Metadaten sind veraltet

**Lösung:**
```bash
# Liste verfügbare Packages
curl -s https://repo.example.com/centos/7/x86_64/repodata/repomd.xml | \
  grep -o 'href="[^"]*primary.xml.gz"' | \
  cut -d'"' -f2

# Oder mit yum/dnf
yum list available | grep package-name
```

### Problem: "Prüfsummen unterscheiden sich"

**Symptom:**
```
[ERROR] Prüfsummen unterscheiden sich! ❌
```

**Mögliche Ursachen:**
- Package wurde modifiziert (Sicherheitsrisiko!)
- Repository-Korruption
- Man-in-the-Middle Angriff
- Mirror-Synchronisationsproblem

**Lösung:**
```bash
# Prüfe mit anderem Mirror
./check-repo-checksum https://alternative-mirror.example.com/... package.rpm

# Prüfe direkt beim offiziellen Repository
./check-repo-checksum https://official-repo.example.com/... package.rpm

# Bei Diskrepanz: NICHT INSTALLIEREN!
```

## 💡 Tipps & Tricks

### Batch-Validierung mehrerer Packages

```bash
# packages.txt erstellen
cat > packages.txt <<EOF
nginx-1.20.1-1.el7.x86_64.rpm
httpd-2.4.6-97.el7.x86_64.rpm
php-7.4.30-1.el7.x86_64.rpm
EOF

# Alle validieren
REPO="https://repo.example.com/centos/7/x86_64"
while read -r pkg; do
    ./check-repo-checksum "$REPO" "$pkg" || echo "FAILED: $pkg"
done < packages.txt
```

### Integration in Monitoring

```bash
#!/bin/bash
# Nagios/Icinga Check-Script

REPO="https://critical-repo.example.com/prod/x86_64"
PACKAGE="mission-critical-app-1.0.rpm"

if ./check-repo-checksum "$REPO" "$PACKAGE" &>/dev/null; then
    echo "OK - Package checksum valid"
    exit 0
else
    echo "CRITICAL - Package checksum mismatch!"
    exit 2
fi
```

### Logging für Audit-Trail

```bash
# Alle Validierungen loggen
LOG_FILE="/var/log/package-validation.log"

validate_package() {
    local repo="$1"
    local package="$2"
    local timestamp=$(date +%Y-%m-%d\ %H:%M:%S)

    if ./check-repo-checksum "$repo" "$package" &>/dev/null; then
        echo "$timestamp [OK] $package" >> "$LOG_FILE"
        return 0
    else
        echo "$timestamp [FAIL] $package" >> "$LOG_FILE"
        return 1
    fi
}

validate_package "https://repo.example.com/prod" "app-1.0.rpm"
```

## 📚 Verwandte Tools

- **[rpm --checksig](https://man7.org/linux/man-pages/man8/rpm.8.html)** - Verifiziert GPG-Signaturen von RPM-Packages
- **[dnf download](https://dnf.readthedocs.io/)** - Lädt RPM-Packages von Repositories
- **[createrepo](http://createrepo.baseurl.org/)** - Erstellt Repository-Metadaten
- **[repoquery](https://man7.org/linux/man-pages/man1/repoquery.1.html)** - Fragt Repository-Metadaten ab
- **yum-utils / dnf-utils** - Repository-Management-Tools

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
