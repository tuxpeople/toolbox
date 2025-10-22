# youtube-to-obsidian

YouTube zu Obsidian Konverter - Erstellt strukturierte Zusammenfassungen von YouTube-Videos für Obsidian mit Claude CLI.

## 🎯 Zweck

Dieses Tool automatisiert die Erstellung von strukturierten Zusammenfassungen aus YouTube-Videos für Obsidian. Es nutzt Claude CLI (keine API-Kosten!) um intelligente Zusammenfassungen zu erstellen mit Fokus auf IT/DevOps/Kubernetes-Relevanz.

## 📋 Voraussetzungen

### Erforderliche Tools
- **yt-dlp** - Für Video-Metadaten und Transkripte
- **claude CLI** - Für Zusammenfassungen (Claude Code oder Claude Desktop)
- **Python 3.6+** - Für Script-Ausführung

### Installation der Abhängigkeiten

**macOS:**
```bash
# yt-dlp installieren
brew install yt-dlp

# Claude Code installieren (falls noch nicht vorhanden)
brew install claude-code

# Python ist meist vorinstalliert
python3 --version
```

**Linux:**
```bash
# yt-dlp installieren
pip3 install yt-dlp

# Python prüfen
python3 --version
```

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/youtube-to-obsidian

# Oder direkt herunterladen
curl -o youtube-to-obsidian https://raw.githubusercontent.com/tuxpeople/toolbox/main/youtube-to-obsidian/youtube-to-obsidian
chmod +x youtube-to-obsidian
```

## 💻 Verwendung

### Syntax

```bash
./youtube-to-obsidian URL [OUTPUT] [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-v, --verbose` | Detaillierte Ausgabe |
| `-h, --help` | Hilfe anzeigen |

### Argumente

- **URL**: YouTube-Video URL (erforderlich)
- **OUTPUT**: Ausgabedatei (optional, Standard: stdout)

## 📄 Ausgabe-Beispiel

### Ausgabe auf Terminal

```bash
$ ./youtube-to-obsidian https://www.youtube.com/watch?v=klyAhaklGNU

[INFO] YouTube zu Obsidian Konverter
[INFO] Hole Video-Informationen von: https://www.youtube.com/watch?v=klyAhaklGNU
[SUCCESS] Video: Kubernetes Security Best Practices
[INFO] Kanal: TechWorld with Nana
[INFO] Dauer: 42 Minuten
[INFO] Erstelle Zusammenfassung basierend auf Titel und Beschreibung
[INFO] Erstelle Zusammenfassung mit Claude CLI...
[SUCCESS] Zusammenfassung erstellt
[SUCCESS] Fertig!

💡 Hinweis: Für detailliertere Zusammenfassungen:
   1. Öffne das Video auf YouTube
   2. Klick auf '...' → 'Transkript anzeigen'
   3. Kopiere den Text und füge ihn der Notiz hinzu

---
aliases: []
tags:
  - Video
  - Tutorial
language: de
title: Kubernetes Security Best Practices
date: 2025-10-22
source: https://www.youtube.com/watch?v=klyAhaklGNU
author: TechWorld with Nana
video_id: klyAhaklGNU
---

# Kubernetes Security Best Practices

**Kanal:** TechWorld with Nana | **Dauer:** 42 Min | **Video:** [YouTube](https://www.youtube.com/watch?v=klyAhaklGNU)

---

## 📋 Executive Summary (TL;DR)
... (Zusammenfassung von Claude) ...
```

### In Datei speichern

```bash
$ ./youtube-to-obsidian https://www.youtube.com/watch?v=klyAhaklGNU output.md

[INFO] YouTube zu Obsidian Konverter
[SUCCESS] Video: Kubernetes Security Best Practices
[INFO] Kanal: TechWorld with Nana
[INFO] Dauer: 42 Minuten
[SUCCESS] Zusammenfassung erstellt
[SUCCESS] Zusammenfassung gespeichert: output.md
[SUCCESS] Fertig!
```

### Direkt in Obsidian Vault

```bash
$ ./youtube-to-obsidian \
    https://www.youtube.com/watch?v=klyAhaklGNU \
    ~/Documents/Obsidian/Notes/kubernetes-security.md

[SUCCESS] Zusammenfassung gespeichert: ~/Documents/Obsidian/Notes/kubernetes-security.md
```

### Verbose-Modus

```bash
$ ./youtube-to-obsidian https://www.youtube.com/watch?v=klyAhaklGNU --verbose

[INFO] YouTube zu Obsidian Konverter
[VERBOSE] Verbose-Modus aktiviert
[VERBOSE] yt-dlp Version: 2025.10.07
[VERBOSE] Claude Version: 2.0.24
[VERBOSE] Alle Abhängigkeiten gefunden
[INFO] Hole Video-Informationen von: https://www.youtube.com/watch?v=klyAhaklGNU
[VERBOSE] Führe yt-dlp aus...
[VERBOSE] Video-Daten geladen: 12458 bytes
[SUCCESS] Video: Kubernetes Security Best Practices
[VERBOSE] Video: Kubernetes Security Best Practices
[VERBOSE] Kanal: TechWorld with Nana
[VERBOSE] Dauer: 42 Minuten
[VERBOSE] Sende Prompt an Claude CLI...
[VERBOSE] Claude-Antwort: 2847 Zeichen
[SUCCESS] Zusammenfassung erstellt
[VERBOSE] Note erstellt: 3421 Zeichen
[SUCCESS] Fertig!
```

## 🔧 Funktionsweise

Das Tool führt folgende Schritte aus:

1. **Abhängigkeiten prüfen**: Stellt sicher dass yt-dlp und claude CLI verfügbar sind
2. **Video-Metadaten laden**: Holt Titel, Kanal, Dauer und Beschreibung mit yt-dlp
3. **Claude-Analyse**: Sendet Video-Informationen an Claude CLI für intelligente Zusammenfassung
4. **Obsidian-Note erstellen**: Generiert Markdown-Datei mit:
   - Vollständiges Frontmatter (Tags, Metadaten, Datum)
   - Video-Header mit Kanal, Dauer und YouTube-Link
   - Executive Summary (TL;DR)
   - Strukturierte Hauptthemen
   - Praktische Relevanz für DevOps/Kubernetes
   - Geschätzte Zeitabschnitte mit klickbaren Links
   - Action Items als Checkliste

### Generierte Abschnitte

Die Claude-Zusammenfassung enthält:
- **📋 Executive Summary** - 2-3 Sätze Kurzfassung
- **🎯 Hauptthemen** - Wichtigste Konzepte
- **💡 Praktische Relevanz** - Warum für DevOps/Kubernetes relevant
- **⏱️ Geschätzte Abschnitte** - Zeitmarken mit klickbaren Links ins Video
- **📚 Was du lernen könntest** - Erwartete Inhalte
- **✅ Nächste Schritte** - Konkrete Action Items

## 🏢 Anwendungsfälle

### Lern-Notizen erstellen

```bash
# Technisches Tutorial zusammenfassen
./youtube-to-obsidian https://youtube.com/watch?v=... ~/Vault/Learning/kubernetes.md
```

### Konferenz-Talks dokumentieren

```bash
# KubeCon-Talk zusammenfassen
./youtube-to-obsidian \
  "https://youtube.com/watch?v=..." \
  ~/Vault/Conferences/KubeCon-2025/security-talk.md
```

### Batch-Processing mehrerer Videos

```bash
#!/bin/bash
# Mehrere Videos einer Playlist verarbeiten

VIDEOS=(
  "https://youtube.com/watch?v=video1"
  "https://youtube.com/watch?v=video2"
  "https://youtube.com/watch?v=video3"
)

for url in "${VIDEOS[@]}"; do
  # Extrahiere Video-ID für Dateinamen
  video_id=$(echo "$url" | sed 's/.*v=\([^&]*\).*/\1/')
  ./youtube-to-obsidian "$url" "notes/${video_id}.md"
done
```

### Integration mit Obsidian Daily Notes

```bash
#!/bin/bash
# Füge Video-Zusammenfassung zu heutiger Daily Note hinzu

TODAY=$(date +%Y-%m-%d)
DAILY_NOTE="$HOME/Vault/Daily/${TODAY}.md"

./youtube-to-obsidian "$1" | tee -a "$DAILY_NOTE"
```

### Shell-Alias für schnellen Zugriff

```bash
# In ~/.zshrc oder ~/.bashrc
alias yt2obs='~/toolbox/youtube-to-obsidian/youtube-to-obsidian'

# Verwendung
yt2obs https://youtube.com/watch?v=...
```

### Automatische Kategorisierung

```bash
#!/bin/bash
# Speichere Videos basierend auf Kanal in verschiedenen Ordnern

url=$1
video_info=$(yt-dlp --print-json --skip-download "$url")
channel=$(echo "$video_info" | jq -r '.channel')

case "$channel" in
  "TechWorld with Nana")
    output_dir="$HOME/Vault/Learning/Kubernetes"
    ;;
  "NetworkChuck")
    output_dir="$HOME/Vault/Learning/Networking"
    ;;
  *)
    output_dir="$HOME/Vault/Learning/General"
    ;;
