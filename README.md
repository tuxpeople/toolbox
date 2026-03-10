# 🧰 Toolbox

Eine Sammlung nützlicher Scripts und Tools für DevOps, SysAdmin und Container-Management.

## 📋 Verfügbare Tools

### Container & Registry
- **[check-images](./check-images/)** - Prüft Verfügbarkeit von Container-Images in verschiedenen Registries
- **[registry-fqdns](./registry-fqdns/)** - Extrahiert FQDNs für Container-Registry Firewall-Freischaltungen
- **[k8s-image-arches](./k8s-image-arches/)** - Zeigt verfügbare Architekturen für alle Container-Images in einem Kubernetes-Cluster

### Development & Build
- **[brewfile-doc](./brewfile-doc/)** - Fügt automatisch Beschreibungen zu Brewfile-Einträgen hinzu
- **[gitlab-clone](./gitlab-clone/)** - Synchronisiert alle GitLab-Repositories eines Benutzers
- **[lima-k8s](./lima-k8s/)** - Lima-basierte Kubernetes und k3s Cluster für lokale Entwicklung
- **[serve-this](./serve-this/)** - Schneller HTTPS/HTTP-Server für lokale Entwicklung
- **[yt-get](./yt-get/)** - Einfacher Wrapper für yt-dlp zum Download von Videos und Audio
- **[youtube-to-obsidian](./youtube-to-obsidian/)** - Erstellt strukturierte YouTube-Video-Zusammenfassungen für Obsidian

### Network & SSH
- **[fix-ssh-key](./fix-ssh-key/)** - SSH Known Hosts reparieren und aktualisieren

### Security & Kubernetes
- **[k8s-vuln](./k8s-vuln/)** - Scannt Kubernetes-Cluster auf Sicherheitslücken
- **[kubectl-backup](./kubectl-backup/)** - Exportiert alle Kubernetes-Ressourcen für Backup und Disaster Recovery
- **[namespace-logs](./namespace-logs/)** - Exportiert alle Container-Logs eines Kubernetes-Namespaces

### Shell & Terminal
- **[sync-toolbox-links](./sync-toolbox-links/)** - Symlinks in ~/bin für alle Toolbox-Scripts erstellen und verwalten
- **[timestamped-history](./timestamped-history/)** - Bash-History mit Timestamps anzeigen und filtern

### System Administration
- **[fix-perms](./fix-perms/)** - macOS Benutzer-Permissions reparieren

### Document Processing
- **[pdf-split](./pdf-split/)** - Teilt ein PDF in einzelne Seiten auf

### System & Text Processing
- **[check-repo-checksum](./check-repo-checksum/)** - Prüft RPM-Paket-Prüfsummen gegen Repository-Metadaten
- **[sanitize-text](./sanitize-text/)** - Säubert Text-Dateien von speziellen Unicode-Zeichen

### Network & Backup
- **[udm-backup](./udm-backup/)** - UniFi Dream Machine Backup-Tool

## 🚀 Schnellstart

1. Repository klonen:
   ```bash
   git clone https://github.com/tuxpeople/toolbox.git
   cd toolbox
   ```

2. Symlinks bootstrappen (einmalig):
   ```bash
   ./sync-toolbox-links/sync-toolbox-links
   ```

