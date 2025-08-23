# 🧰 Toolbox

Eine Sammlung nützlicher Scripts und Tools für DevOps, SysAdmin und Container-Management.

## 📋 Verfügbare Tools

### Container & Registry
- **[crane_fqdn](./crane_fqdn/)** - Extrahiert FQDNs für Container-Registry Firewall-Freischaltungen

### Development & Build
- **[brewfile-commenter](./brewfile-commenter/)** - Fügt automatisch Beschreibungen zu Brewfile-Einträgen hinzu
- **[serve_this](./serve_this/)** - Schneller HTTPS/HTTP-Server für lokale Entwicklung

### Network & SSH
- **[fix-ssh-key](./fix-ssh-key/)** - SSH Known Hosts reparieren und aktualisieren

### Security & Kubernetes
- **[k8s_vuln](./k8s_vuln/)** - Scannt Kubernetes-Cluster auf Sicherheitslücken

### System Administration
- **[fix-perms](./fix-perms/)** - macOS Benutzer-Permissions reparieren

### Network & Backup
- **[udm_backup](./udm_backup/)** - UniFi Dream Machine Backup-Tool

## 🚀 Schnellstart

1. Repository klonen:
   ```bash
   git clone https://github.com/tuxpeople/toolbox.git
   cd toolbox
   ```

2. Gewünschtes Tool verwenden:
   ```bash
   # Container-Registry FQDNs extrahieren
   cd crane_fqdn
   ./crane_fqdn.sh nginx:latest
   
   # Brewfile kommentieren
   cd brewfile-commenter
   ./brewfile-commenter.sh
   
   # SSH Host-Keys reparieren
   cd fix-ssh-key
   ./fix-ssh-key example.com
   
   # Kubernetes Vulnerability Scan
   cd k8s_vuln
   ./k8s_vuln.sh CVE-2021-44228
   
   # Lokalen HTTPS-Server starten
   cd serve_this
   ./serve_this
   
   # UDM Backups verwalten
   cd udm_backup
   ./udm_backup
   ```

## 📝 Tool-Status

| Tool | Status | Beschreibung |
|------|--------|--------------|
| 🏗️ crane_fqdn | ✅ **Ready** | Container-Registry FQDN Extraktor |
| 🍺 brewfile-commenter | ✅ **Ready** | Brewfile Beschreibungs-Generator |
| 🔑 fix-ssh-key | ✅ **Ready** | SSH Known Hosts Reparatur |
| 🛡️ k8s_vuln | ✅ **Ready** | Kubernetes Vulnerability Scanner |
| 🌐 serve_this | ✅ **Ready** | Lokaler HTTPS/HTTP Development Server |
| 🛠️ fix-perms | ✅ **Ready** | macOS Permissions Reparatur-Tool |
| 📡 udm_backup | ✅ **Ready** | UniFi Dream Machine Backup-Tool |

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
# Container-Security in Pipeline
./k8s_vuln/k8s_vuln.sh CVE-2021-44228 --quiet

# Registry-Firewall-Regeln
./crane_fqdn/crane_fqdn.sh my-app:latest
```

### Development Workflow
```bash
# Lokaler HTTPS-Server
./serve_this/serve_this -d ./build

# Brewfile dokumentieren
./brewfile-commenter/brewfile-commenter.sh
```

### System Administration
```bash
# SSH-Probleme beheben
./fix-ssh-key/fix-ssh-key production-server.com

# Kubernetes-Security-Audit
./k8s_vuln/k8s_vuln.sh CVE-2022-0492 -s CRITICAL

# UniFi Dream Machine Backups
./udm_backup/udm_backup --dry-run
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
| crane_fqdn | `crane` | `go install github.com/google/go-containerregistry/cmd/crane@latest` |
| brewfile-commenter | `brew`, `jq` | `brew install jq` |
| fix-ssh-key | `ssh-keygen`, `ssh-keyscan` | Meist vorinstalliert |
| k8s_vuln | `trivy`, `kubectl` | `brew install trivy kubectl` |
| serve_this | `python3`, `openssl` | Meist vorinstalliert |
| udm_backup | `ssh`, `scp`, `jq` | `brew install jq` |

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

- **brewfile-commenter**: 📝 Modifiziert Brewfile - erstellt automatisch Backups
- **fix-perms**: 🛠️ Repariert macOS Benutzerverzeichnis-Berechtigungen - nur auf eigenen Systemen verwenden
- **fix-ssh-key**: 🔑 Modifiziert SSH known_hosts - entfernt und fügt Host-Keys hinzu
- **k8s_vuln**: 🛡️ Benötigt Cluster-Zugriff - Berechtigungen prüfen
- **serve_this**: 🌐 Macht Dateien im Netzwerk zugänglich - sensible Daten beachten
- **udm_backup**: 📡 Benötigt SSH-Zugriff zur UniFi Dream Machine

## 📄 Lizenz

MIT License - siehe [LICENSE](./LICENSE) für Details.

Alle Tools sind frei verwendbar für private und kommerzielle Zwecke.