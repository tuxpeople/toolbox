# Serve This - Local Development Server

Ein vielseitiger HTTP/HTTPS-Server für schnelle lokale Entwicklung, File-Sharing und Prototyping.

## 🎯 Zweck

Manchmal braucht man schnell einen lokalen Webserver um:

1. **Statische Dateien servieren** (HTML, CSS, JS, Images)
2. **APIs testen** die HTTPS erfordern
3. **Dateien im Netzwerk teilen**
4. **CORS-Probleme umgehen**
5. **Mobile Geräte testen** (über lokales Netzwerk)

## 📋 Voraussetzungen

- **Python 3.6+** (normalerweise vorinstalliert)
- **OpenSSL** für HTTPS (normalerweise vorinstalliert):
  ```bash
  # macOS
  brew install openssl
  
  # Ubuntu/Debian
  sudo apt-get install openssl
  ```

## 🚀 Installation

```bash
# Script herunterladen
curl -o serve_this https://raw.githubusercontent.com/tuxpeople/toolbox/main/serve_this/serve_this
chmod +x serve_this
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./serve_this [options]
```

### Grundlegende Optionen
- `-d, --directory DIR` - Zu servierendes Verzeichnis
- `-p, --port PORT` - Port (Standard: 8443 HTTPS, 8000 HTTP)
- `-i, --interface IP` - Interface (Standard: 0.0.0.0)
- `--http` - HTTP statt HTTPS verwenden
- `-v, --verbose` - Detaillierte Ausgabe

### SSL/HTTPS Optionen
- `--cert FILE` - Eigene SSL-Zertifikatsdatei
- `--key FILE` - Eigene SSL-Key-Datei  
- `--subject SUBJECT` - Custom SSL-Subject
- `--keep-certs` - Temporäre Zertifikate nicht löschen

### Beispiele

**Einfachster Start:**
```bash
./serve_this                    # HTTPS auf Port 8443
./serve_this --http             # HTTP auf Port 8000
```

**Verschiedene Verzeichnisse:**
```bash
./serve_this -d /path/to/website
./serve_this -d ./dist          # Build-Output servieren
./serve_this -d ~/Downloads     # Downloads-Ordner teilen
```

**Custom Ports:**
```bash
./serve_this -p 3000            # HTTPS auf Port 3000
./serve_this --http -p 8080     # HTTP auf Port 8080
```

**Nur lokal erreichbar:**
```bash
./serve_this -i 127.0.0.1       # Nur localhost
./serve_this -i 192.168.1.100   # Bestimmte IP
```

**Eigene SSL-Zertifikate:**
```bash
./serve_this --cert mycert.pem --key mykey.pem
```

## 📄 Ausgabe-Beispiel

```bash
$ ./serve_this -d ./my-website

[INFO] Generiere selbstsigniertes SSL-Zertifikat...
[SUCCESS] SSL-Zertifikat erstellt: /tmp/tmp8x9k2j3f.pem
[INFO] Serviere Verzeichnis: /Users/dev/my-website
[SUCCESS] HTTPS-Server gestartet!
===========================================
📁 Verzeichnis: /Users/dev/my-website
🌐 Zugriff:
   Lokal:    https://localhost:8443/
   Netzwerk: https://192.168.1.100:8443/
🔑 Protokoll: HTTPS
⚠️  Selbstsigniertes Zertifikat - Browser-Warnung erwartet
===========================================
Zum Beenden: Ctrl+C

[INFO] 192.168.1.101 - "GET / HTTP/1.1" 200 -
[INFO] 192.168.1.101 - "GET /style.css HTTP/1.1" 200 -
```

## 🔧 Funktionsweise

### HTTPS (Standard-Modus):
1. **Zertifikat generieren** - Erstellt selbstsigniertes SSL-Zertifikat
2. **Server starten** - Bindet an angegebenen Port
3. **Requests verarbeiten** - Serviert Dateien mit Security-Headers
4. **Cleanup** - Löscht temporäre Zertifikate bei Beendigung

### HTTP (Alternative):
1. **Server starten** - Ohne SSL-Overhead
2. **Requests verarbeiten** - Einfacher HTTP-Server
3. **Logging** - Zeigt alle Zugriffe an

### Security Features:
- **Security Headers** - X-Content-Type-Options, X-Frame-Options, X-XSS-Protection
- **SSL/TLS** - Verschlüsselte Verbindungen
- **Path Validation** - Schutz vor Directory Traversal

## 🏢 Anwendungsfälle

### Frontend-Entwicklung
```bash
# React/Vue/Angular Build servieren
npm run build
./serve_this -d ./dist

# Live-Development mit HTTPS
./serve_this -d ./src
```

