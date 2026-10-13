# rancher-token-check

Prüft die verbleibende Gültigkeit des Rancher-Tokens einer Kubeconfig und erstellt bei Bedarf eine neue Kubeconfig.

## 🎯 Zweck

Von Rancher generierte Kubeconfigs enthalten ein Token mit begrenzter Laufzeit. Läuft es ab, funktioniert `kubectl` plötzlich nicht mehr. Dieses Tool liest das Token der aktuellen Kubeconfig, ermittelt über das zugehörige Secret im Namespace `cattle-tokens` die Ablaufzeit und zeigt die Restlaufzeit an. Unterschreitet sie eine Warnschwelle (Standard: 3 Tage), bietet das Tool an, über die Rancher ext-API (`ext.cattle.io/v1`, Kind `Kubeconfig`) eine neue Kubeconfig zu erstellen.

Dank sprechender Exit-Codes eignet es sich auch für Cron-Jobs oder Shell-Prompts.

## 📋 Voraussetzungen

### Erforderliche Tools
- **kubectl** - Kubernetes CLI
- **base64, date** - auf macOS und Linux vorinstalliert (GNU `gdate` wird verwendet, falls vorhanden, sonst BSD-`date`)

### Rancher
- Rancher v2.12+ mit ext-Tokens (Token-Secrets im Namespace `cattle-tokens`)
- Die Kubeconfig muss auf den **Management-Cluster** (`local`) zeigen
- Leserechte auf das eigene Token-Secret

### Installation der Abhängigkeiten

```bash
# macOS
brew install kubectl

# Linux
apt install kubectl  # bzw. gemäss https://kubernetes.io/docs/tasks/tools/
```

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/rancher-token-check

# Oder direkt herunterladen
curl -o rancher-token-check https://raw.githubusercontent.com/tuxpeople/toolbox/main/rancher-token-check/rancher-token-check
chmod +x rancher-token-check
```

## 💻 Verwendung

### Syntax

```bash
./rancher-token-check [OPTIONEN]
```

### Optionen

| Option | Beschreibung |
|--------|--------------|
| `-k, --kubeconfig DATEI` | Zu prüfende Kubeconfig (Standard: `$KUBECONFIG` bzw. `~/.kube/config`) |
| `-c, --context NAME` | Context in der Kubeconfig (Standard: aktueller Context) |
| `-t, --threshold TAGE` | Warnschwelle in Tagen (Standard: 3) |
| `-o, --output-dir DIR` | Zielverzeichnis für die neue Kubeconfig (Standard: aktuelles Verzeichnis) |
| `-d, --description TEXT` | Beschreibung der neuen Kubeconfig in Rancher |
| `-N, --no-renew` | Nur prüfen, nie eine neue Kubeconfig erstellen |
| `-f, --force` | Neue Kubeconfig ohne Nachfrage erstellen, wenn die Warnschwelle unterschritten ist |
| `-v, --verbose` | Detaillierte Ausgabe |
| `-n, --dry-run` | Nur anzeigen, was gemacht würde |
| `-h, --help` | Hilfe anzeigen |

### Exit-Codes

| Code | Bedeutung |
|------|-----------|
| `0` | Token länger als Warnschwelle gültig, oder neue Kubeconfig erfolgreich erstellt |
| `1` | Allgemeiner Fehler (kein Token, Secret nicht lesbar, ungültige Option) |
| `2` | Token läuft innerhalb der Warnschwelle ab |
| `3` | Token ist bereits abgelaufen |

## 📄 Ausgabe-Beispiel

### Token noch lange gültig

```bash
$ ./rancher-token-check -k ~/Downloads/local.yaml

Verbleibende Gültigkeit: 27T 4Std 12Min 9Sek
[SUCCESS] Token ist noch länger als 3 Tage gültig
```

### Token läuft bald ab

```bash
$ ./rancher-token-check