esac

./youtube-to-obsidian "$url" "$output_dir/$(date +%Y%m%d)-video.md"
```

## ⚠️ Hinweise

### Kosten
- ✅ **Keine API-Kosten**: Nutzt dein bestehendes Claude Code/Desktop Abo
- ✅ **Keine zusätzlichen Subscriptions** erforderlich
- yt-dlp ist kostenlos und Open Source

### Transkripte
- ⚠️ **Kein automatisches Transkript**: Tool nutzt nur Titel und Beschreibung
- 💡 **Manuelle Transkripte**: Für detailliertere Zusammenfassungen kopiere das Transkript von YouTube und füge es der Notiz hinzu
- 📝 **Transkript-Verfügbarkeit**: Nicht alle Videos haben automatische Untertitel

### Qualität der Zusammenfassungen
- **Abhängig von Beschreibung**: Je ausführlicher die Video-Beschreibung, desto besser die Zusammenfassung
- **Claude-Kontext**: Claude nutzt sein Wissen über das Thema basierend auf Titel und Beschreibung
- **Best für**: Technische Talks, Tutorials mit guter Beschreibung

### Ausgabeformat
- **UTF-8 Encoding**: Alle Dateien werden als UTF-8 gespeichert
- **Obsidian-kompatibel**: Frontmatter folgt Obsidian-Standards
- **Markdown**: Standard GitHub-flavored Markdown

## 🔍 Troubleshooting

### Problem: "Fehlende Abhängigkeiten: yt-dlp"

**Symptom:**
```
[ERROR] Fehlende Abhängigkeiten: yt-dlp
[INFO] Installation:
[INFO]   yt-dlp: brew install yt-dlp
```

**Lösung:**
```bash
# macOS
brew install yt-dlp

