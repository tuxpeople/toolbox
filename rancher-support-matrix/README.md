# rancher-support-matrix

Zeigt die Rancher Upgrade Support-Matrix mit kompatiblen Kubernetes-, RKE2- und Chart-Versionen.

## 🎯 Zweck

Beim Planen eines Rancher-Upgrades muss man die Kompatibilität zwischen Rancher-Version,
Kubernetes-Version, RKE2-Version und diversen Charts sicherstellen. Dieses Tool fragt
alle relevanten Informationen ab und stellt sie übersichtlich als Tabelle dar.

Ausgegeben werden alle verfügbaren Rancher-Versionen, die neuer als die aktuell
installierte sind, mit folgenden Informationen pro Version:

- **KUBE_VERSION_CONSTRAINT** – Unterstützter Kubernetes-Versionsbereich
- **MAX_RKE2** – Neueste kompatible RKE2-Version
- **Chart-Versionen** – Neueste Versionen von rancher-backup, rancher-monitoring,
  rancher-logging, longhorn und rancher-compliance

## 📋 Voraussetzungen

- `helm` – Kubernetes Package Manager
- `jq` – JSON-Prozessor
- `curl` – HTTP-Client
- `yq` – YAML-Prozessor
- Rancher-Prime Helm-Repository konfiguriert (`rancher-prime`)

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox

# Script ausführbar machen
chmod +x rancher-support-matrix/rancher-support-matrix

# Optional: Symlink in ~/bin anlegen
./sync-toolbox-links/sync-toolbox-links
```

### Abhängigkeiten installieren

```bash
# macOS
brew install helm jq curl yq

# Linux (Debian/Ubuntu)
apt install jq curl
# helm und yq separat installieren (siehe jeweilige Dokumentation)

# Rancher-Prime Helm-Repository hinzufügen
helm repo add rancher-prime https://charts.rancher.com/server-charts/prime
helm repo update
```

## 💻 Verwendung

```
rancher-support-matrix [OPTIONEN]

OPTIONEN:
    -r, --refresh            Daten-Datei neu herunterladen (ignoriert Cache)
    -d, --data-file PFAD     Pfad zur Daten-Datei
                             (Standard: ~/Downloads/rancher-data.json)
    -b, --base-version VER   Basis-Rancher-Version wenn kein Cluster erreichbar
                             (Standard: 2.13.4)
    -v, --verbose            Detaillierte Ausgabe
    -n, --dry-run            Nur anzeigen was gemacht würde
    -h, --help               Diese Hilfe anzeigen
```

### Häufige Verwendung

```bash
# Standard: Versionen neuer als aktuell installiert anzeigen
./rancher-support-matrix

# Mit frisch heruntergeladenen Daten (Cache ignorieren)
./rancher-support-matrix --refresh

# Ohne Cluster-Zugriff ab Version 2.8.0 anzeigen
./rancher-support-matrix --base-version 2.8.0

# Detaillierte Ausgabe für Diagnose
./rancher-support-matrix --verbose
```

## 📄 Ausgabe-Beispiel

```
RANCHER_VERSION  KUBE_VERSION_CONSTRAINT          MAX_RKE2          RANCHER_BACKUP  RANCHER_MONITORING  RANCHER_LOGGING  LONGHORN  RANCHER_COMPLIANCE
2.10.4           >=1.28.0-0 <1.32.0-0             v1.31.9+rke2r1    106.0.0+up4.0.0  104.2.0+up57.1.1   104.2.1+up4.4.4  1.7.3     4.0.0
2.10.3           >=1.28.0-0 <1.32.0-0             v1.31.7+rke2r1    106.0.0+up4.0.0  104.1.2+up57.0.3   104.2.0+up4.4.3  1.7.2     4.0.0
2.10.2           >=1.28.0-0 <1.32.0-0             v1.31.6+rke2r1    105.0.2+up4.0.0  104.1.1+up57.0.2   104.1.1+up4.4.2  1.7.1     3.0.1
```

## 🔧 Funktionsweise

1. **Daten-Datei** – Lädt `rancher-data.json` aus dem neusten Rancher GitHub-Release
   herunter (wird 3 Tage gecacht)
2. **Aktuelle Version** – Liest die installierte Rancher-Version via `helm list`
   aus dem `cattle-system` Namespace; fällt auf Basis-Version zurück wenn kein
   Cluster erreichbar ist
3. **Helm-Suche** – Fragt das `rancher-prime` Helm-Repository nach allen Versionen
   neuer als die aktuelle ab
4. **Pro Version:**
   - Liest `kubeVersion` aus dem Helm-Chart
   - Ermittelt die neueste kompatible RKE2-Version aus der Daten-Datei
   - Liest die neuesten Chart-Versionen aus dem `rancher/charts` GitHub-Repository
5. **Ausgabe** – Formatiert die Ergebnisse mit `column -t` als lesbare Tabelle

## 🏢 Anwendungsfälle

### Upgrade-Planung

```bash
# Vor einem Rancher-Upgrade alle kompatiblen Versionen anzeigen
./rancher-support-matrix