Verbleibende Gültigkeit: 1T 6Std 3Min 41Sek
[WARN] Token ist weniger als 3 Tage gültig
Möchtest du eine neue Kubeconfig erstellen? (j/n): j
[SUCCESS] Neue Kubeconfig erstellt: /Users/me/kubeconfig-rancher-20261013-091512.yaml
[INFO] Verwenden mit: export KUBECONFIG=/Users/me/kubeconfig-rancher-20261013-091512.yaml
```

> Hinweis: Die Restlaufzeit geht auf `stdout`, alle Log-Meldungen auf `stderr`.

## 🔧 Funktionsweise

1. **Token lesen**: `kubectl config view --raw --minify` liefert das Token des aktuellen (bzw. mit `--context` gewählten) Contexts
2. **Secret-Namen ableiten**: Aus `[ext/]<name>:<secret>` wird `<name>` extrahiert (z.B. `ext/token-m428s:...` → `token-m428s`)
3. **Secret auslesen**: `last-update-time` und `ttl` (Millisekunden) aus `cattle-tokens/<name>` lesen und Base64-dekodieren
4. **Ablauf berechnen**: Ablauf = `last-update-time` + `ttl`; ein `ttl` ≤ 0 wird als "läuft nicht ab" interpretiert
5. **Auswerten**: Restlaufzeit ausgeben und mit der Warnschwelle vergleichen
6. **Erneuern** (optional): Nach Bestätigung bzw. mit `--force` wird ein `Kubeconfig`-Objekt (`ext.cattle.io/v1`, alle Cluster) erstellt und `.status.value` als `kubeconfig-rancher-<zeitstempel>.yaml` mit Modus `600` gespeichert. Bestehende Dateien werden nie überschrieben.

## 🏢 Anwendungsfälle

### Bestimmte Kubeconfig prüfen

```bash
./rancher-token-check -k ~/Downloads/local.yaml
```

### Nur prüfen, Warnung ab 7 Tagen

```bash
./rancher-token-check --no-renew --threshold 7
```

### Täglicher Check per Cron mit automatischer Erneuerung

```bash
# Erstellt bei Bedarf eine neue Kubeconfig in ~/.kube, Logs nach Datei
0 8 * * * /path/to/rancher-token-check -k ~/.kube/rancher.yaml -f -o ~/.kube 2>> ~/.kube/token-check.log
```

### In eigenen Scripts verwenden

```bash
if ! ./rancher-token-check -N -t 1 >/dev/null 2>&1; then
    echo "Rancher-Token läuft heute ab oder ist abgelaufen!"
fi
```

## ⚠️ Hinweise

- **Zugangsdaten**: Neu erstellte Kubeconfigs enthalten ein Token mit den Rechten Ihres Benutzers. Dateien werden mit Modus `600` angelegt - trotzdem nur an vertrauenswürdigen Orten ablegen.
- **Alte Tokens**: Beim Erneuern wird das alte Token nicht widerrufen. Nicht mehr benötigte Tokens in der Rancher-UI unter "Account & API Keys" löschen.
- **Abgelaufene Tokens**: Zum Erneuern muss das aktuelle Token noch gültig sein. Ist es abgelaufen, die Kubeconfig über die Rancher-UI neu herunterladen.
- **Management-Cluster**: Die Token-Secrets liegen nur im `local`-Cluster. Kubeconfigs, die direkt auf einen Downstream-Cluster zeigen, können nicht geprüft werden.

## 🔍 Troubleshooting

### Problem: "Kein Token in der aktuellen Kubeconfig gefunden"

Die Kubeconfig verwendet keine Token-Authentifizierung (z.B. Zertifikate oder exec-Plugin) oder der gewählte Context existiert nicht.

```bash
kubectl config get-contexts
./rancher-token-check -c <context-name>
```

### Problem: "Konnte Secret nicht auslesen"

**Ursachen:**
- Kubeconfig zeigt nicht auf den Management-Cluster (`local`)
- Fehlende Rechte auf `cattle-tokens`
- Token bereits abgelaufen (Authentifizierung schlägt fehl)
- Ältere Rancher-Version ohne ext-Tokens

```bash
# Verbindung und Rechte prüfen
kubectl auth can-i get secrets -n cattle-tokens
```

### Problem: "Keine interaktive Eingabe möglich"

Das Tool läuft ohne Terminal (z.B. Cron) und kann nicht nachfragen. Mit `--force` wird ohne Nachfrage erneuert, mit `--no-renew` wird nur geprüft.

## 💡 Tipps & Tricks

### Neue Kubeconfig direkt aktivieren

```bash
./rancher-token-check -f -o ~/.kube && \
    export KUBECONFIG=$(ls -t ~/.kube/kubeconfig-rancher-*.yaml | head -1)
```

### Mehrere Kubeconfigs prüfen

```bash
for kc in ~/.kube/rancher/*.yaml; do
    echo "== $kc"
    ./rancher-token-check -k "$kc" -N
done
```

## 📚 Verwandte Tools

- **[get-kubeconfig-from-rancher](../get-kubeconfig-from-rancher/)** - Kubeconfigs aller Rancher-Cluster per Rancher CLI exportieren
- **[rancher-support-matrix](../rancher-support-matrix/)** - Rancher Upgrade Support-Matrix

## 📄 Lizenz

MIT License - siehe [LICENSE](../LICENSE) für Details.