3. Gewünschtes Tool verwenden:
   ```bash
   # Container-Images Verfügbarkeit prüfen
   cd check-images
   ./check-images --image nginx:latest
   
   # Container-Registry FQDNs extrahieren
   cd registry-fqdns
   ./registry-fqdns nginx:latest

   # Kubernetes Image-Architekturen anzeigen
   cd k8s-image-arches
   ./k8s-image-arches
   
   # Brewfile kommentieren
   cd brewfile-doc
   ./brewfile-doc.sh
   
   # GitLab Repositories synchronisieren
   cd gitlab-clone
   export GITLAB_TOKEN="glpat-xxxxxxxxxxxxxxxxxxxx"
   ./gitlab-clone
   
   # SSH Host-Keys reparieren
   cd fix-ssh-key
   ./fix-ssh-key example.com
   
   # Kubernetes Vulnerability Scan
   cd k8s-vuln
   ./k8s-vuln CVE-2021-44228

   # Kubernetes Cluster Backup
   cd kubectl-backup
   ./kubectl-backup -o cluster-backup

   # Namespace-Logs exportieren
   cd namespace-logs
   ./namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs
   
   # Lima Kubernetes Cluster starten
   cd lima-k8s
   ./lima-k8s start k8s
   
   # Video/Audio Download
   cd yt-get
   ./yt-get video "https://youtube.com/watch?v=..."

   # YouTube-Video zu Obsidian-Note
   cd youtube-to-obsidian
   ./youtube-to-obsidian "https://youtube.com/watch?v=..." output.md

   # Lokalen HTTPS-Server starten
   cd serve-this
   ./serve-this

   # RPM Repository Checksums prüfen
   cd check-repo-checksum
   ./check-repo-checksum https://repo.example.com/centos/7/x86_64 nginx-1.20.1-1.el7.x86_64.rpm

   # Text-Dateien säubern
   cd sanitize-text
   ./sanitize-text document.txt

   # Bash-History mit Timestamps anzeigen
   cd timestamped-history
   ./timestamped-history -n 50

   # PDF in einzelne Seiten aufteilen
   cd pdf-split
   ./pdf-split document.pdf output/

   # UDM Backups verwalten
   cd udm-backup
   ./udm-backup
   ```

## 📝 Tool-Status

| Tool | Status | Beschreibung |
|------|--------|--------------|
| 🔍 check-images | ✅ **Ready** | Container Image Availability Checker |
| 🏗️ registry-fqdns | ✅ **Ready** | Container-Registry FQDN Extraktor |
| 🏛️ k8s-image-arches | ✅ **Ready** | Kubernetes Image Architecture Analyzer |
| 🍺 brewfile-doc | ✅ **Ready** | Brewfile Beschreibungs-Generator |
| 🦊 gitlab-clone | ✅ **Ready** | GitLab Repository Synchronisation Tool |
| 🔑 fix-ssh-key | ✅ **Ready** | SSH Known Hosts Reparatur |
| 🛡️ k8s-vuln | ✅ **Ready** | Kubernetes Vulnerability Scanner |
| 💾 kubectl-backup | ✅ **Ready** | Kubernetes Cluster Backup Tool |
| 📜 namespace-logs | ✅ **Ready** | Kubernetes Namespace Log Exporter |
| 🚀 lima-k8s | ✅ **Ready** | Lima-basierte Kubernetes/k3s Cluster Manager |
| 🌐 serve-this | ✅ **Ready** | Lokaler HTTPS/HTTP Development Server |
| 🛠️ fix-perms | ✅ **Ready** | macOS Permissions Reparatur-Tool |
| 📦 check-repo-checksum | ✅ **Ready** | RPM Repository Checksum Validator |
| 📄 pdf-split | ✅ **Ready** | PDF Seiten-Splitter |
| 📝 sanitize-text | ✅ **Ready** | Text Unicode Sanitizer |
| 📡 udm-backup | ✅ **Ready** | UniFi Dream Machine Backup-Tool |
| 📺 yt-get | ✅ **Ready** | yt-dlp Wrapper für Video/Audio Downloads |
| 🎬 youtube-to-obsidian | ✅ **Ready** | YouTube zu Obsidian Video-Zusammenfassungs-Generator |
| 🔗 sync-toolbox-links | ✅ **Ready** | Toolbox-Symlinks in ~/bin verwalten |
| 📜 timestamped-history | ✅ **Ready** | Bash-History mit Timestamps anzeigen |

**Legende:**
- ✅ **Ready** - Vollständig überarbeitet, dokumentiert und einsatzbereit