### API-Testing
```bash
# Mock-API mit HTTPS für Service Worker Tests
./serve_this -d ./mock-api --cert api.pem --key api.key
```

### File-Sharing
```bash
# Dateien im Netzwerk teilen
./serve_this -d ~/Documents/shared -p 8080

# Sichere Übertragung mit HTTPS
./serve_this -d ./confidential --interface 192.168.1.100
```

### Mobile Testing
```bash
# Für Smartphone-Tests im lokalen Netzwerk
./serve_this -d ./mobile-app
# Dann https://192.168.1.100:8443 auf dem Smartphone
```

### CI/CD Integration
```bash
#!/bin/bash
# Test-Server für E2E-Tests
./serve_this -d ./build --http -p 3001 &
SERVER_PID=$!

# Tests ausführen
npm run e2e

# Server beenden
kill $SERVER_PID
```

## 🌐 Netzwerk-Features

### Automatische IP-Erkennung
- Zeigt lokale und Netzwerk-URLs an
- Funktioniert mit WiFi und Ethernet
- Unterstützt IPv4

### Interface-Binding
```bash
./serve_this -i 0.0.0.0         # Alle Interfaces
./serve_this -i 127.0.0.1       # Nur localhost  
./serve_this -i 192.168.1.100   # Spezifische IP
```

### Port-Management
- Automatische Port-Standards (8443/8000)
- Validierung und Fehlerbehandlung
- Unterstützung für privilegierte Ports (mit sudo)

## ⚠️ Hinweise

### Sicherheit
- **Selbstsignierte Zertifikate** lösen Browser-Warnungen aus
- **Kein Passwort-Schutz** - alle Dateien öffentlich zugänglich
- **Lokale Entwicklung** - nicht für Production geeignet

### Performance
- **Single-threaded** - für leichte Entwicklungs-Workloads
- **Keine Caching-Headers** - Browser cachen möglicherweise nicht optimal
- **Temporäre Zertifikate** - werden bei jedem Start neu erstellt

## 🔍 Troubleshooting

### Häufige Probleme

**"Port bereits in Verwendung"**
```bash
# Anderen Port verwenden
./serve_this -p 9000

# Prozess finden und beenden
lsof -ti:8443 | xargs kill
```

**"Permission denied für Port"**
```bash
# Port > 1024 verwenden
./serve_this -p 8080

# Oder mit sudo (nicht empfohlen)
sudo ./serve_this -p 443
```

**"OpenSSL nicht gefunden"**
```bash
# macOS
brew install openssl

# Ubuntu/Debian
sudo apt-get install openssl

# Oder HTTP verwenden
./serve_this --http
```

**"SSL-Zertifikat Fehler"**
```bash
# HTTP als Fallback
./serve_this --http

# Eigenes Zertifikat verwenden
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes
./serve_this --cert cert.pem --key key.pem
```

### Browser-Warnungen bei HTTPS

**Chrome/Safari:**
- Klick auf "Erweitert" → "Trotzdem fortfahren"
- Oder Zertifikat zu Keychain hinzufügen

**Firefox:**
- Klick auf "Erweitert" → "Risiko akzeptieren und fortfahren"

### Debug-Modus
```bash
# Detaillierte Ausgabe
./serve_this --verbose

# Python direkt für weitere Debug-Info
python3 serve_this --verbose
```

## 💡 Tipps & Tricks

### Dauerhaftes Zertifikat
```bash
# Einmal erstellen
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj "/CN=localhost"

# Immer verwenden
alias serve='./serve_this --cert server.crt --key server.key'
```

### Alias für häufige Verwendung
```bash
# In ~/.bashrc oder ~/.zshrc
alias serve='~/toolbox/serve_this/serve_this'
alias serve-http='~/toolbox/serve_this/serve_this --http'
alias serve-build='~/toolbox/serve_this/serve_this -d ./build'
```

### QR-Code für Mobile Testing
```bash
# QR-Code für URL generieren (macOS)
echo "https://$(ifconfig | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | head -1):8443" | qrencode -t utf8
```

## 📚 Verwandte Tools

- **[Python http.server](https://docs.python.org/3/library/http.server.html)** - Basis-HTTP-Server
- **[Live Server](https://github.com/ritwickdey/vscode-live-server)** - VS Code Extension
- **[Serve](https://github.com/vercel/serve)** - Node.js Alternative
- **[Caddy](https://caddyserver.com/)** - Production-ready Server

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [Python HTTP Server Dokumentation](https://docs.python.org/3/library/http.server.html)
- [OpenSSL Dokumentation](https://www.openssl.org/docs/)
- [SSL/TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)