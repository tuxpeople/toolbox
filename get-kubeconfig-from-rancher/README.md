# get-kubeconfig-from-rancher

Exportiert die Kubeconfigs aller Cluster aller im Rancher-CLI konfigurierten Server als einzelne, eindeutig benannte Dateien.

## 🎯 Zweck

Wer mehrere Rancher-Instanzen mit jeweils mehreren Clustern betreut, braucht für `kubectl`, `k9s` & Co. aktuelle Kubeconfigs. Dieses Tool iteriert über alle mit `rancher login` eingerichteten Server, lädt für jeden Cluster die Kubeconfig herunter und speichert sie als `<server>-<cluster>.yaml`. Cluster- und Context-Namen innerhalb der Datei werden mit dem Server-Namen präfixiert, damit es beim Zusammenführen (z.B. via `KUBECONFIG=a.yaml:b.yaml`) keine Namenskonflikte gibt - etwa wenn mehrere Rancher-Instanzen einen Cluster namens `local` haben.

## 📋 Voraussetzungen

### Erforderliche Tools
- **rancher** - Rancher CLI, mit mindestens einem per `rancher login` konfigurierten Server
- **sed, cmp, mktemp** - auf macOS und Linux vorinstalliert

### Installation der Abhängigkeiten

```bash
# macOS
brew install rancher-cli

# Linux: Binary von https://github.com/rancher/cli/releases herunterladen

# Server einrichten (Token in der Rancher-UI unter "API & Keys" erstellen)
rancher login https://rancher.example.com --token token-xxxxx:yyyyyyyy --name prod-rancher
```

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/get-kubeconfig-from-rancher