# Linux
pip3 install yt-dlp

# Prüfen
yt-dlp --version
```

### Problem: "Fehlende Abhängigkeiten: claude"

**Symptom:**
```
[ERROR] Fehlende Abhängigkeiten: claude
[INFO] Installation:
[INFO]   claude: brew install claude-code
```

**Lösung:**
```bash
# Claude Code installieren
brew install claude-code

# Oder manuell von Claude Desktop verlinken
ln -s '/Applications/Claude.app/Contents/Resources/claude' /usr/local/bin/claude

# Prüfen
claude -v
```

### Problem: "Timeout beim Abrufen der Video-Daten"

**Symptom:**
```
[ERROR] Timeout beim Abrufen der Video-Daten (30s)
```

**Mögliche Ursachen:**
- Langsame Internetverbindung
- YouTube Rate-Limiting
- Video ist nicht verfügbar (privat, gelöscht, geo-blocked)

**Lösung:**
```bash
# Prüfe ob Video verfügbar ist
yt-dlp --skip-download "$URL"

# Prüfe Internetverbindung
curl -I https://www.youtube.com

# Warte und versuche erneut
```

### Problem: "Timeout: Claude brauchte zu lange"

**Symptom:**
```
[ERROR] Timeout: Claude brauchte zu lange (120s)
```

**Mögliche Ursachen:**
- Claude CLI ist überlastet
- Sehr lange Video-Beschreibung
- Netzwerkprobleme

**Lösung:**
```bash
# Prüfe Claude CLI
claude -v

