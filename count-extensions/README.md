# count-extensions

Zaehlt rekursiv alle Dateiendungen in einem Verzeichnis und zeigt sie absteigend nach Haeufigkeit sortiert an.

## 🎯 Zweck

Dieses Tool durchsucht ein Verzeichnis rekursiv, ermittelt fuer jede gefundene Datei die Dateiendung und erstellt daraus eine nach Haeufigkeit absteigend sortierte Statistik. Nuetzlich, um sich einen schnellen Ueberblick zu verschaffen, welche Dateitypen in einem Projekt oder Verzeichnisbaum vorkommen (z.B. vor einem Cleanup, einer Migration oder um `.gitignore`-Regeln zu planen).

## 📋 Voraussetzungen

### Erforderliche Tools
- **find, sort, uniq, tr, awk** - POSIX-Standardtools, auf macOS und Linux vorinstalliert

### Installation der Abhängigkeiten

Keine Installation notwendig - alle Tools sind auf macOS und den gängigen Linux-Distributionen bereits vorhanden.

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/count-extensions

# Oder direkt herunterladen
curl -o count-extensions https://raw.githubusercontent.com/tuxpeople/toolbox/main/count-extensions/count-extensions
chmod +x count-extensions
```

## 💻 Verwendung

### Syntax

```bash
./count-extensions VERZEICHNIS [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-t, --top ANZAHL` | Nur die ANZAHL häufigsten Endungen anzeigen |
| `-j, --json` | Ausgabe als JSON statt als Tabelle |
| `-v, --verbose` | Detaillierte Ausgabe |
| `-h, --help` | Hilfe anzeigen |

### Argumente

- **VERZEICHNIS**: Zu durchsuchendes Verzeichnis (erforderlich)

## 📄 Ausgabe-Beispiel

### Standard-Verwendung

```bash
$ ./count-extensions ~/projects/toolbox

[INFO] Durchsuche Verzeichnis rekursiv ...
ANZAHL  ENDUNG
    23  md
     2  json
     1  rev
     1  pack
     1  idx
[SUCCESS] Fertig!
```

### Nur die Top 3 anzeigen

```bash
$ ./count-extensions . --top 3

[INFO] Durchsuche Verzeichnis rekursiv ...
ANZAHL  ENDUNG
    23  md
     2  json
     1  rev
[SUCCESS] Fertig!
```

### JSON-Ausgabe

```bash
$ ./count-extensions . --json

[INFO] Durchsuche Verzeichnis rekursiv ...
[{"extension":"md","count":23},{"extension":"json","count":2},{"extension":"rev","count":1}]
[SUCCESS] Fertig!
```

> Hinweis: Log-Meldungen gehen auf `stderr`, die eigentliche Ausgabe (Tabelle oder JSON) auf `stdout`. Damit laesst sich das Ergebnis problemlos weiterverarbeiten, z.B. mit `jq` oder in eine Datei umleiten.

## 🔧 Funktionsweise

1. **Rekursive Suche**: `find VERZEICHNIS -type f` listet alle regulären Dateien auf (Symlinks werden ignoriert)
2. **Endung extrahieren**: Vom Dateinamen wird alles nach dem letzten Punkt als Endung verwendet
3. **Versteckte Dateien**: Ein führender Punkt (z.B. bei `.bashrc`) wird ignoriert, damit solche Dateien nicht fälschlich als "Endung ohne Namen" gezählt werden - `.bashrc` hat somit keine Endung, `.tar.gz` wird korrekt als `gz` gezählt
4. **Normalisierung**: Endungen werden kleingeschrieben, damit `JPG` und `jpg` zusammengezählt werden
5. **Zählen & Sortieren**: `sort | uniq -c | sort -nr` zählt die Vorkommen und sortiert absteigend
6. **Optional Top-N**: Mit `--top` wird die Liste auf die häufigsten N Einträge gekürzt
7. **Optional JSON**: Mit `--json` wird das Ergebnis als JSON-Array von `{"extension": ..., "count": ...}` ausgegeben

## 🏢 Anwendungsfälle

### Schneller Ueberblick über einen Projektordner

```bash
./count-extensions ./mein-projekt
```

### Vorbereitung einer .gitignore

```bash
# Zeigt, welche generierten Dateitypen im Build-Verzeichnis anfallen
./count-extensions ./dist --top 15
```

### Weiterverarbeitung mit jq

```bash
# Häufigste Endung ermitteln
./count-extensions . --json | jq -r '.[0].extension'

# Alle Endungen mit mehr als 10 Vorkommen
./count-extensions . --json | jq '[.[] | select(.count > 10)]'
```

### Vergleich mehrerer Verzeichnisse

```bash
for dir in backend frontend docs; do
    echo "=== $dir ==="
    ./count-extensions "$dir" --top 5
done
```

## ⚠️ Hinweise

- **Nur reguläre Dateien**: Symlinks, Verzeichnisse und Spezialdateien werden nicht gezählt
- **Grosse Verzeichnisbäume**: Bei sehr vielen Dateien (z.B. `node_modules`) kann der Scan spürbar dauern - ggf. vorher ausschliessen (siehe Troubleshooting)
- **Gross-/Kleinschreibung**: Endungen werden case-insensitiv gezählt und immer klein ausgegeben

## 🔍 Troubleshooting

### Problem: "Verzeichnis existiert nicht"

**Symptom:**
```
[ERROR] Verzeichnis existiert nicht: ./nicht-vorhanden
```

**Lösung:**
```bash
# Pfad prüfen
ls -la ./nicht-vorhanden
```

### Problem: Scan dauert sehr lange

**Symptom:**
Bei grossen Verzeichnisbäumen (z.B. inkl. `node_modules`, `.git`) dauert der Durchlauf lange.

**Lösung:**
```bash
# Unerwünschte Verzeichnisse vorher aus dem Baum entfernen/kopieren
# oder in einer Kopie ohne node_modules/.git arbeiten
rsync -a --exclude node_modules --exclude .git ./projekt/ /tmp/projekt-clean/
./count-extensions /tmp/projekt-clean
```

### Problem: `--top` gibt einen Fehler

**Symptom:**
```
[ERROR] --top erwartet eine positive Zahl, erhalten: abc
```

**Lösung:**
Nur positive Ganzzahlen als Wert für `--top` verwenden, z.B. `--top 10`.

## 💡 Tipps & Tricks

### Ergebnis in eine Datei schreiben

```bash
./count-extensions . > extensions.txt
```

### Nur Log-Ausgaben unterdrücken

```bash
./count-extensions . 2>/dev/null
```

### Ergebnis als CSV weiterverarbeiten

```bash
./count-extensions . --json | jq -r '.[] | [.extension, .count] | @csv'
```

## 📚 Verwandte Tools

- **[find](https://linux.die.net/man/1/find)** - Dateien rekursiv suchen
- **[sanitize-text](../sanitize-text/)** - Text-Dateien von Unicode-Problemen säubern
- **[check-repo-checksum](../check-repo-checksum/)** - Prüfsummen von Dateien validieren

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
