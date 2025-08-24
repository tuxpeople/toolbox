# Claude Code Anweisungen - Toolbox Repository

## 📋 Projekt-Kontext

Dieses Repository ist eine zentrale Sammlung von DevOps- und SysAdmin-Tools. Alle Scripts sind robust entwickelt und Enterprise-tauglich.

### Repository-Struktur
```
toolbox/
├── README.md                 # Haupt-Dokumentation
├── LICENSE                   # MIT-Lizenz
├── tool_name/
│   ├── tool_name            # Ausführbares Script (OHNE Dateiendung)
│   └── README.md            # Vollständige Tool-Dokumentation
└── CLAUDE.md                # Diese Datei
```

## 🛠️ Code-Standards

### Script-Organisation (ZWINGEND)
- **Eigener Ordner:** Jedes Script hat seinen eigenen Ordner
- **Bindestrich-Namen:** Tool-Namen verwenden Bindestriche (-), KEINE Unterstriche (_)
- **Keine Dateiendung:** Scripts haben KEINE Dateiendung (nicht .sh)
- **Executable:** Alle Scripts müssen ausführbar sein (`chmod +x`)
- **README.md:** Jedes Script hat ein README im gleichen Aufbau
- **Haupt-README:** Jedes Script ist im Haupt-README aufgeführt
- **Sicherheitshinweise:** Wo nötig in Haupt-README und Script-README

### Bash-Scripts
- **Immer verwenden:** `#!/usr/bin/env bash` und `set -euo pipefail`
- **Error-Handling:** Farbige Log-Funktionen (log_info, log_error, log_success, log_warn)
- **Dry-Run Modi:** Für alle destruktiven Operationen (`--dry-run`, `-n`)
- **Destructive Operations:** Immer Bestätigung verlangen, ausser Force-Modus aktiv
- **Backup-Erstellung:** Vor Änderungen an wichtigen Dateien
- **Abhängigkeits-Checks:** `check_dependencies()` Funktion
- **Hilfe-System:** `--help` und `-h` Parameter
- **Verbose-Modi:** `-v/--verbose` für detaillierte Ausgabe

### Python-Scripts
- **Shebang:** `#!/usr/bin/env python3`
- **Imports:** Alle System-Imports am Anfang der Datei
- **Error-Handling:** Try-catch mit aussagekräftigen Fehlermeldungen
- **Argument-Parsing:** `argparse` mit ausführlicher Hilfe

### Portabilität (ZWINGEND)
- **macOS/Linux Kompatibilität:** Alle Scripts müssen auf beiden Systemen funktionieren
- **BSD/GNU Tool-Unterschiede:** Berücksichtigen und testen (z.B. `stat`, `sed -i`)
- **Fallback-Funktionen:** Für externe Tools (z.B. `numfmt`, `dig`, `gsed`)
- **OS-Erkennung:** `uname` oder ähnliches für systemspezifische Pfade
- **GNU-Tools auf macOS:** Prüfung auf Brew-installierte Versionen (gsed, gawk, etc.)

## 📚 Dokumentations-Standards

### Deutsche Dokumentation (Schweiz-tauglich)
- **Alle README-Dateien auf Deutsch** mit Schweizer Rechtschreibung
- **Keine ß-Zeichen:** Immer "ss" verwenden (z.B. "muss" statt "muß")
- **Deutsche Kommentare** in Scripts (Schweiz-tauglich)
- **Deutsche Log-Ausgaben** (Schweiz-tauglich)
- **Englische Variablen-/Funktionsnamen** sind OK

### README.md Struktur (pro Tool)
1. **Titel & Kurzbeschreibung**
2. **🎯 Zweck** - Was macht das Tool?
3. **📋 Voraussetzungen** - Dependencies
4. **🚀 Installation** - Download-Anweisungen
5. **💻 Verwendung** - Syntax und Optionen
6. **📄 Ausgabe-Beispiel** - Beispiel-Output
7. **🔧 Funktionsweise** - Wie es funktioniert
8. **🏢 Anwendungsfälle** - Praktische Beispiele
9. **⚠️ Hinweise** - Sicherheit, Performance
10. **🔍 Troubleshooting** - Häufige Probleme
11. **💡 Tipps & Tricks** - Best Practices
12. **📚 Verwandte Tools** - Ähnliche/ergänzende Tools

### Beispiel-Code in README
- Immer mit `bash` oder entsprechender Sprache taggen
- Vollständige, ausführbare Beispiele
- Kommentare für komplexe Befehle

## 🔒 Sicherheits-Richtlinien

### Sensible Daten
- **Keine SSH-Keys, Passwörter oder Tokens** in Code oder Dokumentation
- **Beispiel-Konfigurationen** mit Platzhaltern
- **Warnungen** bei Scripts die Systemänderungen vornehmen

### Berechtigungen
- **Sudo-Anforderungen** klar dokumentieren
- **Minimal-Rechte-Prinzip** befolgen
- **Validierung** von Benutzereingaben

## 🧪 Test-Standards

### Manueller Test-Workflow
```bash
# Syntax-Check für alle Bash-Scripts
find . -name "*.sh" -exec bash -n {} \;

# ShellCheck (falls installiert)
find . -name "*.sh" -exec shellcheck {} \;

# Dry-Run Tests (wenn verfügbar)
./tool_name --dry-run --verbose
```

### Funktionalitäts-Sicherstellung
- **Rückwärts-Kompatibilität** bei Änderungen an bestehenden Tools
- **Erweiterte Features** sind erlaubt und erwünscht
- **Breaking Changes** nur nach ausdrücklicher Genehmigung

## 📦 Tool-spezifische Hinweise

