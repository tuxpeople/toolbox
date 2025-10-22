# sanitize-text

Text Sanitizer - Säubert Text-Dateien von speziellen Unicode-Zeichen und vereinheitlicht Formatierung.

## 🎯 Zweck

Dieses Tool säubert Text-Dateien von problematischen Unicode-Zeichen, vereinheitlicht Leerzeichen und typografische Zeichen, behält dabei aber Umlaute und Emojis bei. Ideal für die Bereinigung von kopierten Texten aus PDFs, Webseiten oder Word-Dokumenten.

## 📋 Voraussetzungen

### Erforderliche Tools
- **Python 3.6+** - Für Unicode-Verarbeitung

### Installation der Abhängigkeiten

**macOS:**
```bash
brew install python3
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install python3
```

**Linux (RHEL/CentOS):**
```bash
sudo yum install python3
```

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/sanitize-text

# Oder direkt herunterladen
curl -o sanitize-text https://raw.githubusercontent.com/tuxpeople/toolbox/main/sanitize-text/sanitize-text
chmod +x sanitize-text
```

## 💻 Verwendung

### Syntax

```bash
./sanitize-text INPUT [OUTPUT] [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-v, --verbose` | Detaillierte Ausgabe |
| `-h, --help` | Hilfe anzeigen |

### Argumente

- **INPUT**: Eingabe-Datei (erforderlich)
- **OUTPUT**: Ausgabe-Datei (optional, Standard: `INPUT.cleaned.txt`)

## 📄 Ausgabe-Beispiel

### Standard-Verwendung

```bash
$ ./sanitize-text messy-document.txt

[INFO] Säubere Text-Datei ...
Wrote cleaned text to: /path/to/messy-document.cleaned.txt
[SUCCESS] Text erfolgreich gesäubert
[INFO] Ausgabe: messy-document.cleaned.txt
```

### Mit spezifischer Ausgabedatei

```bash
$ ./sanitize-text input.txt clean-output.txt

[INFO] Säubere Text-Datei ...
Wrote cleaned text to: /path/to/clean-output.txt
[SUCCESS] Text erfolgreich gesäubert
[INFO] Ausgabe: clean-output.txt
```

### Verbose-Modus

```bash
$ ./sanitize-text document.txt --verbose

[VERBOSE] Python-Version: 3.11
[VERBOSE] Eingabedatei: document.txt
[VERBOSE] Ausgabedatei: document.cleaned.txt
[INFO] Säubere Text-Datei ...
Wrote cleaned text to: /path/to/document.cleaned.txt
[SUCCESS] Text erfolgreich gesäubert
[INFO] Ausgabe: document.cleaned.txt
```

### Vorher/Nachher Beispiel

**Eingabe** (mit speziellen Unicode-Zeichen):
```
Das ist ein Test mit "smarten Quotes" und – Gedankenstrichen.
Preis: 49,99€   (mit  mehrfachen    Leerzeichen)
Ä Ö Ü ä ö ü ß bleiben erhalten! 😊🎉
```

**Ausgabe** (gesäubert):
```
Das ist ein Test mit "smarten Quotes" und - Gedankenstrichen.
Preis: 49,99EUR (mit mehrfachen Leerzeichen)
Ä Ö Ü ä ö ü ss bleiben erhalten! 😊🎉
```

## 🔧 Funktionsweise

Das Tool führt folgende Transformationen durch:

### 1. Unicode-Normalisierung
- **NFKC-Normalisierung**: Vereinheitlicht Unicode-Zeichen
- **Kompatibilitätsmapping**: Konvertiert spezielle Varianten zu Standard-Zeichen

### 2. Leerzeichen-Vereinheitlichung
Konvertiert zu normalem Space:
- `\u00A0` - Non-Breaking Space (NBSP)
- `\u202F` - Narrow Non-Breaking Space
- `\u2007` - Figure Space
- `\u2008` - Punctuation Space
- `\u2009` - Thin Space
- `\u200A` - Hair Space
- `\u2002-\u2006` - EN/EM/Three-Per-EM Spaces
- `\u205F` - Medium Mathematical Space
- `\u3000` - Ideographic Space
- `\u180E` - Mongolian Vowel Separator
- `\u2000-\u2001` - Weitere Space-Varianten

### 3. Typografische Zeichen zu ASCII
- **Smarte Quotes**: `"` `"` `'` `'` → `"` `'`
- **Guillemets**: `«` `»` → `"`
- **Dashes**: `–` (EN-Dash), `—` (EM-Dash), `−` (Minus) → `-`
- **Primes**: `′` `″` → `'` `"`

### 4. Währungssymbole
- `€` → `EUR`
- `£` → `GBP`
- `¥` → `JPY`
- `₩` → `KRW`
- `₽` → `RUB`
- `₹` → `INR`
- `₿` → `BTC`
- `¢` → `c`

### 5. Spezielle Buchstaben
- `ß` → `ss` (Schweizer Rechtschreibung)
- `Æ` `æ` → `AE` `ae`
- `Ø` `ø` → `O` `o`
- `Đ` `đ` → `D` `d`
- `Ł` `ł` → `L` `l`
- `Þ` `þ` → `Th` `th`
- `Œ` `œ` → `OE` `oe`

### 6. Was BLEIBT erhalten
- ✅ **ASCII-Zeichen** (0x20-0x7E)
- ✅ **Umlaute**: Ä Ö Ü ä ö ü
- ✅ **Akzentbuchstaben**: à é è ñ ô etc. (Latin-1 Supplement, Latin Extended-A/B)
- ✅ **Emojis**: 😊 🎉 👍 etc.
- ✅ **Emoji-Modifikatoren**: Hauttöne, ZWJ-Sequenzen
- ✅ **Flaggen**: 🇨🇭 🇩🇪 etc.
- ✅ **Zeilenumbrüche**: `\n` `\r`
- ✅ **Tabs**: `\t`

### 7. Whitespace-Kollabierung
- Mehrfache Leerzeichen → Ein Leerzeichen
- Führende/Trailing Leerzeichen entfernt (pro Zeile)
- Zeilenstruktur bleibt erhalten

## 🏢 Anwendungsfälle

### PDF-Text säubern

```bash
# Text aus PDF extrahiert (mit vielen Unicode-Problemen)
./sanitize-text extracted-from-pdf.txt clean-text.txt
```

### Webseiten-Content bereinigen

```bash
# HTML → Text kopiert, mit speziellen Zeichen
pbpaste > clipboard.txt  # macOS
./sanitize-text clipboard.txt cleaned.txt
cat cleaned.txt | pbcopy  # Zurück in Clipboard
```

### Batch-Verarbeitung mehrerer Dateien

```bash
#!/bin/bash
# Alle .txt Dateien im Verzeichnis säubern

for file in *.txt; do
    echo "Processing: $file"
    ./sanitize-text "$file" "cleaned_${file}"
done
```

### Word-Dokument-Export bereinigen

```bash
# Nach Word → Plain Text Export
./sanitize-text word-export.txt --verbose
```

### Markdown-Dateien normalisieren

```bash
# README mit kopierten Texten säubern
./sanitize-text README.md README-clean.md
mv README-clean.md README.md
```

### E-Mail-Text säubern

```bash
# E-Mail mit formatiertem Text
./sanitize-text email-body.txt email-clean.txt
```

### CI/CD Integration

```bash
#!/bin/bash
# Säubere alle Dokumentations-Dateien vor Commit

find docs/ -name "*.md" -type f | while read -r file; do
    ./sanitize-text "$file" "${file}.tmp"
    mv "${file}.tmp" "$file"
done

git add docs/
git commit -m "Sanitize documentation files"
```

## ⚠️ Hinweise

### Encoding
- **Input**: Erwartet UTF-8 Encoding
- **Output**: Schreibt UTF-8 Encoding
- Bei anderen Encodings: Zuerst mit `iconv` konvertieren

```bash
# Latin-1 zu UTF-8
iconv -f ISO-8859-1 -t UTF-8 input.txt | ./sanitize-text - output.txt
```

### Dateigrösse
- **Empfohlen**: Bis 10 MB
- **Maximum**: Systemabhängig (RAM)
- Für sehr grosse Dateien: In Chunks verarbeiten

### Backup
- Original-Datei wird NICHT modifiziert
- Neue Datei wird erstellt
- Bei gleicher Ausgabedatei: Wird überschrieben

### Umkehrbarkeit
- ⚠️ **Nicht umkehrbar**: Originalzeichen gehen verloren
- Teste zuerst mit Kopien
- Für kritische Dokumente: Original behalten

## 🔍 Troubleshooting

### Problem: "Python 3.6+ erforderlich"

**Symptom:**
```
[ERROR] Python 3.6+ erforderlich (gefunden: 3.5)
```

**Lösung:**
```bash
# Python-Version prüfen
python3 --version

# Python 3.6+ installieren
# macOS
brew install python@3.11

# Linux
sudo apt install python3.11
```

### Problem: "Eingabedatei nicht gefunden"

**Symptom:**
```
[ERROR] Eingabedatei nicht gefunden: myfile.txt
```

**Lösung:**
```bash
# Prüfe Dateipfad
ls -l myfile.txt

# Verwende absoluten Pfad
./sanitize-text /absolute/path/to/myfile.txt
```

### Problem: "UnicodeDecodeError"

**Symptom:**
```
UnicodeDecodeError: 'utf-8' codec can't decode byte...
```

**Mögliche Ursachen:**
- Datei ist nicht UTF-8 encoded
- Datei ist binär

**Lösung:**
```bash
# Encoding prüfen
file -i input.txt

# Nach UTF-8 konvertieren (wenn Latin-1)
iconv -f ISO-8859-1 -t UTF-8 input.txt > input-utf8.txt
./sanitize-text input-utf8.txt

# Nach UTF-8 konvertieren (wenn Windows-1252)
iconv -f WINDOWS-1252 -t UTF-8 input.txt > input-utf8.txt
./sanitize-text input-utf8.txt
```

### Problem: "Spezielle Zeichen verschwinden"

**Symptom:**
Wichtige Sonderzeichen wurden entfernt

**Erklärung:**
Das ist beabsichtigt. Das Tool entfernt nicht-lateinische Zeichen ausser Emojis.

**Lösung:**
Falls du bestimmte Zeichen behalten willst, musst du das Script anpassen:
```python
# In der is_emoji_cp() oder special_letter_map Funktion
# Füge deine Zeichen hinzu
```

### Problem: "Umlaute wurden ASCII-fiziert"

**Symptom:**
Umlaute wie ä ö ü wurden entfernt

**Erklärung:**
Das sollte NICHT passieren. Umlaute bleiben standardmässig erhalten.

**Lösung:**
```bash
# Teste mit einem einfachen Beispiel
echo "Ä Ö Ü ä ö ü" > test.txt
./sanitize-text test.txt test-out.txt
cat test-out.txt
# Sollte ausgeben: Ä Ö Ü ä ö ü

# Falls Problem besteht: Bug-Report erstellen
```

## 💡 Tipps & Tricks

### Pipeline-Verarbeitung (STDIN/STDOUT)

```bash
# Aus Clipboard (macOS)
pbpaste | ./sanitize-text /dev/stdin /dev/stdout | pbcopy

# Mit anderen Tools kombinieren
cat input.txt | ./sanitize-text /dev/stdin /dev/stdout | grep "pattern"
```

### Git Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Sanitize all staged Markdown files
git diff --cached --name-only --diff-filter=ACM | grep '\.md$' | while read file; do
    ./sanitize-text "$file" "${file}.tmp"
    mv "${file}.tmp" "$file"
    git add "$file"
done
```

### Watch-Modus für Entwicklung

```bash
# Automatisch säubern wenn Datei ändert (mit fswatch)
fswatch -o input.txt | while read; do
    ./sanitize-text input.txt output.txt
    echo "File sanitized at $(date)"
done
```

### Vorschau vor Änderung

```bash
# Diff zwischen Original und gesäubert anzeigen
./sanitize-text input.txt input.cleaned.txt
diff -u input.txt input.cleaned.txt | less
```

### Batch mit Fehlerbehandlung

```bash
#!/bin/bash
# Säubere alle Dateien mit Fehlerbehandlung

for file in *.txt; do
    if [ -f "$file" ]; then
        if ./sanitize-text "$file" "cleaned_${file}"; then
            echo "✅ $file"
        else
            echo "❌ $file FAILED"
        fi
    fi
done
```

## 📚 Verwandte Tools

- **[iconv](https://linux.die.net/man/1/iconv)** - Character encoding conversion
- **[dos2unix](https://linux.die.net/man/1/dos2unix)** - Konvertiert DOS/Windows Zeilenenden zu Unix
- **[recode](https://linux.die.net/man/1/recode)** - Character set conversion
- **[uconv](http://manpages.ubuntu.com/manpages/focal/man1/uconv.1.html)** - Unicode character set converter
- **[sed](https://linux.die.net/man/1/sed)** - Stream editor für Text-Transformationen
- **[tr](https://linux.die.net/man/1/tr)** - Translate oder delete characters

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
