# timestamped-history - History mit Timestamps anzeigen

Liest die Bash-History-Datei und gibt alle Befehle mit gespeicherten Timestamps aus. Unterstützt Filterung, Anzahl-Begrenzung und anpassbares Datumsformat.

## 🎯 Zweck

Die Bash-History enthält standardmässig keine sichtbaren Timestamps - obwohl Bash diese als Unix-Timestamps in der History-Datei speichern kann, wenn `HISTTIMEFORMAT` gesetzt ist. Dieses Tool:

1. **Liest die History-Datei direkt** und parst die gespeicherten Timestamps
2. **Formatiert Timestamps** in ein lesbares Datum/Uhrzeit-Format
3. **Filtert Befehle** nach Mustern (z.B. nur git- oder kubectl-Befehle)
4. **Begrenzt die Ausgabe** auf die letzten N Einträge
5. **Markiert Einträge ohne Timestamp** mit "?" für Transparenz

## 📋 Voraussetzungen

- **awk** mit strftime-Unterstützung (auf macOS und Linux standardmässig verfügbar)
- **Bash-History** mit aktivierten Timestamps (empfohlen: `HISTTIMEFORMAT="%F %T "`)

## 🚀 Installation

```bash
# Script herunterladen
curl -o timestamped-history https://raw.githubusercontent.com/tuxpeople/toolbox/main/timestamped-history/timestamped-history
chmod +x timestamped-history
```

### Timestamps in Bash aktivieren

Damit Timestamps dauerhaft in der History gespeichert werden, folgendes in `~/.bashrc` (Linux) oder `~/.bash_profile` (macOS) eintragen:

```bash
export HISTTIMEFORMAT="%F %T "
export HISTSIZE=10000
export HISTFILESIZE=20000
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./timestamped-history [OPTIONEN]
```

### Optionen
- `-n, --lines N` - Nur die letzten N Einträge anzeigen
- `-f, --filter MUSTER` - Nur Einträge anzeigen, die MUSTER enthalten
- `-d, --date-format FMT` - Datumsformat (Standard: `%Y-%m-%d %H:%M:%S`)
- `-F, --file DATEI` - Alternative History-Datei angeben
- `-v, --verbose` - Detaillierte Ausgabe (zeigt verwendete Einstellungen)
- `-h, --help` - Hilfe anzeigen

### Beispiele

**Alle History-Einträge mit Timestamps:**
```bash
./timestamped-history
```

**Letzte 50 Einträge:**
```bash
./timestamped-history -n 50
```

**Nur git-Befehle:**
```bash
./timestamped-history -f "git"
```

**Letzte 100 kubectl-Befehle:**
```bash
./timestamped-history -n 100 -f "kubectl"
```

**Mit deutschem Datumsformat:**
```bash
./timestamped-history -d "%d.%m.%Y %H:%M"
```

**Alternative History-Datei:**
```bash
./timestamped-history -F ~/.zsh_history
```

## 📄 Ausgabe-Beispiel

```
$ ./timestamped-history -n 10

 1  2025-03-09 14:22:31  git status
 2  2025-03-09 14:22:45  git add -A
 3  2025-03-09 14:23:01  git commit -m "fix: typo"
 4  2025-03-09 14:25:17  kubectl get pods -n production
 5  2025-03-09 14:26:02  kubectl logs -f pod/myapp-abc123
 6  ?                    ls -la
 7  2025-03-09 15:01:44  cd /etc/nginx
 8  2025-03-09 15:02:09  cat nginx.conf
 9  2025-03-09 15:10:33  brew update
10  2025-03-09 15:11:07  brew upgrade
```

Einträge mit `?` wurden ohne aktiven `HISTTIMEFORMAT` gespeichert.

## 🔧 Funktionsweise

### History-Datei Format

Bash speichert Timestamps als Unix-Zeitstempel in der History-Datei, wenn `HISTTIMEFORMAT` gesetzt ist:

```
#1741521751
git status
#1741521765
git add -A
ls -la
#1741522304
kubectl get pods
```

Zeilen die mit `#<Zahl>` beginnen sind Unix-Timestamps. Das Script erkennt diese und ordnet sie den nachfolgenden Befehlen zu.

### Verarbeitungsschritte

