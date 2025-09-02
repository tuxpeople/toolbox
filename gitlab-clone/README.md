# gitlab-clone - GitLab Repository Synchronisation Tool

Synchronisiert automatisch alle zugänglichen GitLab-Repositories eines Benutzers durch Klonen neuer und Aktualisieren existierender Repositories.

## 🎯 Zweck

Das `gitlab-clone` Tool automatisiert das Management aller GitLab-Repositories eines Benutzers. Es durchläuft alle über die GitLab API zugänglichen Repositories, klont neue Repositories und aktualisiert bestehende durch Git-Pull. Dabei wird die Namespace-Struktur von GitLab beibehalten und lokale Änderungen respektiert. Perfekt für Backup-Szenarien, Entwicklungsumgebung-Setup oder Team-Synchronisation.

## 📋 Voraussetzungen

- **curl** - Für GitLab API-Aufrufe
- **jq** - JSON-Parser für API-Antworten
- **git** - Git Version Control System
- **GitLab API Token** - Personal Access Token mit 'read_repository' Berechtigung
- **Bash 4.0+** - Für erweiterte Script-Features

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/gitlab-clone

# Script ausführbar machen (falls noch nicht geschehen)
chmod +x gitlab-clone

# Zu PATH hinzufügen (optional)
sudo ln -s "$(pwd)/gitlab-clone" /usr/local/bin/gitlab-clone
```

## 💻 Verwendung

### GitLab API Token erstellen

1. **GitLab.com oder Self-hosted GitLab** besuchen
2. **User Settings → Access Tokens** navigieren
3. **Neuen Token erstellen** mit folgenden Scopes:
   - ✅ `read_repository` (erforderlich)
   - ✅ `read_api` (empfohlen)
4. **Token sicher speichern** (wird nur einmal angezeigt)

### Grundlegende Syntax
```bash
gitlab-clone [OPTIONEN]
```

### Parameter

| Option | Lang-Form | Beschreibung | Erforderlich |
|--------|-----------|--------------|--------------|
| `-t` | `--token TOKEN` | GitLab API Token | ❌* |
| `-u` | `--url URL` | GitLab API URL | ❌ |
| `-d` | `--dir DIR` | Ziel-Verzeichnis | ❌ |
| `-f` | `--filter FILTER` | Repository-Filter | ❌ |
| `-v` | `--verbose` | Detaillierte Ausgabe | ❌ |
| `-n` | `--dry-run` | Nur anzeigen was gemacht würde | ❌ |
| | `--force` | Überschreibe ohne Nachfrage | ❌ |
| `-h` | `--help` | Hilfe anzeigen | ❌ |

*Token kann auch über Umgebungsvariable `GITLAB_TOKEN` gesetzt werden

### Umgebungsvariablen

| Variable | Beschreibung | Standard |
|----------|--------------|----------|
| `GITLAB_TOKEN` | GitLab API Token (erforderlich) | - |
| `GITLAB_API` | GitLab API URL | https://gitlab.com/api/v4 |
| `BASE_DIR` | Basis-Verzeichnis für Repositories | ./repos |
| `REPO_FILTER` | Filter für Repository-Namen | - |

### Beispiele

```bash
# GitLab Token setzen und alle Repositories synchronisieren
export GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
gitlab-clone

# Mit Custom GitLab-Instanz
gitlab-clone --url "https://gitlab.example.com/api/v4" --token "glpat-xxx"

# Nur bestimmte Repositories (Filter)
gitlab-clone --filter "backend"
gitlab-clone --filter "myproject"

# In spezifisches Verzeichnis
gitlab-clone --dir "/backup/repos"

# Dry-Run um zu sehen was passieren würde
gitlab-clone --dry-run --verbose

# Mit Konfigurationsdatei (.env im Script-Verzeichnis)
cat > .env << EOF
GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
GITLAB_API="https://gitlab.example.com/api/v4"
BASE_DIR="/home/user/repos"
REPO_FILTER="backend"
EOF
gitlab-clone

# Force-Modus für automatische Scripts
gitlab-clone --force --verbose
```

## 📄 Ausgabe-Beispiel

### Erfolgreiche Synchronisation
```bash
$ gitlab-clone --verbose

