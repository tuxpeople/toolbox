# UDM Backup - UniFi Dream Machine Backup Tool

Ein robustes Bash-Script zur automatischen Sicherung von UniFi Dream Machine (UDM) Autobackups mit intelligenter lokaler Backup-Verwaltung.

## 🎯 Zweck

Verwaltet UniFi Dream Machine Backups automatisch durch:

1. **Download von UDM Autobackups** via SSH/SCP
2. **Intelligente Backup-Bereinigung** basierend auf autobackup_meta.json
3. **Konfigurierbare Retention-Policy** 
4. **Robuste Fehlerbehandlung** und Logging
5. **Flexible Konfiguration** über Parameter, Umgebungsvariablen oder Config-Datei

## 📋 Voraussetzungen

- **SSH-Zugriff zur UDM** (typischerweise als root)
- **OpenSSH Tools** (ssh, scp) - normalerweise vorinstalliert
- **jq** für JSON-Verarbeitung:
  ```bash
  # macOS
  brew install jq
  
  # Ubuntu/Debian
  sudo apt-get install jq
  ```

## 🚀 Installation

```bash
# Script herunterladen
curl -o udm_backup https://raw.githubusercontent.com/tuxpeople/toolbox/main/udm_backup/udm_backup
chmod +x udm_backup
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./udm_backup [options]
```

### Hauptoptionen
- `-H, --host HOST` - UDM Host/IP-Adresse (Standard: 10.20.30.1)
- `-u, --user USER` - SSH-Benutzername (Standard: root)
- `-p, --port PORT` - SSH-Port (Standard: 22)
- `-d, --directory DIR` - Lokales Backup-Verzeichnis
- `-k, --ssh-key KEY` - SSH Private Key Datei
- `-r, --retention DAYS` - Backup-Aufbewahrung in Tagen (Standard: 30)

### Weitere Optionen
- `-n, --dry-run` - Testlauf ohne Änderungen
- `-v, --verbose` - Detaillierte Ausgabe
- `--skip-cleanup` - Keine lokale Backup-Bereinigung
- `--skip-download` - Kein Download, nur lokale Bereinigung
- `-h, --help` - Hilfe anzeigen

### Beispiele

**Standard-Backup:**
```bash
./udm_backup                    # Verwendet Standard-Konfiguration
```

**Andere UDM-Adresse:**
```bash
./udm_backup -H 192.168.1.1 -u admin
./udm_backup --host udm.example.com --user backup-user
```

**Anderes Backup-Verzeichnis:**
```bash
./udm_backup -d /backup/udm
./udm_backup --directory ~/backups/unifi
```

**Mit SSH-Key:**
```bash
./udm_backup -k ~/.ssh/udm_backup_key
./udm_backup --ssh-key /etc/backup/udm_key
```

**Testlauf:**
```bash
./udm_backup --dry-run          # Zeigt was gemacht würde
./udm_backup -n -v              # Dry-run mit Details
```

**Backup-Retention:**
```bash
./udm_backup -r 7               # Nur 7 Tage aufbewahren
./udm_backup --retention 90     # 90 Tage aufbewahren
```

**Nur lokale Bereinigung:**
```bash
./udm_backup --skip-download    # Kein Download von UDM
```

## 📄 Ausgabe-Beispiel

```bash
$ ./udm_backup -v

[INFO] UniFi Dream Machine Backup gestartet
[INFO] UDM: root@10.20.30.1:22
[INFO] Backup-Verzeichnis: /Users/admin/iCloudDrive/Allgemein/backup/udm
[INFO] Retention: 30 Tage

1) Bereite lokales Backup-Verzeichnis vor
[INFO] Backup-Verzeichnis existiert: /Users/admin/iCloudDrive/Allgemein/backup/udm
[INFO] Teste SSH-Verbindung zu root@10.20.30.1:22
[SUCCESS] SSH-Verbindung erfolgreich
[INFO] Prüfe UDM Backup-Verzeichnis: /mnt/data/unifi-os/unifi/data/backup/autobackup
[SUCCESS] UDM Backup-Verzeichnis gefunden
[INFO] Verfügbare Backup-Dateien: 3

2) Lade Autobackups von UDM herunter
[INFO] Lade Dateien herunter von: 10.20.30.1:/mnt/data/unifi-os/unifi/data/backup/autobackup
[SUCCESS] Backup-Download abgeschlossen
[INFO] Heruntergeladene Dateien: 4

3) Bereinige alte lokale Backups
[INFO] Verwende Metadata aus: /Users/admin/iCloudDrive/Allgemein/backup/udm/autobackup_meta.json
[INFO] Aktuelle Backup-Dateien (werden behalten): 4
[INFO] Lösche: old_backup_20241101.unf (45.2M)
[SUCCESS] Gelöschte Dateien: 1 (45.2M)

[INFO] === Backup-Statistiken ===
[INFO] Verzeichnis: /Users/admin/iCloudDrive/Allgemein/backup/udm
[INFO] Anzahl Backups: 3
[INFO] Gesamtgrosse: 142.8M
[INFO] Neuestes Backup: autobackup_6.7.56_20241122_0300_1732244400026.unf

[SUCCESS] UDM Backup erfolgreich abgeschlossen
```

