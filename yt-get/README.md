# 📺 yt-get

Einfacher Wrapper für yt-dlp zum Download von Videos und Audio.

## 📋 Überblick

Dieses Tool vereinfacht die Verwendung von yt-dlp für die häufigsten Download-Szenarien. Es unterstützt Video-Downloads in MP4/AAC und Audio-Downloads als MP3.

**Unterstützte Formate:**
- **Video** - MP4-Container mit H.264 Video und AAC Audio
- **Audio** - MP3-Dateien mit 192kbps

## 🚀 Schnellstart

```bash
# Video in bester Qualität herunterladen
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ"

# Audio als MP3 herunterladen
./yt-get audio "https://youtube.com/watch?v=dQw4w9WgXcQ"

# Video in spezifischer Qualität
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ" --quality 1080p

# Video-Informationen anzeigen
./yt-get info "https://youtube.com/watch?v=dQw4w9WgXcQ"
```

## ⚙️ Installation

### Voraussetzungen

```bash
# yt-dlp installieren
pip install yt-dlp

# ffmpeg installieren (für Audio-Konvertierung)
# macOS:
brew install ffmpeg

# Ubuntu/Debian:
sudo apt install ffmpeg

# Arch Linux:
sudo pacman -S ffmpeg
```

## 📖 Verwendung

### Grundlegende Syntax

```bash
./yt-get <command> <url> [options]
```

### Commands

| Command | Beschreibung |
|---------|-------------|
| `video` | Video in MP4/AAC in bester verfügbarer Auflösung |
| `audio` | Audio als MP3 herunterladen |
| `info` | Video-Informationen anzeigen |

### Optionen

| Option | Beschreibung |
|--------|-------------|
| `-o, --output DIR` | Output-Verzeichnis (Standard: aktuelles Verzeichnis) |
| `-q, --quality QUAL` | Video-Qualität (nur für video command) |
| `-v, --verbose` | Detaillierte Ausgabe |
| `-h, --help` | Hilfe anzeigen |

### Qualitäts-Optionen

| Qualität | Beschreibung |
|----------|-------------|
| `best` | Beste verfügbare Qualität (Standard) |
| `worst` | Schlechteste verfügbare Qualität |
| `720p` | Maximal 720p (HD) |
| `1080p` | Maximal 1080p (Full HD) |
| `1440p` | Maximal 1440p (2K) |
| `2160p` | Maximal 2160p (4K) |

## 💡 Beispiele

### Video-Downloads

```bash
# Beste verfügbare Qualität
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ"

# Spezifische Qualität
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ" --quality 1080p

# In bestimmtes Verzeichnis
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ" --output ~/Videos

# Mit detaillierter Ausgabe
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ" --verbose

# Kombinierte Optionen
./yt-get video "https://youtube.com/watch?v=dQw4w9WgXcQ" --quality 720p --output ~/Downloads --verbose
```

### Audio-Downloads

```bash
# Audio als MP3 herunterladen
./yt-get audio "https://youtube.com/watch?v=dQw4w9WgXcQ"

# In bestimmtes Verzeichnis
./yt-get audio "https://youtube.com/watch?v=dQw4w9WgXcQ" --output ~/Music

# Mit detaillierter Ausgabe
./yt-get audio "https://youtube.com/watch?v=dQw4w9WgXcQ" --verbose
```

### Information

```bash
# Video-Informationen anzeigen
./yt-get info "https://youtube.com/watch?v=dQw4w9WgXcQ"

# Detaillierte Informationen
./yt-get info "https://youtube.com/watch?v=dQw4w9WgXcQ" --verbose
```

## 🔧 Erweiterte Verwendung

### Playlists

```bash
# Ganze Playlist als Videos herunterladen
./yt-get video "https://youtube.com/playlist?list=PLxxxx" --output ~/Playlist

# Ganze Playlist als Audio
./yt-get audio "https://youtube.com/playlist?list=PLxxxx" --output ~/Music
```

### Verschiedene Plattformen

Das Tool funktioniert mit allen von yt-dlp unterstützten Plattformen:

```bash
# YouTube
./yt-get video "https://youtube.com/watch?v=..."

# Vimeo
./yt-get video "https://vimeo.com/..."

# SoundCloud
./yt-get audio "https://soundcloud.com/..."

# Twitch Clips
./yt-get video "https://clips.twitch.tv/..."
```

## 🛠️ Fehlerbehebung

### Häufige Probleme

**Problem:** "yt-dlp: command not found"
```bash
# Lösung: yt-dlp installieren
pip install yt-dlp

# Oder mit Homebrew (macOS)
brew install yt-dlp
```

**Problem:** "ffmpeg: command not found"
```bash
# Lösung: ffmpeg installieren
# macOS:
brew install ffmpeg

# Ubuntu/Debian:
sudo apt install ffmpeg
```

**Problem:** Video kann nicht heruntergeladen werden
```bash
# Prüfen ob URL korrekt ist
./yt-get info "URL"

# yt-dlp aktualisieren
pip install --upgrade yt-dlp

# Mit detaillierter Ausgabe debuggen
./yt-get video "URL" --verbose
```

**Problem:** Qualität nicht verfügbar
```bash
# Verfügbare Qualitäten prüfen
./yt-get info "URL"

# Oder yt-dlp direkt verwenden
yt-dlp --list-formats "URL"
```

### Logs und Debugging

```bash
# Detaillierte Ausgabe aktivieren
./yt-get video "URL" --verbose

# yt-dlp Version prüfen
yt-dlp --version

# ffmpeg Version prüfen
ffmpeg -version
```

## ⚡ Performance-Tipps

- **SSD empfohlen:** Für grosse Video-Downloads
- **Internetverbindung:** Stabile Verbindung für hohe Qualitäten
- **Speicherplatz:** 4K Videos benötigen viel Platz
- **Parallelität:** Ein Download nach dem anderen für beste Performance

## 🔐 Sicherheitshinweise

⚠️ **Wichtige Sicherheitsaspekte:**

- **Copyright beachten:** Nur Videos herunterladen, deren Download erlaubt ist
- **Private URLs:** Keine privaten/gesperrten URLs verwenden
- **Malware-Schutz:** Nur vertrauenswürdige URLs verwenden
- **Speicherplatz:** Downloads können viel Speicherplatz verbrauchen
- **Bandbreite:** Grosse Downloads verbrauchen viel Internetbandbreite
- **Updates:** yt-dlp regelmässig aktualisieren für beste Kompatibilität

## 📊 Ausgabeformate

### Video-Ausgabe
- **Container:** MP4
- **Video-Codec:** H.264
- **Audio-Codec:** AAC
- **Metadaten:** Eingebettet
- **Kapitel:** Eingebettet (falls verfügbar)
- **Zusatzdateien:** .description, .info.json

### Audio-Ausgabe
- **Format:** MP3
- **Bitrate:** 192kbps
- **Metadaten:** Eingebettet
- **Zusatzdateien:** .description, .info.json

## 🤝 Beitragen

Verbesserungsvorschläge und Fehlermeldungen sind willkommen!

### Entwicklung

```bash
# Script testen
./yt-get --help

# Syntax prüfen
shellcheck yt-get

# Mit Test-URL testen
./yt-get info "https://youtube.com/watch?v=dQw4w9WgXcQ"
```

## 📚 Weiterführende Links

- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg Documentation](https://ffmpeg.org/documentation.html)
- [Supported Sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

---

**⚠️ Verwendung auf eigene Gefahr** - Beachten Sie Copyright-Bestimmungen und lokale Gesetze beim Download von Inhalten.