[INFO] gitlab-clone - GitLab Repository Synchronisation Tool
[INFO] GitLab API: https://gitlab.com/api/v4
[INFO] Ziel-Verzeichnis: ./repos
[VERBOSE] Lade Repositories von GitLab...
[VERBOSE] Lade Seite 1...
[VERBOSE] Gefunden: 25 Repositories auf Seite 1
[INFO] Bearbeite Repository: mycompany/backend-api
[VERBOSE] Repository nicht vorhanden, klone...
[SUCCESS] Repository erfolgreich geklont: backend-api
[INFO] Bearbeite Repository: mycompany/frontend-app
[VERBOSE] Repository existiert bereits, versuche zu pullen...
[VERBOSE] Pullen von Branch: main
[SUCCESS] Repository erfolgreich gepullt: mycompany/frontend-app (main)
[INFO] Insgesamt gefunden: 25 Repositories
[INFO] Synchronisation abgeschlossen!

📊 Statistiken:
   🆕 Geklont: 12
   🔄 Gepullt: 8
   ⏭️  Übersprungen: 3
   ❌ Fehler: 2

[SUCCESS] Alle Repositories erfolgreich synchronisiert!
```

### Repository-Struktur nach Synchronisation
```
repos/
├── mycompany/
│   ├── backend-api/
│   ├── frontend-app/
│   └── mobile-app/
├── personal/
│   ├── dotfiles/
│   └── scripts/
└── opensource/
    ├── my-lib/
    └── contribution-fork/
```

### Dry-Run Ausgabe
```bash
$ gitlab-clone --dry-run

[INFO] DRY_RUN Modus aktiv
[INFO] [DRY_RUN] Würde Repository klonen: git@gitlab.com:mycompany/new-service.git -> ./repos/mycompany/new-service
[INFO] [DRY_RUN] Würde Repository pullen: ./repos/mycompany/existing-app
```

## 🔧 Funktionsweise

### Workflow-Schritte
1. **Token-Validierung** - Prüft GitLab API Token und Verbindung
2. **Repository-Discovery** - Durchläuft alle Seiten der GitLab API
3. **Namespace-Erhaltung** - Erstellt lokale Verzeichnis-Struktur wie in GitLab
4. **Smart-Synchronisation** - Klont neue, pullt existierende Repositories
5. **Konflikt-Vermeidung** - Respektiert lokale Änderungen und untracked files
6. **Statistik-Reporting** - Zeigt detaillierte Zusammenfassung

### API-Aufrufe
```bash
# Repository-Liste abrufen (paginiert)
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_API/projects?membership=true&simple=true&per_page=100&page=1"

# Beispiel-API-Response
[
  {
    "id": 12345,
    "name": "backend-api",
    "path": "backend-api",
    "path_with_namespace": "mycompany/backend-api",
    "ssh_url_to_repo": "git@gitlab.com:mycompany/backend-api.git",
    "http_url_to_repo": "https://gitlab.com/mycompany/backend-api.git"
  }
]
```

### Git-Operationen
```bash
# Für neue Repositories
git clone --quiet "$repo_url" "$target_dir"

# Für existierende Repositories
cd "$target_dir"
git diff-index --quiet HEAD --        # Working directory clean?
git ls-files --others --exclude-standard  # Untracked files?
git pull --quiet origin "$current_branch"
```

## 🏢 Anwendungsfälle

### Backup und Archivierung
```bash
# Tägliches Backup aller Repositories
#!/bin/bash
export GITLAB_TOKEN="glpat-backup-token"
gitlab-clone --dir "/backup/gitlab/$(date +%Y-%m-%d)" --force

# Alte Backups bereinigen (älter als 30 Tage)
find /backup/gitlab -type d -mtime +30 -exec rm -rf {} \;
```

### Entwicklungsumgebung Setup
```bash
# Neuer Entwickler - alle Company-Repositories klonen
gitlab-clone --filter "mycompany" --dir "/workspace/projects"

# Nur Backend-Services
gitlab-clone --filter "backend" --dir "/workspace/backend"
```

### Team-Synchronisation
```bash
# Alle Repositories auf neuesten Stand bringen
gitlab-clone --verbose