## 🔧 Konfiguration

### 1. Kommandozeilenparameter (höchste Priorität)
```bash
./udm_backup -H 192.168.1.1 -u admin -d /backup/udm
```

### 2. Umgebungsvariablen
```bash
export UDM_HOST="10.20.30.1"
export UDM_USER="root"
export UDM_PORT="22"
export UDM_BACKUP_DIR="/backup/udm"
export UDM_SSH_KEY="~/.ssh/udm_key"
export UDM_RETENTION_DAYS="30"

./udm_backup
```

### 3. Konfigurationsdatei `~/.udm_backup_config`
```bash
# UDM Backup Konfiguration
UDM_HOST=10.20.30.1
UDM_USER=root
UDM_PORT=22
UDM_BACKUP_DIR=/Users/admin/iCloudDrive/Allgemein/backup/udm
UDM_SSH_KEY=/Users/admin/.ssh/udm_backup_key
UDM_RETENTION_DAYS=30
```

## 🏢 Anwendungsfälle

### Tägliche Backups mit Cron
```bash
# /etc/crontab - Täglich um 3:00 Uhr
0 3 * * * /home/admin/udm_backup >/var/log/udm_backup.log 2>&1

# Mit Rotation und Benachrichtigung
0 3 * * * /home/admin/udm_backup -r 14 && echo "UDM Backup OK" | mail -s "Backup Success" admin@example.com
```

### Backup-Server Setup
```bash
#!/bin/bash
# backup-server.sh - Mehrere UDMs sichern

# Produktions-UDM
UDM_HOST=10.1.1.1 UDM_BACKUP_DIR=/backup/udm-prod ./udm_backup

# Staging-UDM  
UDM_HOST=10.2.1.1 UDM_BACKUP_DIR=/backup/udm-staging ./udm_backup

# Test-UDM
UDM_HOST=10.3.1.1 UDM_BACKUP_DIR=/backup/udm-test ./udm_backup -r 7
```

### Monitoring Integration
```bash
#!/bin/bash
# Mit Exit-Code-Überwachung
if ! ./udm_backup --verbose; then
    echo "UDM Backup failed!" | mail -s "ALERT: Backup Failed" admin@example.com
    exit 1
fi

# Nagios/Icinga Check
./udm_backup --dry-run >/dev/null 2>&1 && echo "OK - UDM reachable" || echo "CRITICAL - UDM unreachable"
```

### Docker/Container Setup
```bash
# Dockerfile
FROM alpine:latest
RUN apk add --no-cache bash openssh-client jq
COPY udm_backup /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/udm_backup"]

# docker run
docker run -v ~/.ssh:/root/.ssh -v /backup:/backup udm-backup -d /backup
```

## 🌐 UDM-Unterstützung

### Getestete Modelle
- **UniFi Dream Machine (UDM)**
- **UniFi Dream Machine Pro (UDM Pro)**  
- **UniFi Dream Machine SE (UDM SE)**
- **UniFi Dream Router (UDR)**

### UniFi Controller Versionen
- **6.x** - Vollständig unterstützt
- **7.x** - Vollständig unterstützt
- **8.x** - Vollständig unterstützt

### Backup-Pfade
```bash
# Standard UDM-Pfad (wird automatisch verwendet)
/mnt/data/unifi-os/unifi/data/backup/autobackup/

# Enthält typischerweise:
autobackup_6.7.56_20241122_0300_1732244400026.unf  # Backup-Datei
autobackup_meta.json                                # Metadata
```

## ⚠️ Hinweise

