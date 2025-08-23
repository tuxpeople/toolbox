# macOS User Permissions Repair Tool

Ein speziell für macOS entwickeltes Tool zur Reparatur von Benutzerverzeichnis-Berechtigungen. Löst häufige Berechtigungsprobleme nach System-Updates oder Migrationen.

## 🎯 Zweck

macOS-Benutzerverzeichnisse können nach verschiedenen Ereignissen beschädigte Berechtigungen haben:

1. **System-Updates** - macOS-Updates können Berechtigungen durcheinanderbringen
2. **Migrationen** - Time Machine Wiederherstellungen oder Benutzer-Migrationen
3. **Manuelle Änderungen** - Versehentliche chmod/chown-Befehle
4. **Drittanbieter-Software** - Programme die Systemberechtigungen ändern
5. **Festplatten-Reparaturen** - Nach Disk Utility Reparaturen

## 📋 Voraussetzungen

- **macOS** (alle Versionen ab 10.11 El Capitan)
- **sudo-Rechte** für Eigentümer-Änderungen
- **Administratorzugang** für systemweite Reparaturen

## 🚀 Installation

```bash
# Script herunterladen
curl -o fix-perms https://raw.githubusercontent.com/tuxpeople/toolbox/main/fix-perms/fix-perms
chmod +x fix-perms
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./fix-perms [options]
```

### Optionen
- `-u, --user USERNAME` - Spezifischen Benutzer reparieren
- `-d, --directory PATH` - Spezifisches Verzeichnis reparieren
- `--dry-run` - Nur anzeigen, was gemacht würde
- `--reset-umask` - Benutzer-umask zurücksetzen
- `--fix-acls` - ACLs (Access Control Lists) zurücksetzen
- `-v, --verbose` - Detaillierte Ausgabe

### Beispiele

**Standard-Reparatur (aktueller Benutzer):**
```bash
./fix-perms
```

**Spezifischen Benutzer reparieren:**
```bash
./fix-perms -u john
./fix-perms --user alice
```

**Nur bestimmtes Verzeichnis:**
```bash
./fix-perms -d /Users/john/Documents
./fix-perms --directory ~/Downloads
```

**Vorschau ohne Änderungen:**
```bash
./fix-perms --dry-run
./fix-perms --dry-run -v
```

**Vollständige Reparatur:**
```bash
./fix-perms --fix-acls --reset-umask -v
```

## 📄 Ausgabe-Beispiel

```bash
$ ./fix-perms --verbose

[INFO] macOS Berechtigungs-Reparatur gestartet
[INFO] Verwende aktuellen Console-Benutzer: john
[INFO] Benutzer: john (UID: 501, GID: 20)
[INFO] Verzeichnis: /Users/john
[INFO] Erstelle Backup der aktuellen Berechtigungen...
[SUCCESS] Backup erstellt: /tmp/permissions_backup_20250822_143052.txt
[INFO] Repariere Berechtigungen für: /Users/john
[INFO] Setze Eigentümer auf 501:20
[INFO] Setze ACLs zurück für: /Users/john
[INFO] Setze Standard-Berechtigungen
[INFO] Setze restriktive Berechtigungen für: .ssh
[INFO] Setze restriktive Berechtigungen für: .gnupg
[SUCCESS] Berechtigungen repariert für: /Users/john
[INFO] Backup verfügbar: /tmp/permissions_backup_20250822_143052.txt
[SUCCESS] Berechtigungs-Reparatur abgeschlossen!
[INFO] Empfehlung: System neu starten für vollständige Wirkung
```

## 🔧 Funktionsweise

### Standard-Berechtigungen (macOS-konform):

1. **Home-Verzeichnis** (`/Users/username`):
   - Berechtigung: `755` (rwxr-xr-x)
   - Eigentümer: Benutzer-UID:staff (20)

2. **Normale Verzeichnisse**:
   - Berechtigung: `755` (rwxr-xr-x)
   - Eigentümer: Benutzer-UID:staff (20)

3. **Normale Dateien**:
   - Berechtigung: `644` (rw-r--r--)
   - Eigentümer: Benutzer-UID:staff (20)

4. **Ausführbare Dateien**:
   - Berechtigung: `755` (rwxr-xr-x)
   - Ausführungsbit bleibt erhalten

5. **Private Verzeichnisse** (`.ssh`, `.gnupg`, etc.):
   - Berechtigung: `700` (rwx------)
   - Nur Eigentümer-Zugriff

### Workflow:

1. **System-Prüfung** - Bestätigt macOS
2. **Benutzer-Validierung** - Prüft Benutzer-Existenz
3. **Backup-Erstellung** - Sichert aktuelle Berechtigungen
4. **Eigentümer-Korrektur** - Setzt richtigen UID:GID
5. **ACL-Reset** - Entfernt komplexe Access Control Lists
6. **Standard-Berechtigungen** - Setzt macOS-Standard-Permissions
7. **Private-Verzeichnisse** - Spezialbehandlung für sensible Ordner