# Vor wichtigen Meetings/Releases
gitlab-clone --filter "production" --force
```

### CI/CD Integration
```bash
# In GitLab CI Pipeline
gitlab-clone --token "$CI_REPOSITORY_TOKEN" --dir "./all-repos" --force --verbose
```

## ⚠️ Hinweise

### Sicherheit
- **Token-Schutz**: GitLab Token haben weitreichende Berechtigungen - sicher aufbewahren
- **SSH vs HTTPS**: Bei SSH-URLs werden SSH-Keys verwendet, bei HTTPS der Token
- **Token-Rotation**: Regelmässig Token erneuern und in allen Systemen aktualisieren
- **.env-Dateien**: Nicht in Version Control committen (`.gitignore` verwenden)

### Performance
- **Grosse GitLab-Instanzen**: Bei vielen Repositories kann Synchronisation Zeit dauern
- **API-Rate-Limits**: GitLab limitiert API-Aufrufe - bei Fehlern Pause einlegen
- **Parallelisierung**: Currently sequential - parallel processing könnte implementiert werden
- **Netzwerk**: Grosse Repositories können bei langsamen Verbindungen problematisch sein

### Lokale Änderungen
- **Working Directory**: Script pulllt nur wenn working directory clean ist
- **Untracked Files**: Repositories mit untracked files werden übersprungen
- **Detached HEAD**: Repositories im detached HEAD state werden übersprungen
- **Merge-Konflikte**: Bei Konflikten wird Pull übersprungen - manuelle Auflösung erforderlich

## 🔍 Troubleshooting

### Häufige Probleme

#### Token-Authentifizierung fehlgeschlagen
```bash
[ERROR] GitLab Token ungültig oder abgelaufen
```
**Lösungen**:
- Token in GitLab-Settings überprüfen
- Neuen Token mit korrekten Scopes erstellen
- Token-Berechtigung auf alle gewünschten Projekte prüfen

#### API-Verbindung fehlgeschlagen
```bash
[ERROR] Verbindung zu GitLab fehlgeschlagen
```
**Lösungen**:
```bash
# Netzwerk-Verbindung testen
curl -I https://gitlab.com

# API-URL manuell testen
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects?per_page=1"

# Custom GitLab-Instanz URL prüfen
gitlab-clone --url "https://gitlab.example.com/api/v4" --verbose
```

#### Abhängigkeiten fehlen
```bash
[ERROR] Fehlende Abhängigkeiten: jq
```
**Lösungen**:
```bash
# macOS
brew install curl jq git

# Ubuntu/Debian
sudo apt update && sudo apt install curl jq git

# CentOS/RHEL
sudo yum install curl jq git
```

#### Repository-Clone fehlgeschlagen
```bash
[WARN] Clone fehlgeschlagen für mycompany/private-repo
```
**Mögliche Ursachen**:
- SSH-Key nicht konfiguriert (bei SSH-URLs)
- Fehlende Repository-Berechtigung
- Repository-Name enthält Sonderzeichen
- Festplatten-Platz erschöpft

**Lösungen**:
```bash
# SSH-Key testen
ssh -T git@gitlab.com

# Repository-Berechtigung prüfen
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/projects/PROJECT_ID"

# Manueller Clone-Test
git clone git@gitlab.com:mycompany/private-repo.git
```

#### Pull-Konflikte
```bash
[WARN] Repository hat lokale Änderungen - überspringe Pull
```
**Lösungen**:
```bash
cd repos/mycompany/conflicted-repo

# Lokale Änderungen anzeigen
git status
git diff

# Änderungen stashen oder committen
git stash
# oder
git add . && git commit -m "Local changes"

# Danach gitlab-clone erneut ausführen
```

### Debug-Befehle

```bash
# Verbose-Modus für detaillierte Ausgabe
gitlab-clone --verbose

# Dry-Run um Probleme zu identifizieren
gitlab-clone --dry-run --verbose

# Einzelnes Repository manuell testen
git clone git@gitlab.com:namespace/repo.git