### Sicherheit
- **SSH-Keys empfohlen** - Sicherer als Password-Auth
- **Netzwerk-Zugriff** - UDM muss über SSH erreichbar sein
- **Berechtigungen** - Script benötigt Schreibrechte im Backup-Verzeichnis

### Performance
- **Backup-Grosse** - UniFi-Backups können 50-200MB gross sein
- **Netzwerk-Bandbreite** - Downloads können je nach Backup-Grosse Zeit benötigen
- **Retention** - Niedrigere Retention spart Speicherplatz

### UDM-Spezifika
- **SSH muss aktiviert sein** - In UniFi OS Console unter System
- **Root-Zugriff** - Standardmäßig verfügbar bei UDM
- **Autobackups** - Müssen in UniFi Controller aktiviert sein

## 🔍 Troubleshooting

### Häufige Probleme

**"SSH-Verbindung fehlgeschlagen"**
```bash
# SSH-Zugriff manuell testen
ssh root@10.20.30.1

# UDM SSH aktivieren
# UniFi OS Console → System → Enable SSH

# Firewall prüfen
telnet 10.20.30.1 22
```

**"UDM Backup-Verzeichnis nicht gefunden"**
```bash
# Controller-Status prüfen
ssh root@10.20.30.1 "systemctl status unifi"

# Autobackups aktiviert?
# UniFi Controller → Settings → System → Backup → Auto Backup
```

**"jq nicht gefunden"**
```bash
# jq installieren
brew install jq              # macOS
sudo apt-get install jq      # Ubuntu/Debian
sudo yum install jq          # CentOS/RHEL
```

**"Keine Schreibberechtigung"**
```bash
# Berechtigungen prüfen
ls -la /path/to/backup/directory

# Verzeichnis erstellen
mkdir -p ~/backups/udm
chmod 755 ~/backups/udm
```

### SSH-Key Setup
```bash
# SSH-Key für UDM erstellen
ssh-keygen -t ed25519 -f ~/.ssh/udm_backup_key

# Public Key zur UDM kopieren
ssh-copy-id -i ~/.ssh/udm_backup_key.pub root@10.20.30.1

# Testen
ssh -i ~/.ssh/udm_backup_key root@10.20.30.1

# Script mit Key verwenden
./udm_backup -k ~/.ssh/udm_backup_key
```

### Debug-Modus
```bash
# Maximale Ausgabe
./udm_backup --verbose --dry-run

# SSH-Verbindung testen
ssh -v root@10.20.30.1

# SCP manuell testen
scp root@10.20.30.1:/mnt/data/unifi-os/unifi/data/backup/autobackup/* /tmp/
```

## 💡 Tipps & Best Practices

### Automatisierung
```bash
# Systemd Service erstellen
# /etc/systemd/system/udm-backup.service
[Unit]
Description=UDM Backup Service
After=network.target

[Service]
Type=oneshot
User=backup
ExecStart=/usr/local/bin/udm_backup
Environment=UDM_BACKUP_DIR=/var/backups/udm

# Timer für tägliche Ausführung
# /etc/systemd/system/udm-backup.timer
[Unit]
Description=Run UDM Backup daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

### Monitoring
```bash
# Backup-Alter überwachen
find /backup/udm -name "*.unf" -mtime +2 | mail -s "Old UDM Backup" admin@example.com

# Speicherplatz überwachen
df -h /backup/udm | awk 'NR==2 && $5 > "80%" {print "Disk usage: " $5}' | mail -s "Low Disk Space" admin@example.com
```

### Retention-Strategien
```bash
# Gestaffelte Retention
./udm_backup -r 7     # Wöchentlich - 7 Tage
./udm_backup -r 30    # Monatlich - 30 Tage  
./udm_backup -r 365   # Jährlich - 1 Jahr
```

## 📚 Verwandte Tools

- **[UniFi Controller Backup](https://help.ui.com/hc/en-us/articles/226218448)** - Offizielle Backup-Dokumentation
- **[unifi-tools](https://github.com/Art-of-WiFi/UniFi-API-browser)** - UniFi API Tools
- **[rclone](https://rclone.org/)** - Cloud-Storage-Sync für Backup-Replikation

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [UniFi Dream Machine Dokumentation](https://help.ui.com/hc/en-us/categories/200320654-UniFi-Network-Video)
- [UniFi Controller Backup Guide](https://help.ui.com/hc/en-us/articles/226218448-UniFi-How-to-Configure-Backup)
- [SSH Best Practices](https://wiki.mozilla.org/Security/Guidelines/OpenSSH)