### brewfile-commenter.sh
- Backup-Erstellung ist kritisch
- jq-Abhängigkeit prüfen
- Homebrew-API-Aufrufe können fehlschlagen

### crane_fqdn.sh
- crane-Binary erforderlich
- Netzwerk-Zugriff zu Registries nötig
- Temporäre Dateien automatisch löschen

### fix-perms.sh
- NUR auf macOS verwenden
- Sudo-Rechte erforderlich
- Backup-System ist essentiell
- SIP-Beschränkungen beachten

### fix-ssh-key
- SSH-Tools müssen verfügbar sein
- DNS-Auflösung optional aber hilfreich
- ~/.ssh/known_hosts Backup empfehlen

### k8s_vuln.sh
- trivy und kubectl Dependencies
- Kubernetes-Cluster-Zugriff erforderlich
- Performance bei grossen Clustern beachten

### serve_this
- Python 3.6+ erforderlich
- OpenSSL für HTTPS
- Selbstsignierte Zertifikate = Browser-Warnungen

### udm_backup
- SSH-Zugriff zur UniFi Dream Machine
- jq für JSON-Verarbeitung
- SCP-Transfer kann bei grossen Backups Zeit brauchen

## 🚀 Development-Workflow

### Bei Script-Änderungen
1. **Bestehende Funktionalität** vollständig verstehen
2. **Dry-Run Tests** implementieren/verwenden
3. **Error-Handling** für alle kritischen Operationen
4. **README.md** entsprechend aktualisieren
5. **Haupt-README.md** bei strukturellen Änderungen anpassen

### Bei neuen Tools (ZWINGEND - ALLE Schritte erforderlich!)
1. **Eigenen Ordner** erstellen: `tool-name/` (mit Bindestrichen!)
2. **Ausführbares Script:** `tool-name` (OHNE .sh Endung!)
3. **Script executable machen:** `chmod +x tool-name/tool-name`
4. **ZWINGEND: README.md erstellen** nach obiger Struktur im tool-name/ Ordner
5. **ZWINGEND: Haupt-README.md erweitern:**
   - Tool in "Verfügbare Tools" Sektion hinzufügen
   - Beispiel in "Schnellstart" Sektion hinzufügen
   - Eintrag in "Tool-Status" Tabelle hinzufügen
   - Abhängigkeiten in "Abhängigkeiten" Tabelle hinzufügen
6. **Sicherheitshinweise** hinzufügen (Haupt-README und Tool-README)
7. **macOS/Linux Kompatibilität** testen und sicherstellen

⚠️ **WICHTIG:** Ohne vollständige README.md (sowohl Tool-README als auch Haupt-README-Updates) ist ein Tool NICHT vollständig und darf nicht als fertig betrachtet werden!

## ⚠️ Wichtige Beachtungen

### Niemals ändern
- **LICENSE** Datei - MIT-Lizenz beibehalten
- **Kern-Funktionalität** bestehender Tools ohne Genehmigung

### Immer prüfen
- **Bindestrich-Namen** für Tools (nicht Unterstriche!)
- **Keine Dateiendungen** bei Scripts (nicht .sh!)
- **Executable-Rechte** gesetzt (`chmod +x`)
- **Portable Shebang-Zeilen** (`#!/usr/bin/env bash`)
- **macOS/Linux Kompatibilität** getestet
- **Schweizer Rechtschreibung** (kein ß)
- **Destructive Operations** mit Confirmation-Dialog
- **Error-Codes** für CI/CD-Integration
- **Help/Usage-Ausgaben** vollständig und korrekt
- **Beispiele** in README funktionieren wirklich
- **Sicherheitshinweise** wo erforderlich

### Performance-Überlegungen
- **Grosse Cluster/Dateien** - Timeout- und Progress-Mechanismen
- **Netzwerk-Operations** - Retry-Logic und Timeouts
- **Parallelisierung** wo sinnvoll (aber dokumentiert)

## 🎯 Qualitätskriterien

Ein Tool gilt als "✅ Ready" wenn:
- ✅ **Eigener Ordner** erstellt (mit Bindestrichen!)
- ✅ **Bindestrich-Namen** verwendet (keine Unterstriche!)
- ✅ **Keine Dateiendung** (.sh entfernt)
- ✅ **Executable-Rechte** gesetzt
- ✅ **macOS/Linux kompatibel** (getestet)
- ✅ **Schweizer Rechtschreibung** (kein ß)
- ✅ **Tool-README.md** vollständig nach Standard-Struktur erstellt
- ✅ **Haupt-README** komplett aktualisiert:
  - ✅ Tool in "Verfügbare Tools" aufgeführt
  - ✅ Beispiel in "Schnellstart" hinzugefügt
  - ✅ Eintrag in "Tool-Status" Tabelle
  - ✅ Abhängigkeiten in "Abhängigkeiten" Tabelle
- ✅ **Sicherheitshinweise** hinzugefügt (wo nötig)
- ✅ **Error-Handling** implementiert
- ✅ **Dry-Run Modus** verfügbar (`--dry-run`, `-n`)
- ✅ **Confirmation-Dialogs** für destructive Operations
- ✅ **Help-System** funktional (`--help`, `-h`)
- ✅ **Portable Implementation** (BSD/GNU-Tools berücksichtigt)
- ✅ **Beispiele getestet** und funktional

🚨 **KRITISCH:** Ohne vollständige Dokumentation (Tool-README + Haupt-README Updates) ist ein Tool NICHT fertig!

---

**Letzte Aktualisierung:** 2025-08-23  
**Version:** 1.2 - Verschärfte README-Anforderungen nach yt-get Erfahrung