# API-Token manuell testen
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/projects?membership=true&simple=true&per_page=1"

# Lokales Repository-Status prüfen
cd repos/problematic/repo
git status
git remote -v
git branch -a
```

## 💡 Tipps & Tricks

### .env-Datei Konfiguration
```bash
# Erstelle .env-Datei im gitlab-clone/ Verzeichnis
cd /path/to/toolbox/gitlab-clone

cat > .env << EOF
# GitLab Configuration
GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
GITLAB_API="https://gitlab.example.com/api/v4"

# Directory Configuration
BASE_DIR="/backup/repositories"

# Filter Configuration
REPO_FILTER="backend"
EOF

# .env-Datei vor Versionskontrolle schützen
echo ".env" >> .gitignore
```

### Automation mit Cron
```bash
# Täglich um 02:00 alle Repositories synchronisieren
0 2 * * * /usr/local/bin/gitlab-clone --force >> /var/log/gitlab-sync.log 2>&1

# Wöchentlich Backup mit Datum
0 3 * * 0 GITLAB_TOKEN="glpat-xxx" /usr/local/bin/gitlab-clone --dir "/backup/gitlab-$(date +\%Y-\%m-\%d)" --force
```

### Selective Synchronisation
```bash
# Nur Production-Repositories
gitlab-clone --filter "prod"

# Nur eigene Repositories (nicht Forks)
REPO_FILTER="myusername" gitlab-clone

# Multiple Filter mit separaten Aufrufen
gitlab-clone --filter "backend" --dir "./backend-repos"
gitlab-clone --filter "frontend" --dir "./frontend-repos"
gitlab-clone --filter "mobile" --dir "./mobile-repos"
```

### Integration mit anderen Tools
```bash
# Nach Synchronisation Code-Qualität prüfen
gitlab-clone --force && \
find ./repos -name "*.py" -exec pylint {} \; > quality-report.txt

# Repository-Grössen analysieren
gitlab-clone --dry-run --verbose | grep "Würde Repository klonen" | \
while read line; do
  repo_url=$(echo "$line" | awk '{print $5}')
  du -sh "$repo_url" 2>/dev/null || echo "Not cloned: $repo_url"
done
```

### SSH vs HTTPS Handling
```bash
# SSH bevorzugen (Standard bei GitLab API)
# Stellt sicher dass SSH-Key konfiguriert ist
ssh -T git@gitlab.com

# HTTPS erzwingen (nützlich bei Firewall-Problemen)
# Modifikation der API-Response wäre nötig - Feature-Request
```

## 📚 Verwandte Tools

### Ähnliche Tools in der Toolbox
- **namespace-logs** - Kubernetes Namespace Log Exporter
- **udm-backup** - UniFi Dream Machine Backup-Tool
- **fix-ssh-key** - SSH Known Hosts Reparatur

### Externe GitLab-Tools
- **glab** - GitLab CLI Tool
- **gitlab-ci-multi-runner** - GitLab CI Runner
- **gitlab-backup** - GitLab Instance Backup Tool
- **git-sync** - Generic Git Repository Synchronizer

### Git-Management-Tools
- **myrepos** - Multiple Repository Management
- **mr** - Multiple Repository Tool
- **git-subrepo** - Git Subrepository Management
- **ghorg** - GitHub Organization Cloner

## 🔄 Wartung und Updates

### Script-Updates
```bash
# Aktuellste Version holen
cd toolbox
git pull origin main

# Neue Features testen
gitlab-clone --help
```

### Token-Rotation
```bash
# Alten Token deaktivieren in GitLab
# Neuen Token erstellen
# .env-Datei aktualisieren
sed -i 's/GITLAB_TOKEN="old-token"/GITLAB_TOKEN="new-token"/' .env

# Oder Umgebungsvariable aktualisieren
export GITLAB_TOKEN="new-token"
```

### Repository-Bereinigung
```bash
# Nicht mehr existierende Repositories finden
# (Repositories die lokal vorhanden aber nicht mehr in GitLab)
gitlab-clone --dry-run --verbose 2>&1 | \
grep -v "Würde Repository" | \
find ./repos -type d -name ".git" -exec dirname {} \;
```