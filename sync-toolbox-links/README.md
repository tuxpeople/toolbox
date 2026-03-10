# sync-toolbox-links - Toolbox-Symlinks verwalten

Erstellt und aktualisiert Symlinks in `~/bin` für alle ausführbaren Scripts im Toolbox-Repo. Das Script verlinkt sich beim ersten Aufruf selbst und ist danach von überall aufrufbar.

## 🎯 Zweck

Anstatt Tools immer mit vollem Pfad aufzurufen, legt dieses Script Symlinks in `~/bin` an. So sind alle Toolbox-Scripts direkt als Befehle verfügbar. Es:

1. **Erkennt seinen eigenen Standort** im Repo und leitet ROOT daraus ab — kein Hardcoding nötig
2. **Erstellt fehlende Symlinks** für alle ausführbaren Dateien und Scripts (`.sh`, `.py`, `.pl`)
3. **Aktualisiert veraltete Links** die noch ins Repo zeigen, aber auf eine andere Datei
4. **Entfernt obsolete Links** wenn ein Tool aus dem Repo entfernt wurde
5. **Erkennt Namenskollisionen** und überspringt betroffene Einträge mit einer Warnung
6. **Bootstrapt sich selbst** — einmal direkt aus dem Repo aufrufen genügt

## 📋 Voraussetzungen

- **Bash 4+** (macOS: via Homebrew `brew install bash`)
- **`~/bin` im PATH** (für den direkten Aufruf nach dem ersten Bootstrapping)

## 🚀 Installation (Bootstrapping)

Einmalig direkt aus dem Repo aufrufen:

```bash
./sync-toolbox-links/sync-toolbox-links
```

Danach ist `sync-toolbox-links` selbst in `~/bin` verlinkt und kann von überall aufgerufen werden:

```bash
sync-toolbox-links
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
sync-toolbox-links [OPTIONEN]
```

### Optionen
- `-n, --dry-run` - Nur anzeigen, was gemacht würde (nichts ändern)
- `-q, --quiet` - Keine Ausgabe
- `--keep-ext` - Dateiendungen (.sh/.py/.pl) im Linknamen behalten
- `--no-chmod` - Fehlende x-Bits nicht setzen
- `--root DIR` - Alternatives Repo-Verzeichnis
- `--bin DIR` - Alternatives Zielverzeichnis (Standard: `~/bin`)
- `-h, --help` - Hilfe anzeigen

### Umgebungsvariablen
Alle Optionen können auch als Umgebungsvariablen gesetzt werden:
- `ROOT` - Repo-Verzeichnis
- `BIN` - Zielverzeichnis für Symlinks
- `KEEP_EXT=1` - Endungen behalten
- `DRYRUN=1` - Dry-Run Modus
- `VERBOSE=0` - Stille Ausgabe
- `CHMOD_EXEC=0` - x-Bits nicht setzen

## 📄 Ausgabe-Beispiel

```
$ sync-toolbox-links

✓ bereits korrekt: /Users/tdeutsch/bin/check-images
✓ bereits korrekt: /Users/tdeutsch/bin/fix-ssh-key
＋ linke timestamped-history → /Users/tdeutsch/bin/timestamped-history
↺ aktualisiere Link: /Users/tdeutsch/bin/kubectl-backup
－ entferne veralteten Link: /Users/tdeutsch/bin/old-tool
Fertig.
```

## 🔧 Funktionsweise

### Automatische ROOT-Erkennung
Das Script ermittelt seinen eigenen Standort im Repo und leitet daraus ROOT ab:
```
.../toolbox/sync-toolbox-links/sync-toolbox-links
              ↑ SCRIPT_DIR                ↑ Script
.../toolbox/
  ↑ ROOT (eine Ebene höher)
```

### Kandidaten-Erkennung
Alle Dateien mit exec-Bit oder Endung `.sh`, `.py`, `.pl` werden erfasst — ausser `README.*`, `LICENSE.*` und `CLAUDE.*`.

### Endungen
Standardmässig werden `.sh`, `.py`, `.pl` Endungen im Linknamen entfernt: `fix-perms.sh` wird zu `fix-perms`.

### Kollisionsschutz
Wenn zwei Dateien zum gleichen Linknamen führen würden (z.B. `tool` und `tool.sh`), werden beide übersprungen und eine Warnung ausgegeben.

### Aufräumen
Symlinks in `~/bin`, die ins Repo zeigen, aber zu keiner aktuellen Datei mehr gehören, werden automatisch entfernt.

## ⚠️ Hinweise

- **Externe Symlinks** in `~/bin` werden nicht angefasst — nur Links die ins Toolbox-Repo zeigen
- **Keine echten Dateien** werden überschrieben — nur Symlinks werden verwaltet
- **Bash 4+** erforderlich wegen `mapfile` und `${var,,}`

## 🔍 Troubleshooting

### "mapfile: command not found"
```bash
# Bash-Version prüfen
bash --version

# macOS: Homebrew-Bash installieren
brew install bash
# Dann direkt aufrufen:
/opt/homebrew/bin/bash sync-toolbox-links/sync-toolbox-links
```

### Symlink zeigt auf falsche Datei
```bash
# Dry-Run zeigt was geändert würde
sync-toolbox-links --dry-run
```

### Tool taucht nicht auf
```bash
# Executable-Bit prüfen
ls -la toolbox/tool-name/tool-name

# Setzen falls nötig
chmod +x toolbox/tool-name/tool-name
```

## 📚 Verwandte Tools

- **stow** - GNU Stow für Dotfile-Management via Symlinks
- **ln** - Standard Unix Symlink-Befehl