# Teste Claude CLI separat
echo "Test" | claude

# Versuche mit kürzerem Video
```

### Problem: "JSONDecodeError beim Parsen"

**Symptom:**
```
[ERROR] Fehler beim Parsen der JSON-Antwort
```

**Mögliche Ursachen:**
- yt-dlp Output ist korrupt
- Video-Daten sind unvollständig

**Lösung:**
```bash
# Teste yt-dlp direkt
yt-dlp --print-json --skip-download "$URL"

# Update yt-dlp
brew upgrade yt-dlp  # macOS
pip3 install --upgrade yt-dlp  # Linux
```

### Problem: "Video hat keine Beschreibung"

**Symptom:**
Zusammenfassung ist sehr generisch

**Lösung:**
- Nutze Videos mit ausführlichen Beschreibungen
- Kopiere manuell das Transkript von YouTube
- Füge Transkript zur generierten Notiz hinzu

## 💡 Tipps & Tricks

### Shell-Funktionen für Common Workflows

```bash
# ~/.zshrc oder ~/.bashrc

# YouTube zu Obsidian mit Auto-Dateinamen
yt2vault() {
    local url=$1
    local title=$(yt-dlp --print "%(title)s" --skip-download "$url" | \
                 sed 's/[^a-zA-Z0-9 ]/-/g' | \
                 tr '[:upper:]' '[:lower:]' | \
                 tr -s ' ' '-')
    ~/toolbox/youtube-to-obsidian/youtube-to-obsidian "$url" \
      "$HOME/Vault/Videos/${title}.md"
}

# Mit Datum im Dateinamen
yt2dated() {
    local url=$1
    local date=$(date +%Y%m%d)
    ~/toolbox/youtube-to-obsidian/youtube-to-obsidian "$url" \
      "$HOME/Vault/Videos/${date}-video.md"
}

# Direkt in Clipboard (macOS)
yt2clip() {
    ~/toolbox/youtube-to-obsidian/youtube-to-obsidian "$1" | pbcopy
    echo "Zusammenfassung in Clipboard kopiert!"
}
```

### Integration mit Obsidian Templater

```markdown
<%*
// Obsidian Templater Template
const url = await tp.system.prompt("YouTube URL");
const output = await tp.system.clipboard();

// Führe youtube-to-obsidian aus und füge ein
const result = await tp.user.run_shell_command(
  `~/toolbox/youtube-to-obsidian/youtube-to-obsidian "${url}"`
);
%>
```

### Watch-Later Liste verarbeiten

```bash
#!/bin/bash
# Verarbeite alle Videos aus einer Liste

LIST_FILE="watch-later.txt"
OUTPUT_DIR="$HOME/Vault/Watch-Later"

mkdir -p "$OUTPUT_DIR"

while read -r url; do
  # Überspringe Kommentare und leere Zeilen
  [[ "$url" =~ ^#.*$ || -z "$url" ]] && continue

  echo "Verarbeite: $url"

  # Extrahiere Video-ID
  video_id=$(echo "$url" | sed 's/.*v=\([^&]*\).*/\1/')

  ./youtube-to-obsidian "$url" "$OUTPUT_DIR/${video_id}.md"

  # Rate-Limiting (YouTube freundlich)
  sleep 2
done < "$LIST_FILE"
```

### Sprachspezifische Zusammenfassungen

```python
# Erweitere das Script für andere Sprachen
# Füge --lang Parameter hinzu:

# Englische Zusammenfassung
./youtube-to-obsidian "$url" --lang en

# Französische Zusammenfassung
./youtube-to-obsidian "$url" --lang fr
```

## 📚 Verwandte Tools

- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - YouTube Download Tool
- **[Obsidian](https://obsidian.md/)** - Knowledge Base und Note-Taking App
- **[Claude Code](https://docs.anthropic.com/claude-code)** - Claude CLI Tool
- **[youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api)** - Python Package für Transkripte
- **[yt-get](../yt-get/)** - Toolbox Tool für Video/Audio Downloads

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