# Ausgabe in Datei speichern für Dokumentation
./rancher-support-matrix > rancher-upgrade-matrix-$(date +%Y-%m-%d).txt
```

### Ohne Cluster-Zugriff (z.B. in CI/CD)

```bash
# Mit expliziter Basis-Version statt Cluster-Abfrage
./rancher-support-matrix --base-version 2.9.0 --refresh
```

### Skriptintegration

```bash
# Nur die neueste verfügbare Rancher-Version ermitteln
./rancher-support-matrix 2>/dev/null | awk 'NR==2 {print $1}'
```

## ⚠️ Hinweise

- **Netzwerkzugriff erforderlich:** Das Script fragt GitHub-API, Helm-Repository
  und GitHub-Raw-Content ab
- **Rate Limits:** GitHub-API ist auf 60 Anfragen/Stunde limitiert (ohne Token);
  bei häufiger Ausführung `--refresh` sparsam einsetzen
- **Helm-Repo erforderlich:** `rancher-prime` muss als Helm-Repository konfiguriert
  sein (`helm repo add`)
- **Daten-Cache:** Die `rancher-data.json` wird standardmässig 3 Tage gecacht,
  um GitHub-API-Limits zu schonen
- **Cluster-Zugriff optional:** Ohne erreichbaren Cluster wird die Basis-Version
  (`--base-version`) als Ausgangspunkt verwendet

## 🔍 Troubleshooting

### "Keine neueren Rancher-Versionen gefunden"
```bash
# Prüfen ob das rancher-prime Repo konfiguriert ist
helm repo list | grep rancher-prime

# Helm-Repos aktualisieren
helm repo update

# Mit expliziter Basis-Version versuchen
./rancher-support-matrix --base-version 2.7.0
```

### "Download-URL für rancher-data.json nicht gefunden"
```bash
# GitHub-API Rate-Limit prüfen
curl -s https://api.github.com/rate_limit | jq '.rate'

# Alternativ: Daten-Datei manuell herunterladen
curl -Ls https://github.com/rancher/rancher/releases/latest/download/rancher-data.json \
  > ~/Downloads/rancher-data.json
```

### "Fehlende Abhängigkeiten"
```bash
# macOS
brew install helm jq curl yq

# yq-Version prüfen (Version 4+ erforderlich)
yq --version
```

### Leere Spalten (N/A) bei Charts
```bash
# Prüfen ob das Charts-Repository für die entsprechende Version existiert
RANCHER_MINOR="2.10"
curl -s "https://raw.githubusercontent.com/rancher/charts/release-v${RANCHER_MINOR}/index.yaml" \
  | yq '.entries | keys'
```

## 💡 Tipps & Tricks

```bash
# Ausgabe in CSV umwandeln
./rancher-support-matrix 2>/dev/null | tr -s ' ' ',' > matrix.csv

# Nur Versionen mit bestimmter K8s-Unterstützung filtern
./rancher-support-matrix 2>/dev/null | grep "1.30"

# Regelmässig ausführen und vergleichen (Cache wird genutzt)
./rancher-support-matrix --verbose 2>&1 | grep -E "(INFO|WARN|SUCCESS)"
```

## 📚 Verwandte Tools

- **[kubectl-backup](../kubectl-backup/)** – Kubernetes-Ressourcen vor dem Upgrade sichern
- **[k8s-vuln](../k8s-vuln/)** – Kubernetes-Cluster auf Sicherheitslücken prüfen
- **[namespace-logs](../namespace-logs/)** – Logs vor dem Upgrade exportieren