## 📝 Struktur

Jedes Tool hat seinen eigenen Ordner mit:
- **Script-Datei(en)** - Das ausführbare Tool
- **README.md** - Umfassende Dokumentation
- **Beispiele** - Praktische Anwendungsfälle
- **Troubleshooting** - Häufige Probleme und Lösungen

## 🎯 Anwendungsbereiche

### DevOps & CI/CD
```bash
# Container-Image Verfügbarkeit vor Deployment prüfen
./check-images/check-images --file deployment-images.txt

# Container-Security in Pipeline
./k8s-vuln/k8s-vuln CVE-2021-44228 --quiet

# Kubernetes Cluster Backup
./kubectl-backup/kubectl-backup -o backup-$(date +%Y-%m-%d) --force

# Registry-Firewall-Regeln
./registry-fqdns/registry-fqdns my-app:latest
```

### Development Workflow
```bash
# Lokaler HTTPS-Server
./serve-this/serve-this -d ./build

# Brewfile dokumentieren
./brewfile-doc/brewfile-doc

# Alle GitLab-Repositories synchronisieren
./gitlab-clone/gitlab-clone --verbose
```

### System Administration
```bash
# SSH-Probleme beheben
./fix-ssh-key/fix-ssh-key production-server.com

# Kubernetes-Security-Audit
./k8s-vuln/k8s-vuln CVE-2022-0492 -s CRITICAL

# Kubernetes Cluster Backup
./kubectl-backup/kubectl-backup -o cluster-backup --verbose

# Kubernetes-Namespace-Logs exportieren
./namespace-logs/namespace-logs -n production -s "2025-08-25T10:00:00Z" -e "2025-08-25T12:00:00Z" -o ./incident-logs

# UniFi Dream Machine Backups
./udm-backup/udm-backup --dry-run
```

## 🔧 Installation

### Einzelne Tools
```bash
# Spezifisches Tool herunterladen
curl -o tool_name https://raw.githubusercontent.com/tuxpeople/toolbox/main/tool_dir/tool_name
chmod +x tool_name
```

### Ganzes Repository
```bash
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox

# Alle Tools ausführbar machen
find . -name "*.sh" -exec chmod +x {} \;
find . -type f -perm +111 -exec chmod +x {} \;
```

## 📊 Abhängigkeiten

| Tool | Abhängigkeiten | Installation |
|------|----------------|--------------|
| check-images | `curl` | Meist vorinstalliert |
| registry-fqdns | `crane` | `go install github.com/google/go-containerregistry/cmd/crane@latest` |
| k8s-image-arches | `kubectl`, `curl`, `jq` | `brew install kubectl jq` |
| brewfile-doc | `brew`, `jq` | `brew install jq` |
| gitlab-clone | `curl`, `jq`, `git` | `brew install curl jq git` |
| fix-ssh-key | `ssh-keygen`, `ssh-keyscan` | Meist vorinstalliert |
| k8s-vuln | `trivy`, `kubectl` | `brew install trivy kubectl` |
| kubectl-backup | `kubectl`, `yq` (optional) | `brew install kubectl yq` |
| namespace-logs | `kubectl` | `brew install kubectl` |
| lima-k8s | `lima` | `brew install lima` |
| serve-this | `python3`, `openssl` | Meist vorinstalliert |
| check-repo-checksum | `curl`, `gawk`, `grep`, `sed`, `gunzip`, `sha256sum` | `brew install coreutils gawk grep gnu-sed gzip` |
| pdf-split | `python3` mit venv | `brew install python3` |
| sanitize-text | `python3` (3.6+) | `brew install python3` |
| udm-backup | `ssh`, `scp`, `jq` | `brew install jq` |
| yt-get | `yt-dlp`, `ffmpeg` | `pip install yt-dlp && brew install ffmpeg` |
| youtube-to-obsidian | `yt-dlp`, `claude`, `python3` | `brew install yt-dlp claude-code` |
| sync-toolbox-links | `bash` 4+, `find` | `brew install bash` |
| timestamped-history | `awk` | Meist vorinstalliert |

