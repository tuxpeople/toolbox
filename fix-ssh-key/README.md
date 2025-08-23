# SSH Known Hosts Fixer

Ein robustes Bash-Script zur automatischen Reparatur und Aktualisierung von SSH Known Hosts. Löst häufige SSH-Verbindungsprobleme durch Host-Key-Änderungen.

## 🎯 Zweck

SSH-Verbindungen schlagen oft fehl, wenn sich Host-Keys ändern (Server-Neuinstallation, Key-Updates, etc.). Dieses Tool:

1. **Entfernt alte Host-Keys** aus `~/.ssh/known_hosts`
2. **Löst IP-Adressen auf** für vollständige Bereinigung
3. **Scannt neue Host-Keys** und fügt sie hinzu
4. **Unterstützt verschiedene Key-Typen** (RSA, ECDSA, Ed25519)
5. **Funktioniert mit Custom-Ports**

## 📋 Voraussetzungen

- **OpenSSH Tools** (ssh-keygen, ssh-keyscan) - normalerweise vorinstalliert
- **DNS-Tools** (dig, nslookup, oder host) für IP-Auflösung - optional

## 🚀 Installation

```bash
# Script herunterladen
curl -o fix-ssh-key https://raw.githubusercontent.com/tuxpeople/toolbox/main/fix-ssh-key/fix-ssh-key
chmod +x fix-ssh-key
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./fix-ssh-key <hostname|ip> [options]
```

### Optionen
- `-v, --verbose` - Detaillierte Ausgabe
- `-p, --port PORT` - SSH-Port (Standard: 22)  
- `-t, --type TYPE` - Schlüssel-Typen (rsa,ecdsa,ed25519)
- `-h, --help` - Hilfe anzeigen

### Beispiele

**Standard-Host-Key-Reparatur:**
```bash
./fix-ssh-key example.com
./fix-ssh-key 192.168.1.100
```

**Mit Custom-Port:**
```bash
./fix-ssh-key example.com -p 2222
./fix-ssh-key myserver.local --port 8022
```

**Nur bestimmte Key-Typen:**
```bash
./fix-ssh-key example.com -t rsa,ecdsa
./fix-ssh-key example.com --type ed25519
```

**Mit detaillierter Ausgabe:**
```bash
./fix-ssh-key example.com --verbose
./fix-ssh-key 192.168.1.100 -v -p 2222
```

## 📄 Ausgabe-Beispiel

```bash
$ ./fix-ssh-key example.com --verbose

[INFO] SSH Known Hosts Reparatur für example.com:22
[INFO] Entferne alte SSH-Schlüssel für example.com
[INFO] IP-Adresse aufgelöst: example.com -> 93.184.216.34
[INFO] Füge neue SSH-Schlüssel hinzu für example.com:22
[INFO] Ausgeführter Befehl: ssh-keyscan -t rsa -t ecdsa -t ed25519 example.com,93.184.216.34
[SUCCESS] Neue SSH-Schlüssel hinzugefügt
[INFO] Hinzugefügte Schlüssel:
[INFO]   example.com ssh-rsa AAAAB3NzaC1yc2EAAAA...
[INFO]   example.com ecdsa-sha2-nistp256 AAAAE2VjZHNh...
[INFO] Teste SSH-Verbindung zu example.com:22
[SUCCESS] SSH-Schlüssel erfolgreich aktualisiert
```

## 🔧 Funktionsweise

### Schritt-für-Schritt-Prozess:

1. **Validierung**
   - Prüft Abhängigkeiten (ssh-keygen, ssh-keyscan)
   - Validiert Hostname/IP und Port
   - Erstellt SSH-Verzeichnis falls nötig

2. **DNS-Auflösung**
   - Löst Hostnames zu IP-Adressen auf
   - Verwendet dig, nslookup, host oder getent
   - Fallback-Mechanismen für verschiedene Systeme

3. **Alte Keys entfernen**
   - Entfernt Hostname aus known_hosts
   - Entfernt auch aufgelöste IP-Adresse
   - Berücksichtigt Custom-Ports

4. **Neue Keys scannen**
   - Scannt alle angegebenen Key-Typen
   - Fügt Hostname und IP gleichzeitig hinzu
   - Validiert erfolgreiches Scannen

5. **Verbindungstest** (optional)
   - Testet SSH-Verbindung im verbose-Modus
   - Timeout-geschützt