1. **Einlesen** - History-Datei zeilenweise lesen
2. **Parsen** - Timestamp-Zeilen (`#<unix_ts>`) von Befehls-Zeilen trennen
3. **Filtern** - Optional nach Muster filtern
4. **Begrenzen** - Optional auf letzte N Einträge reduzieren
5. **Formatieren** - Unix-Timestamps mit `strftime` in lesbares Format umwandeln
6. **Ausgeben** - Nummerierte Liste mit Timestamps und Befehlen

### Session-History

Die aktuelle Shell-Session schreibt History möglicherweise erst am Ende in die Datei. Um die aktuelle Session-History sofort zu speichern:

```bash
history -a   # Aktuelle Session in Datei schreiben
```

## 🏢 Anwendungsfälle

### Audit & Compliance
```bash
# Was wurde heute auf dem Server gemacht?
./timestamped-history -d "%Y-%m-%d %H:%M:%S" | grep "2025-03-10"

# Alle sudo-Befehle finden
./timestamped-history -f "sudo"

# Alle Deployment-Befehle
./timestamped-history -f "kubectl apply"
```

### Troubleshooting
```bash
# Was wurde kurz vor einem Incident ausgeführt?
./timestamped-history -n 50

# Welche Konfigurationsänderungen wurden gemacht?
./timestamped-history -f "vim\|nano\|edit"
```

### Entwicklung
```bash
# Alle git-Operationen der letzten Woche
./timestamped-history -f "git" -n 200

# Docker-Befehle mit Timestamp
./timestamped-history -f "docker"
```

## ⚠️ Hinweise

- **Timestamps nur bei aktivem HISTTIMEFORMAT** - Einträge vor der Aktivierung haben keinen Timestamp
- **Session-History** - Die aktuelle Shell-Session muss zuerst mit `history -a` gespeichert werden
- **Read-Only** - Das Tool verändert die History-Datei nicht
- **Grosse Dateien** - Bei sehr grossen History-Dateien (>100 MB) kann die Verarbeitung länger dauern

## 🔍 Troubleshooting

### "History-Datei nicht gefunden"
```bash
# Prüfen wo die History-Datei liegt
echo $HISTFILE

# Standard-Pfad prüfen
ls -la ~/.bash_history

# Alternativen History-Datei angeben
./timestamped-history -F /pfad/zur/history
```

### Alle Timestamps sind "?"
```bash
# HISTTIMEFORMAT war nicht gesetzt, jetzt aktivieren
echo 'export HISTTIMEFORMAT="%F %T "' >> ~/.bashrc
source ~/.bashrc

# Ab jetzt werden neue Einträge mit Timestamp gespeichert
```

### Aktuelle Session fehlt
```bash
# Session-History sofort speichern
history -a

# Dann timestamped-history erneut aufrufen
./timestamped-history -n 20
```

### Datumsformat anpassen
```bash
# ISO 8601
./timestamped-history -d "%Y-%m-%dT%H:%M:%S"

# Deutsch
./timestamped-history -d "%d.%m.%Y %H:%M"

# Nur Datum
./timestamped-history -d "%Y-%m-%d"

# Nur Uhrzeit
./timestamped-history -d "%H:%M:%S"
```

## 💡 Tipps & Tricks

### Als Alias einrichten
```bash
# In ~/.bashrc hinzufügen
alias hist='~/toolbox/timestamped-history/timestamped-history'
alias hist50='~/toolbox/timestamped-history/timestamped-history -n 50'
```

### Mit grep kombinieren
```bash
# Erweiterte Filterung (Regex)
./timestamped-history | grep -E "git (commit|push|pull)"

# Nur heute
./timestamped-history | grep "$(date +%Y-%m-%d)"
```

### History automatisch sichern
```bash
# History bei jedem Befehl sofort speichern (in ~/.bashrc)
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
```

### Zsh History
```bash
# Zsh-History hat ein anderes Format mit erweitertem Timestamp
# Für zsh besser die eingebauten Tools verwenden:
# fc -l -d -D 1   # Zsh: History mit Timestamps
```

## 📚 Verwandte Tools

- **history** - Bash-Builtin zum Anzeigen der History (ohne Timestamps im Standard)
- **fc** - Bash/Zsh-Builtin für History-Management
- **atuin** - Modernes History-Tool mit Datenbank und Synchronisation
- **hstr** - Interaktive History-Suche für Bash/Zsh