## 🏢 Anwendungsfälle

### Nach System-Updates
```bash
# macOS hat Berechtigungen durcheinandergebracht
./fix-perms --fix-acls --reset-umask
```

### Nach Time Machine Wiederherstellung
```bash
# Benutzer-Verzeichnis nach Migration reparieren
./fix-perms -u restored_user --verbose
```

### Nach manuellen Fehlern
```bash
# Versehentlich falsche chmod/chown-Befehle verwendet
./fix-perms -d /Users/john/Projects --dry-run  # Vorschau
./fix-perms -d /Users/john/Projects             # Reparieren
```

### Systemadministration
```bash
# Alle Benutzer in einer Organisation
for user in alice bob charlie; do
    ./fix-perms -u $user
done
```

### Development-Setup
```bash
# Development-Verzeichnis nach Git-Clone-Problemen
./fix-perms -d ~/Development
```

## 🔒 Sicherheitsfeatures

### Backup-System
- **Automatische Backups** vor jeder Änderung
- **Timestamp-basierte Namen** für eindeutige Identifikation
- **Vollständige Permission-Historie** in Backup-Dateien

### Validierung
- **macOS-Only** - Funktioniert nur auf macOS-Systemen
- **Benutzer-Existenz-Prüfung** - Validiert Benutzer vor Änderungen
- **Pfad-Validierung** - Warnt bei Verzeichnissen ausserhalb `/Users/`

### Dry-Run Modus
- **Sichere Vorschau** ohne Systemänderungen
- **Vollständige Befehlsanzeige** was ausgeführt würde
- **Risikofrei testen** vor echten Änderungen

## ⚠️ Wichtige Hinweise

### Sudo-Rechte erforderlich
```bash
# Das Script fragt automatisch nach sudo-Passwort für:
# - chown (Eigentümer-Änderungen)
# - chmod (Berechtigungs-Änderungen)
# - launchctl (umask-Einstellungen)
```

### System-Neustart empfohlen
```bash
# Nach grösseren Reparaturen empfiehlt sich ein Neustart
sudo reboot
```

### Private Verzeichnisse
Das Script behandelt diese Verzeichnisse speziell restriktiv:
- `.ssh` - SSH-Schlüssel und Konfiguration
- `.gnupg` - GPG-Schlüssel
- `.aws` - AWS-Credentials
- `.kube` - Kubernetes-Konfiguration

## 🔍 Troubleshooting

### Häufige Probleme

**"Operation not permitted"**
```bash
# System Integrity Protection (SIP) aktiv
# Lösung: Nur eigene Benutzerverzeichnisse bearbeiten
./fix-perms -d /Users/$USER
```

**"User does not exist"**
```bash
# Benutzer-Name prüfen
dscl . -list /Users | grep username

# Aktuellen Benutzer verwenden
./fix-perms  # ohne -u Parameter
```

**"Permission denied trotz sudo"**
```bash
# SIP-Status prüfen
csrutil status

# Eventuell macOS Recovery Mode nötig
```

**"Backup creation failed"**
```bash
# /tmp-Verzeichnis prüfen
ls -la /tmp/

# Alternative: Eigenes Backup erstellen
ls -laR /Users/$USER > ~/permissions_backup.txt
```

### Debug-Modus

```bash
# Maximale Ausgabe
./fix-perms --verbose --dry-run

# Einzelne Verzeichnisse testen
./fix-perms -d ~/Documents --dry-run -v

# Aktuellen Status prüfen
ls -la /Users/$USER
```

## 💡 Best Practices

### Vor grösseren Änderungen
```bash
# Immer erst Dry-Run
./fix-perms --dry-run

# Time Machine Backup
sudo tmutil startbackup

# Dann erst echte Reparatur
./fix-perms
```

### Regelmassige Wartung
```bash
# Monatliche Berechtigungs-Prüfung
./fix-perms --dry-run | grep "would be changed"

# Bei Problemen sofort reparieren
./fix-perms --fix-acls
```

### Enterprise-Deployment
```bash
#!/bin/bash
# IT-Script für alle Arbeitsplätze
for user in $(dscl . -list /Users | grep -v "^_"); do
    if [[ -d "/Users/$user" ]]; then
        ./fix-perms -u "$user"
    fi
done
```

## 📚 Technische Details

### macOS-spezifische Befehle
- **`dscl`** - Directory Service Command Line (Benutzer-Info)
- **`stat -f %Su /dev/console`** - Aktueller Console-Benutzer
- **`launchctl config`** - Systemweite Konfiguration
- **`diskutil resetUserPermissions`** - System-Level Reparatur

### Standard-GIDs auf macOS
- **20** - `staff` (Standard-Gruppe für Benutzer)
- **80** - `admin` (Administrator-Gruppe)
- **0** - `wheel` (Root-Gruppe)

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [macOS File System Permissions](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
- [Directory Service Command Line](https://ss64.com/osx/dscl.html)
- [macOS Security Guide](https://support.apple.com/guide/security/)