## 🏢 Anwendungsfälle

### Server-Migration
```bash
# Nach Server-Neuinstallation
./fix-ssh-key production-server.com
./fix-ssh-key staging.example.com -p 2222
```

### Development-Setup
```bash
# Docker-Container mit wechselnden Keys
./fix-ssh-key localhost -p 2222

# Vagrant/VM-Setup
./fix-ssh-key 192.168.56.100
```

### CI/CD Pipelines
```bash
#!/bin/bash
# In Deployment-Scripts
for host in web1.example.com web2.example.com db.example.com; do
    ./fix-ssh-key $host
done
```

### Batch-Verarbeitung
```bash
# Mehrere Hosts reparieren
cat hosts.txt | while read host; do
    ./fix-ssh-key $host --verbose
done
```

## 🌐 Unterstützte Systeme

**Betriebssysteme:**
- Linux (alle Distributionen)
- macOS
- Windows (WSL, Git Bash, Cygwin)
- FreeBSD/OpenBSD

**SSH-Key-Typen:**
- **RSA** - Traditionell, weit verbreitet
- **ECDSA** - Moderner, effizienter
- **Ed25519** - Neueste Generation, empfohlen

**DNS-Auflösung:**
- dig (bevorzugt)
- nslookup (Fallback)
- host (Fallback)
- getent (System-Fallback)

## ⚠️ Hinweise

- **Backup empfohlen** - Das Script erstellt kein Backup von known_hosts
- **Netzwerk erforderlich** - Für Key-Scanning und DNS-Auflösung
- **Berechtigungen** - ~/.ssh/known_hosts muss beschreibbar sein
- **Erste Verbindung** - Bei völlig neuen Hosts wird Host-Key-Verification umgangen

## 🔍 Troubleshooting

### Häufige Probleme

**"ssh-keygen nicht gefunden"**
```bash
# OpenSSH installieren
# Ubuntu/Debian:
sudo apt-get install openssh-client

# macOS:
brew install openssh

# Windows:
# OpenSSH via Windows Features aktivieren
```

**"Keine SSH-Schlüssel erhalten"**
```bash
# Manuell testen
ssh-keyscan -t rsa example.com

# Port-Probleme prüfen
telnet example.com 22

# Firewall/Netzwerk prüfen
```

**"DNS-Auflösung fehlgeschlagen"**
```bash
# Mit IP-Adresse direkt versuchen
./fix-ssh-key 93.184.216.34

# DNS-Tools installieren
sudo apt-get install dnsutils  # dig
```

**"Permission denied" für known_hosts**
```bash
# Berechtigungen prüfen
ls -la ~/.ssh/known_hosts

# Reparieren
chmod 600 ~/.ssh/known_hosts
```

### Debug-Modus

```bash
# Maximale Ausgabe
./fix-ssh-key example.com --verbose

# Manueller Key-Scan
ssh-keyscan -v -t rsa example.com

# SSH-Verbindung testen
ssh -v -o StrictHostKeyChecking=yes example.com
```

## 💡 Tipps & Best Practices

### Automatisierung
```bash
# Als Alias in ~/.bashrc
alias fix-ssh='~/toolbox/fix-ssh-key/fix-ssh-key'

# In SSH-Config für problematische Hosts
Host problematic-server
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

### Sicherheit
```bash
# Backup vor Batch-Operationen
cp ~/.ssh/known_hosts ~/.ssh/known_hosts.backup

# Nur vertrauenswürdige Hosts
# Script prüft nicht die Authentizität der neuen Keys
```

### Performance
```bash
# Nur benötigte Key-Typen scannen
./fix-ssh-key example.com -t ed25519  # Schneller

# Timeout für langsame Hosts
timeout 30 ./fix-ssh-key slow-server.com
```

## 📚 Verwandte Tools

- **ssh-keygen** - SSH-Key-Management
- **ssh-keyscan** - Host-Key-Scanning
- **ssh-copy-id** - Public-Key-Installation
- **ssh-audit** - SSH-Sicherheits-Audit

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [OpenSSH Dokumentation](https://www.openssh.com/manual.html)
- [SSH Known Hosts Format](https://man.openbsd.org/sshd.8#SSH_KNOWN_HOSTS_FILE_FORMAT)
- [SSH Key-Typen Vergleich](https://goteleport.com/blog/comparing-ssh-keys/)