## 🤝 Beitragen

Pull Requests und Issues sind willkommen!

### Beitrag-Guidelines
1. **Ein Tool pro PR** - Separate Pull Requests für jedes Tool
2. **README hinzufügen** - Jedes Tool braucht Dokumentation
3. **Tests durchführen** - Tools auf verschiedenen Systemen testen
4. **Copyright beachten** - Keine kopierten Code-Fragmente ohne Attribution

### Tool-Struktur
```
tool_name/
├── tool_name[.sh]        # Das ausführbare Script
├── README.md             # Vollständige Dokumentation
└── examples/             # Optional: Beispiel-Dateien
```

## ⚠️ Wichtiger Haftungsausschluss

**Diese Tools wurden für spezifische Use-Cases entwickelt und werden "as-is" bereitgestellt.**

- 🔧 **Verwendung auf eigene Gefahr** - Keine Garantie für Funktionalität oder Sicherheit
- 🧪 **Testen Sie zuerst** - Verwenden Sie Dry-Run Modi und testen Sie in sicheren Umgebungen
- 💾 **Backups erstellen** - Sichern Sie wichtige Daten vor der Verwendung
- 🎯 **Spezifische Konfiguration** - Tools sind auf bestimmte Setups optimiert
- 📖 **README lesen** - Verstehen Sie die Funktionsweise vor der Nutzung
- 🤝 **Feedback willkommen** - Issues und Pull Requests für Verbesserungen sind erwünscht

## 🔒 Sicherheitshinweise

- **brewfile-doc**: 📝 Modifiziert Brewfile - erstellt automatisch Backups
- **check-images**: 🔍 Führt HTTP-Requests zu Container-Registries durch - respektiert Rate-Limits
- **check-repo-checksum**: 📦 Lädt RPM-Pakete herunter - verwende nur vertrauenswürdige Repositories
- **gitlab-clone**: 🦊 Benötigt GitLab API Token - sichere Aufbewahrung erforderlich
- **fix-perms**: 🛠️ Repariert macOS Benutzerverzeichnis-Berechtigungen - nur auf eigenen Systemen verwenden
- **fix-ssh-key**: 🔑 Modifiziert SSH known_hosts - entfernt und fügt Host-Keys hinzu
- **k8s-image-arches**: 🏛️ Benötigt Kubernetes-Cluster-Zugriff - liest imagePullSecrets
- **k8s-vuln**: 🛡️ Benötigt Cluster-Zugriff - Berechtigungen prüfen
- **kubectl-backup**: 💾 Exportiert ALLE Ressourcen inkl. Secrets - sichere Aufbewahrung erforderlich
- **namespace-logs**: 📜 Benötigt Kubernetes-Cluster-Zugriff und Pod-Log-Berechtigungen
- **pdf-split**: 📄 Überschreibt existierende Dateien ohne Warnung - Dry-Run empfohlen
- **sanitize-text**: 📝 Nicht umkehrbar - behalte Originaldateien bei kritischen Dokumenten
- **serve-this**: 🌐 Macht Dateien im Netzwerk zugänglich - sensible Daten beachten
- **udm-backup**: 📡 Benötigt SSH-Zugriff zur UniFi Dream Machine
- **youtube-to-obsidian**: 🎬 Nutzt Claude CLI - keine API-Kosten, erfordert Claude Code/Desktop
- **timestamped-history**: 📜 Liest ~/.bash_history - enthält möglicherweise sensible Befehlsargumente (Passwörter, Tokens)

## 📄 Lizenz

MIT License - siehe [LICENSE](./LICENSE) für Details.

Alle Tools sind frei verwendbar für private und kommerzielle Zwecke.