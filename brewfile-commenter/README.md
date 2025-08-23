# Brewfile Commenter

Ein intelligentes Bash-Script, das automatisch Beschreibungen zu allen brew- und cask-Einträgen in einem Brewfile hinzufügt.

## 🎯 Zweck

Brewfiles sind praktisch für die Verwaltung von Homebrew-Paketen, aber oft ist nicht klar, was ein bestimmtes Paket macht. Dieses Tool fügt automatisch Beschreibungen hinzu:

**Vorher:**
```ruby
brew "jq"
brew "wget"
cask "docker"
```

**Nachher:**
```ruby
brew "jq" # Command-line JSON processor
brew "wget" # Internet file retriever
cask "docker" # Pack, ship and run any application as a lightweight container
```

## 📋 Voraussetzungen

- **Homebrew** muss installiert sein
- **jq** für JSON-Verarbeitung:
  ```bash
  brew install jq
  ```

## 🚀 Installation

```bash
# Script herunterladen
curl -o brewfile-commenter https://raw.githubusercontent.com/tuxpeople/toolbox/main/brewfile-commenter/brewfile-commenter
chmod +x brewfile-commenter
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./brewfile-commenter [Brewfile]
```

### Beispiele

**Standard Brewfile verarbeiten:**
```bash
./brewfile-commenter
```

**Spezifisches Brewfile verarbeiten:**
```bash
./brewfile-commenter MyBrewfile
./brewfile-commenter /path/to/custom/Brewfile
```

**Mit Hilfe:**
```bash
./brewfile-commenter --help
```

## 📄 Ausgabe-Beispiel

```bash
$ ./brewfile-commenter

[INFO] Backup erstellt: Brewfile.backup.20250822_143052
[INFO] Verarbeite Brewfile...
[INFO] TAP-Einträge kopiert
[INFO] Verarbeite brew-Einträge...
[INFO] Verarbeite brew package: jq
[INFO] Verarbeite brew package: wget
[INFO] Verarbeite cask-Einträge...
[INFO] Verarbeite cask package: docker
[INFO] MAS-Einträge kopiert
[SUCCESS] Brewfile erfolgreich aktualisiert
[INFO] Verarbeitet: 3 packages
[SUCCESS] Verarbeitung abgeschlossen
[INFO] Original gesichert als: Brewfile.backup.20250822_143052
```

## 🔧 Funktionsweise

1. **Backup erstellen** - Automatisches Backup vor Änderungen
2. **TAP-Einträge** - Werden unverändert kopiert
3. **Brew-Pakete** - Beschreibungen via `brew info --json=v2` abrufen
4. **Cask-Pakete** - Beschreibungen via `brew info --json=v2` abrufen  
5. **MAS-Einträge** - Werden unverändert kopiert (App Store)
6. **Kommentare** - Bestehende Kommentare bleiben erhalten

## 🏢 Anwendungsfälle

### Dokumentation für Teams
```bash
# Brewfile für das Team dokumentieren
./brewfile-commenter team-brewfile
git add team-brewfile
git commit -m "Add package descriptions to team brewfile"
```

### Aufräumen alter Brewfiles
```bash
# Verstehen was in einem alten Brewfile steht
./brewfile-commenter legacy-brewfile
# Jetzt kann man sehen, welche Pakete noch benötigt werden
```

### Onboarding neuer Entwickler
```bash
# Entwickler-Setup dokumentieren
./brewfile-commenter developer-setup
# Neue Teammitglieder verstehen sofort, was installiert wird
```

## ⚠️ Hinweise

- **Backup automatisch** - Das Script erstellt immer ein Backup vor Änderungen
- **Netzwerk erforderlich** - Beschreibungen werden live von Homebrew abgerufen
- **Bestehende Kommentare** - Werden respektiert und nicht überschrieben
- **Fehlertoleranz** - Bei fehlgeschlagenen Paketen wird "No description available" verwendet

## 🔍 Troubleshooting

### Häufige Probleme

**"jq nicht gefunden"**
```bash
brew install jq
```

**"Brewfile nicht gefunden"**
```bash
# Prüfen ob Datei existiert
ls -la Brewfile

# Spezifischen Pfad angeben
./brewfile-commenter /path/to/Brewfile
```

**"Keine Beschreibung verfügbar"**
```bash
# Manuell prüfen
brew info package-name

# Eventuell ist das Paket veraltet oder nicht mehr verfügbar
```

**Wiederherstellung bei Problemen:**
```bash
# Backup wiederherstellen
mv Brewfile.backup.TIMESTAMP Brewfile
```

## 💡 Tipps

- **Regelmassig ausführen** - Nach Updates des Brewfiles
- **Version Control** - Änderungen in Git committen
- **Team-Workflow** - Als Teil des CI/CD für Brewfile-Updates

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [Homebrew Bundle Dokumentation](https://github.com/Homebrew/homebrew-bundle)
- [Brewfile Format](https://docs.brew.sh/Manpage#bundle-subcommand)
- [jq Manual](https://stedolan.github.io/jq/manual/)