# Oder direkt herunterladen
curl -o get-kubeconfig-from-rancher https://raw.githubusercontent.com/tuxpeople/toolbox/main/get-kubeconfig-from-rancher/get-kubeconfig-from-rancher
chmod +x get-kubeconfig-from-rancher
```

## 💻 Verwendung

### Syntax

```bash
./get-kubeconfig-from-rancher [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-o, --output-dir DIR` | Ausgabeverzeichnis (Standard: `~/iCloudDrive/Allgemein/kubectl`) |
| `-s, --server NAME` | Nur diesen Rancher-Server verarbeiten |
| `-B, --no-backup` | Kein `.bak`-Backup vor dem Überschreiben erstellen |
| `-v, --verbose` | Detaillierte Ausgabe |
| `-n, --dry-run` | Nur anzeigen, welche Dateien geschrieben würden |
| `-h, --help` | Hilfe anzeigen |

### Umgebungsvariablen

| Variable | Beschreibung |
|----------|--------------|
| `KUBECONFIG_EXPORT_DIR` | Standard-Ausgabeverzeichnis (wird von `--output-dir` überschrieben) |

### Exit-Codes

| Code | Bedeutung |
|------|-----------|
| `0` | Alle Kubeconfigs erfolgreich exportiert |
| `1` | Allgemeiner Fehler (fehlende Abhängigkeit, ungültige Option, kein Server konfiguriert) |
| `2` | Mindestens ein Server oder Cluster konnte nicht verarbeitet werden |

## 📄 Ausgabe-Beispiel

```bash
$ ./get-kubeconfig-from-rancher -o ~/.kube/rancher

[INFO] Verarbeite Rancher-Server: Prod-Rancher
[SUCCESS] Exportiert: /Users/me/.kube/rancher/prod-rancher-local.yaml
[SUCCESS] Exportiert: /Users/me/.kube/rancher/prod-rancher-app-cluster.yaml
[INFO] Verarbeite Rancher-Server: Test-Rancher
[ERROR] Cluster-Liste von 'Test-Rancher' konnte nicht abgerufen werden (Server erreichbar?)
[INFO] Zusammenfassung: 2 Cluster, 2 exportiert, 0 unverändert, 1 Fehler
[WARN] Fertig mit Fehlern
```

### Dry-Run

```bash
$ ./get-kubeconfig-from-rancher --dry-run

[INFO] Verarbeite Rancher-Server: Prod-Rancher
[INFO] [DRY-RUN] Würde exportieren: local -> /Users/me/iCloudDrive/Allgemein/kubectl/prod-rancher-local.yaml
[INFO] [DRY-RUN] Würde exportieren: app-cluster -> /Users/me/iCloudDrive/Allgemein/kubectl/prod-rancher-app-cluster.yaml
[INFO] Zusammenfassung: 2 Cluster, 0 exportiert, 0 unverändert, 0 Fehler
[SUCCESS] Fertig!
```

## 🔧 Funktionsweise

1. **Server ermitteln**: `rancher server ls` liefert alle konfigurierten Rancher-Server; der aktuell aktive wird gemerkt
2. **Server wechseln**: Für jeden Server `rancher server switch <name>`
3. **Cluster auflisten**: `rancher cluster ls` liefert alle Cluster des Servers
4. **Kubeconfig laden**: `rancher clusters kubeconfig <cluster>` in eine temporäre Datei
5. **Umbenennen**: `"<cluster>"` wird zu `"<server>-<cluster>"` (Server-Name in Kleinbuchstaben); ACE-Contexts (`"<cluster>-<node>"`) werden ebenfalls präfixiert
6. **Vergleichen**: Ist die Datei inhaltlich unverändert, wird nichts geschrieben; sonst wird die bestehende Datei als `.bak` gesichert und ersetzt
7. **Berechtigungen**: Dateien werden mit Modus `600` geschrieben
8. **Aufräumen**: Temporäre Dateien werden gelöscht und der ursprünglich aktive Rancher-Server wiederhergestellt (auch bei Abbruch)

Nicht erreichbare Server oder fehlerhafte Cluster werden übersprungen, die übrigen werden trotzdem verarbeitet.

## 🏢 Anwendungsfälle

### Alle Kubeconfigs aktualisieren

```bash
./get-kubeconfig-from-rancher
```

### Alle exportierten Cluster in kubectl verfügbar machen

```bash
./get-kubeconfig-from-rancher -o ~/.kube/rancher
export KUBECONFIG=$(find ~/.kube/rancher -name '*.yaml' | tr '\n' ':')
kubectl config get-contexts
```

### Regelmässige Aktualisierung per Cron

```bash
# Jeden Morgen um 07:00, nur Fehler ins Log
0 7 * * * /path/to/get-kubeconfig-from-rancher -o ~/.kube/rancher 2>> ~/.kube/rancher-export.log
```

### Nur einen Server aktualisieren

```bash
./get-kubeconfig-from-rancher -s Prod-Rancher -v
```

## ⚠️ Hinweise

- **Zugangsdaten**: Kubeconfigs enthalten Rancher-Tokens mit den Rechten Ihres Benutzers. Das Ausgabeverzeichnis nur an vertrauenswürdigen Orten verwenden. Beim Standard-Verzeichnis in iCloud Drive werden die Tokens in die Cloud synchronisiert - bei Bedarf mit `-o` oder `KUBECONFIG_EXPORT_DIR` ein lokales Verzeichnis wählen.
- **Backups**: `.bak`-Dateien enthalten ebenfalls Tokens. Mit `--no-backup` lassen sie sich vermeiden.
- **Server-Wechsel**: Das Tool wechselt den aktiven Rancher-CLI-Server und stellt ihn am Ende wieder her. Parallel laufende `rancher`-Befehle können davon betroffen sein.
- **Dry-Run**: Auch im Dry-Run werden die Server kontaktiert, um die Cluster aufzulisten; es werden aber keine Kubeconfigs geladen oder Dateien geschrieben.

## 🔍 Troubleshooting

### Problem: "Keine Rancher-Server konfiguriert"

**Lösung:**
```bash
rancher login https://rancher.example.com --token token-xxxxx:yyyyyyyy --name mein-rancher
```

### Problem: "Cluster-Liste konnte nicht abgerufen werden"

**Symptom:**
```
[ERROR] Cluster-Liste von 'Test-Rancher' konnte nicht abgerufen werden (Server erreichbar?)
```

**Lösung:**
```bash
# Erreichbarkeit/VPN prüfen
rancher server switch Test-Rancher
rancher cluster ls

# Token abgelaufen? Neu einloggen
rancher login https://rancher-test.example.com --token token-neu:zzzz --name Test-Rancher
```

### Problem: Falscher Rancher-Server nach Abbruch aktiv

Der ursprüngliche Server wird per `trap` auch bei Abbruch wiederhergestellt. Falls das z.B. nach `kill -9` nicht geklappt hat:
```bash
rancher server switch <name>
```

## 💡 Tipps & Tricks

### Kubeconfigs zu einer Datei zusammenführen

```bash
KUBECONFIG=$(find ~/.kube/rancher -name '*.yaml' | tr '\n' ':') \
    kubectl config view --flatten > ~/.kube/config-rancher
chmod 600 ~/.kube/config-rancher
```

### Alte Backups aufräumen

```bash
find ~/.kube/rancher -name '*.yaml.bak' -delete
```

## 📚 Verwandte Tools

- **[rancher-support-matrix](../rancher-support-matrix/)** - Rancher Upgrade Support-Matrix
- **[kubectl-backup](../kubectl-backup/)** - Kubernetes-Ressourcen exportieren
- **[k8s-vuln](../k8s-vuln/)** - Kubernetes-Cluster auf Sicherheitslücken scannen

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
