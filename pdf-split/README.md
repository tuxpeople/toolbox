# pdf-split

Teilt ein PDF in einzelne Seiten auf.

## 🎯 Zweck

Dieses Tool teilt eine PDF-Datei in einzelne Seiten auf. Jede Seite wird als separate PDF-Datei gespeichert. Ideal für die Dokumenten-Verarbeitung, wenn einzelne Seiten eines PDFs benötigt werden.

**Originalquelle:** Dieses Tool basiert auf einem [Script von Matthew Hammond](https://gist.github.com/matthewshammond/23a217767ff93d733c8d11fff97b19f5) und wurde für die toolbox nach CLAUDE.md Standards angepasst und erweitert.

## 📋 Voraussetzungen

- **Python 3** mit venv-Modul
- **PyPDF2** wird automatisch in einem temporären Virtual Environment installiert

### Installation der Voraussetzungen

**macOS:**
```bash
brew install python3
```

**Linux (Debian/Ubuntu):**
```bash
apt install python3 python3-venv
```

**Linux (RHEL/CentOS):**
```bash
yum install python3 python3-venv
```

## 🚀 Installation

1. Repository klonen oder Script herunterladen:
```bash
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/pdf-split
```

2. Script ist bereits executable (sollte `chmod +x` sein)

## 💻 Verwendung

### Basis-Syntax

```bash
pdf-split [OPTIONEN] <input.pdf> <output_directory>
```

### Optionen

- **`-v, --verbose`** - Detaillierte Ausgabe
- **`-n, --dry-run`** - Nur anzeigen was gemacht würde (kein PDF wird erstellt)
- **`-p, --prefix PREFIX`** - Präfix für Ausgabe-Dateien (Standard: "page")
- **`-s, --start-page NUM`** - Erste zu extrahierende Seite (Standard: 1)
- **`-e, --end-page NUM`** - Letzte zu extrahierende Seite (Standard: alle)
- **`-h, --help`** - Hilfe anzeigen

### Beispiele

**Alle Seiten aufteilen:**
```bash
pdf-split document.pdf output/
```

**Mit eigenem Präfix:**
```bash
pdf-split --prefix doc document.pdf output/
# Erstellt: doc_1.pdf, doc_2.pdf, doc_3.pdf, ...
```

**Nur bestimmte Seiten extrahieren:**
```bash
pdf-split --start-page 5 --end-page 10 document.pdf output/
# Erstellt nur Seiten 5-10
```

**Dry-Run zum Testen:**
```bash
pdf-split --dry-run document.pdf output/
```

**Mit detaillierter Ausgabe:**
```bash
pdf-split --verbose document.pdf output/
```

**Kombinierte Optionen:**
```bash
pdf-split --verbose --prefix chapter --start-page 20 --end-page 30 book.pdf chapters/
```

## 📄 Ausgabe-Beispiel

### Standard-Ausgabe

```bash
$ pdf-split document.pdf output/
[INFO] PDF-Split wird gestartet
[INFO] Input: document.pdf
[INFO] Output: output/
[INFO] Präfix: page
[INFO] Richte Python Virtual Environment ein...
[INFO] Installiere PyPDF2...
[INFO] Teile PDF auf...
[SUCCESS] Erstellt: output/page_1.pdf
[SUCCESS] Erstellt: output/page_2.pdf
[SUCCESS] Erstellt: output/page_3.pdf
[SUCCESS] Fertig!
[INFO] Statistik: 3 erfolgreich, 0 Fehler, 3 gesamt
```

### Verbose-Ausgabe

```bash
$ pdf-split --verbose document.pdf output/
[INFO] PDF-Split wird gestartet
[INFO] Input: document.pdf
[INFO] Output: output/
[INFO] Präfix: page
[VERBOSE] Temporäres Verzeichnis: /tmp/tmp.abc123
[VERBOSE] Erstelle Python-Script
[INFO] Richte Python Virtual Environment ein...
[INFO] Installiere PyPDF2...
[INFO] Teile PDF auf...
[INFO] PDF hat 3 Seiten
[SUCCESS] Erstellt: output/page_1.pdf
[SUCCESS] Erstellt: output/page_2.pdf
[SUCCESS] Erstellt: output/page_3.pdf
[VERBOSE] Räume temporäre Dateien auf: /tmp/tmp.abc123
[SUCCESS] Fertig!
[INFO] Statistik: 3 erfolgreich, 0 Fehler, 3 gesamt
```

### Dry-Run-Ausgabe

```bash
$ pdf-split --dry-run document.pdf output/
[INFO] PDF-Split wird gestartet
[INFO] Input: document.pdf
[INFO] Output: output/
[INFO] Präfix: page
[INFO] DRY-RUN: Würde PDF aufteilen: document.pdf -> output/
[INFO] DRY-RUN: Präfix: page
[INFO] Richte Python Virtual Environment ein...
[INFO] Installiere PyPDF2...
[INFO] Führe PDF-Split aus (Dry-Run)...
[INFO] Würde erstellen: output/page_1.pdf
[INFO] Würde erstellen: output/page_2.pdf
[INFO] Würde erstellen: output/page_3.pdf
[SUCCESS] Fertig!
[INFO] Statistik: 3 erfolgreich, 0 Fehler, 3 gesamt
```

## 🔧 Funktionsweise

1. **Dependency-Check:** Prüft ob Python 3 und venv-Modul verfügbar sind
2. **Parameter-Validierung:** Validiert Input-Datei und Optionen
3. **Temporäres Environment:** Erstellt ein isoliertes Python Virtual Environment
4. **PyPDF2-Installation:** Installiert PyPDF2 automatisch im venv
5. **PDF-Verarbeitung:** Teilt das PDF in einzelne Seiten auf
6. **Cleanup:** Löscht automatisch alle temporären Dateien

Das Tool verwendet ein temporäres Virtual Environment, um keine Systemabhängigkeiten zu verändern. Nach der Ausführung werden alle temporären Dateien automatisch aufgeräumt.

## 🏢 Anwendungsfälle

### Dokumenten-Management
```bash
# Einzelne Rechnungen aus einem Sammel-PDF extrahieren
pdf-split --prefix invoice invoices_2024.pdf invoices/

# Nur relevante Seiten aus einem Report extrahieren
pdf-split --start-page 10 --end-page 15 --prefix summary report.pdf output/
```

### Scan-Verarbeitung
```bash
# Gescannte Dokumente in einzelne Seiten aufteilen
pdf-split scans.pdf pages/

# Mit sprechendem Präfix
pdf-split --prefix scan_20240127 scans.pdf archive/
```

### Dokumenten-Extraktion
```bash
# Einzelne Kapitel aus einem Buch extrahieren
pdf-split --start-page 50 --end-page 75 --prefix chapter_3 book.pdf chapters/

# Spezifische Seiten für Präsentationen
pdf-split --start-page 1 --end-page 5 presentation.pdf handout/
```

### Automatisierte Workflows
```bash
# In Kombination mit anderen Tools
for pdf in *.pdf; do
    pdf-split --verbose "$pdf" "split_$(basename "$pdf" .pdf)/"
done
```

## ⚠️ Hinweise

### Dateigrösse und Performance

- **Grosse PDFs:** Bei PDFs mit vielen Seiten (>100) kann die Verarbeitung etwas dauern
- **Komplexe PDFs:** PDFs mit vielen Bildern oder komplexen Layouts benötigen mehr Zeit
- **Speicherplatz:** Stelle sicher, dass genug Speicherplatz verfügbar ist (jede Seite = separate Datei)

### Datei-Überschreibung

- **Bestehende Dateien werden überschrieben:** Wenn im Output-Verzeichnis bereits Dateien mit gleichem Namen existieren, werden sie ohne Warnung überschrieben
- **Dry-Run verwenden:** Teste zuerst mit `--dry-run` um zu sehen, welche Dateien erstellt würden

### PDF-Kompatibilität

- **Passwort-geschützte PDFs:** Funktionieren nicht (PyPDF2-Limitation)
- **Beschädigte PDFs:** Können zu Fehlern führen
- **Sehr alte PDF-Versionen:** Können Probleme verursachen

### Sicherheit

- **Temporäre Dateien:** Werden automatisch aufgeräumt (auch bei Fehlern durch `trap`)
- **Virtual Environment:** Keine Systemveränderungen, alles isoliert
- **Keine externen Netzwerk-Calls:** Alles läuft lokal

## 🔍 Troubleshooting

### "Python venv-Modul nicht verfügbar"

**Problem:** Das venv-Modul ist nicht installiert.

**Lösung:**
```bash
# Linux (Debian/Ubuntu)
apt install python3-venv

# Linux (RHEL/CentOS)
yum install python3-venv
```

### "Input-Datei nicht gefunden"

**Problem:** Die angegebene PDF-Datei existiert nicht.

**Lösung:**
```bash
# Prüfe ob die Datei existiert
ls -la document.pdf

# Verwende absolute Pfade
pdf-split /absolute/path/to/document.pdf output/
```

### "Fehler beim Lesen der PDF"

**Problem:** Die PDF-Datei ist beschädigt oder passwortgeschützt.

**Lösung:**
```bash
# Prüfe die PDF mit anderen Tools
pdfinfo document.pdf

# Versuche die PDF zu reparieren (falls gs installiert)
gs -o repaired.pdf -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress document.pdf
pdf-split repaired.pdf output/
```

### "Start-Seite > Gesamt-Seiten"

**Problem:** Die angegebene Start-Seite existiert nicht im PDF.

**Lösung:**
```bash
# Prüfe zuerst die Anzahl Seiten
pdfinfo document.pdf | grep Pages

# Verwende --dry-run zum Testen
pdf-split --dry-run --start-page 1 document.pdf output/
```

### PyPDF2-Installation schlägt fehl

**Problem:** Netzwerkprobleme oder pip-Probleme.

**Lösung:**
```bash
# Prüfe Internet-Verbindung
ping pypi.org

# Teste pip manuell
python3 -m pip install --user PyPDF2

# Update pip
python3 -m pip install --upgrade pip
```

## 💡 Tipps & Tricks

### Batch-Verarbeitung

Alle PDFs in einem Verzeichnis aufteilen:
```bash
for pdf in *.pdf; do
    name=$(basename "$pdf" .pdf)
    pdf-split --prefix "${name}" "$pdf" "split_${name}/"
done
```

### Seiten-Bereich mit Offset

Wenn du Seiten 10-20 als Seiten 1-11 nummerieren willst:
```bash
pdf-split --start-page 10 --end-page 20 --prefix page document.pdf output/
# Erstellt: page_10.pdf, page_11.pdf, ..., page_20.pdf

# Oder mit eigenem Script renumbern
```

### Integration mit anderen Tools

Kombiniere mit anderen toolbox-Tools:
```bash
# PDF aufteilen und dann einzelne Seiten verarbeiten
pdf-split document.pdf pages/

# Dateigrössen prüfen
du -sh pages/*.pdf | sort -h

# Oder mit anderen PDF-Tools weiterverarbeiten
for page in pages/*.pdf; do
    # OCR, Komprimierung, etc.
    echo "Verarbeite: $page"
done
```

### Performance-Optimierung

Für sehr grosse PDFs (>500 Seiten):
```bash
# Teile in Batches auf
pdf-split --start-page 1 --end-page 100 --prefix batch1 huge.pdf output/
pdf-split --start-page 101 --end-page 200 --prefix batch2 huge.pdf output/
# etc.
```

### Verbose-Logging für Debugging

Bei Problemen:
```bash
pdf-split --verbose document.pdf output/ 2>&1 | tee pdf-split.log
```

## 📚 Verwandte Tools

### Ähnliche Tools in dieser Toolbox

Momentan keine anderen PDF-Tools in der Toolbox.

### Externe Tools

- **pdftk** - Umfangreiches PDF-Toolkit (Merge, Split, Rotate, etc.)
- **ghostscript (gs)** - PDF-Manipulation und -Konvertierung
- **qpdf** - PDF-Transformation und -Reparatur
- **pdfinfo** - PDF-Metadaten anzeigen

### Warum pdf-split?

- **Einfach:** Keine komplexe Installation, Python venv wird automatisch erstellt
- **Portabel:** Funktioniert auf macOS und Linux ohne Anpassungen
- **Standard-konform:** Folgt den toolbox CLAUDE.md Standards
- **Self-contained:** Keine globalen Python-Packages erforderlich

## 📜 Lizenz

MIT-Lizenz (siehe LICENSE im Repository-Root)

## 🙏 Credits

- **Originalautor:** [Matthew Hammond](https://gist.github.com/matthewshammond/23a217767ff93d733c8d11fff97b19f5)
- **Anpassung:** Umgesetzt nach toolbox CLAUDE.md Standards
- **Verbesserungen:** Erweiterte Optionen, Error-Handling, Dokumentation
