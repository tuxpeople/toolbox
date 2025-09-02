# namespace-logs - Kubernetes Namespace Log Exporter

Exportiert alle Container-Logs eines Kubernetes-Namespaces in einem bestimmten Zeitraum und speichert sie als separate Dateien.

## 🎯 Zweck

Das `namespace-logs` Tool automatisiert das Sammeln aller Container-Logs aus einem Kubernetes-Namespace für einen spezifischen Zeitraum. Es durchläuft alle Pods im Namespace, identifiziert alle Container und exportiert deren Logs in separate Dateien. Dies ist besonders nützlich für Debugging, Audit-Zwecke oder für die Archivierung von Logs.

## 📋 Voraussetzungen

- **kubectl** - Kubernetes Command Line Tool (muss installiert und konfiguriert sein)
- **Bash 4.0+** - Für erweiterte Array-Funktionen
- **Kubernetes-Cluster-Zugriff** - kubectl muss mit einem funktionsfähigen Cluster verbunden sein
- **Namespace-Berechtigung** - Leserechte auf Pods und Logs im gewünschten Namespace

## 🚀 Installation

```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/namespace-logs

# Script ausführbar machen (falls noch nicht geschehen)
chmod +x namespace-logs

# Zu PATH hinzufügen (optional)
sudo ln -s "$(pwd)/namespace-logs" /usr/local/bin/namespace-logs
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
namespace-logs -n NAMESPACE -s START_TIME -e END_TIME -o OUTPUT_DIR [OPTIONEN]
```

### Parameter

| Option | Lang-Form | Beschreibung | Erforderlich |
|--------|-----------|--------------|--------------|
| `-n` | `--namespace` | Kubernetes-Namespace | ✅ |
| `-s` | `--start-time` | Start-Zeit (ISO 8601 Format) | ✅ |
| `-e` | `--end-time` | End-Zeit (ISO 8601 Format) | ❌ |
| `-o` | `--output-dir` | Output-Verzeichnis | ✅ |
| `-v` | `--verbose` | Detaillierte Ausgabe | ❌ |
| | `--dry-run` | Nur anzeigen was gemacht würde | ❌ |
| `-f` | `--force` | Überschreibe ohne Nachfrage | ❌ |
| `-h` | `--help` | Hilfe anzeigen | ❌ |

### Zeitformat
- **ISO 8601 Format**: `YYYY-MM-DDTHH:MM:SSZ`
- **Beispiel**: `2025-08-25T13:00:00Z`
- **UTC-Zeit**: Das 'Z' am Ende steht für UTC/Zulu-Zeit

### Beispiele

```bash
# Logs zwischen 13:00 und 14:00 UTC exportieren
namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs

# Logs ab 13:00 UTC bis jetzt exportieren
namespace-logs -n staging -s "2025-08-25T13:00:00Z" -o ./logs

# Dry-Run um zu sehen was exportiert würde
namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs --dry-run

# Mit detaillierter Ausgabe
namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs --verbose

# Existierende Dateien ohne Nachfrage überschreiben
namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs --force
```

## 📄 Ausgabe-Beispiel

### Erfolgreicher Export
```bash
$ namespace-logs -n production -s "2025-08-25T13:00:00Z" -e "2025-08-25T14:00:00Z" -o ./logs

[INFO] namespace-logs - Kubernetes Namespace Log Exporter
[INFO] Exportiere Logs aus Namespace: production
[INFO] Gefundene Pods: 15
[SUCCESS] Export abgeschlossen
[INFO] Erfolgreich exportierte Logs: 23
[SUCCESS] Alle Logs exportiert nach: ./logs
```

### Datei-Struktur
```
logs/
├── frontend-deployment-abc123_nginx.log
├── frontend-deployment-abc123_app.log
├── backend-deployment-def456_app.log
├── database-statefulset-0_postgres.log
└── worker-deployment-ghi789_worker.log
```

### Verbose-Ausgabe
```bash
[VERBOSE] Start-Zeit: 2025-08-25T13:00:00Z
[VERBOSE] End-Zeit: 2025-08-25T14:00:00Z
[VERBOSE] Output-Verzeichnis: ./logs
[VERBOSE] Verarbeite Pod: frontend-deployment-abc123
[VERBOSE] Exportiere Logs für Pod: frontend-deployment-abc123, Container: nginx
[VERBOSE] Erfolgreich exportiert: ./logs/frontend-deployment-abc123_nginx.log (1247 Zeilen)
```

## 🔧 Funktionsweise

1. **Validierung**: Prüft kubectl-Installation und Cluster-Verbindung
2. **Namespace-Check**: Überprüft ob der angegebene Namespace existiert
3. **Pod-Discovery**: Listet alle Pods im Namespace auf
4. **Container-Erkennung**: Identifiziert alle Container in jedem Pod
5. **Log-Export**: Exportiert Logs für jeden Container mit kubectl logs
6. **Datei-Organisation**: Speichert Logs als `{pod_name}_{container_name}.log`

### kubectl-Kommandos die verwendet werden:
```bash
# Namespace-Validierung
kubectl get namespace NAMESPACE

# Pod-Liste abrufen
kubectl get pods -n NAMESPACE -o jsonpath='{.items[*].metadata.name}'

# Container-Liste für einen Pod
kubectl get pod POD -n NAMESPACE -o jsonpath='{.spec.containers[*].name}'

# Logs exportieren
kubectl logs POD -c CONTAINER -n NAMESPACE --since-time=START_TIME --until-time=END_TIME
```

## 🏢 Anwendungsfälle

### Debugging und Fehleranalyse
```bash
# Nach einem Incident alle Logs aus dem letzten Zeitraum sammeln
namespace-logs -n production -s "2025-08-25T10:00:00Z" -e "2025-08-25T12:00:00Z" -o ./incident-logs
```

### Audit und Compliance
```bash
# Tägliche Log-Archivierung
namespace-logs -n production -s "2025-08-25T00:00:00Z" -e "2025-08-25T23:59:59Z" -o ./archive/2025-08-25
```

### Performance-Analyse
```bash
# Logs während Load-Tests sammeln
namespace-logs -n testing -s "2025-08-25T14:00:00Z" -e "2025-08-25T15:00:00Z" -o ./performance-test-logs
```

### Deployment-Überwachung
```bash
# Logs während und nach einem Deployment
namespace-logs -n staging -s "2025-08-25T16:00:00Z" -o ./deployment-logs --verbose
```

## ⚠️ Hinweise

### Sicherheit
- **Sensible Daten**: Log-Dateien können sensible Informationen enthalten - sichere Speicherung erforderlich
- **RBAC-Berechtigungen**: Stelle sicher, dass ausreichende Kubernetes-Berechtigungen vorhanden sind
- **Network-Policies**: Bei restriktiven Netzwerk-Richtlinien kann kubectl-Zugriff eingeschränkt sein

### Performance
- **Grosse Namespaces**: Bei vielen Pods kann der Export längere Zeit dauern
- **Log-Grösse**: Grosse Log-Mengen können viel Speicherplatz benötigen
- **API-Rate-Limits**: Kubernetes API kann bei vielen gleichzeitigen Anfragen begrenzen

### Speicher-Management
- **Festplatten-Platz**: Prüfe verfügbaren Speicherplatz vor dem Export
- **Temporäre Dateien**: Das Tool erstellt keine temporären Dateien, schreibt direkt in Ziel-Dateien
- **Bereinigung**: Lösche alte Export-Verzeichnisse regelmässig

## 🔍 Troubleshooting

### Häufige Probleme

#### kubectl nicht gefunden
```bash
[ERROR] Fehlende Abhängigkeiten: kubectl
[ERROR] Bitte installiere alle erforderlichen Tools
```
**Lösung**: kubectl installieren und zu PATH hinzufügen

#### Keine Cluster-Verbindung
```bash
[ERROR] Keine Verbindung zum Kubernetes-Cluster möglich
[ERROR] Prüfe deine kubectl-Konfiguration
```
**Lösung**: 
```bash
kubectl cluster-info
kubectl config current-context
kubectl config use-context GEWÜNSCHTER_CONTEXT
```

#### Namespace existiert nicht
```bash
[ERROR] Namespace 'mein-namespace' existiert nicht
```
**Lösung**: 
```bash
kubectl get namespaces
kubectl create namespace mein-namespace  # falls erforderlich
```

#### Keine Berechtigung
```bash
[WARN] Fehler beim Auflisten der Pods in Namespace 'production'
```
**Lösung**: RBAC-Berechtigungen prüfen
```bash
kubectl auth can-i get pods --namespace=production
kubectl auth can-i get pods/log --namespace=production
```

#### Leere oder fehlende Logs
```bash
[WARN] Fehler beim Exportieren der Logs für Pod 'mein-pod', Container 'mein-container'
```
**Mögliche Ursachen**:
- Pod war im angegebenen Zeitraum nicht aktiv
- Container hatte keine Logs im Zeitraum
- Log-Rotation hat Logs bereits gelöscht
- Zeitzone-Probleme (verwende UTC-Zeit)

### Debug-Befehle

```bash
# Manuelle Überprüfung der Pod-Logs
kubectl logs POD_NAME -c CONTAINER_NAME -n NAMESPACE --since-time="2025-08-25T13:00:00Z"

# Pod-Status überprüfen
kubectl describe pod POD_NAME -n NAMESPACE

# Container-Namen eines Pods anzeigen
kubectl get pod POD_NAME -n NAMESPACE -o jsonpath='{.spec.containers[*].name}'

# Namespace-Events anzeigen
kubectl get events -n NAMESPACE --sort-by=.metadata.creationTimestamp
```

## 💡 Tipps & Tricks

### Zeitzone-Handling
```bash
# Lokale Zeit zu UTC konvertieren (macOS/Linux)
date -u -d "2025-08-25 15:00:00" +"%Y-%m-%dT%H:%M:%SZ"

# Oder mit expliziter Zeitzone
TZ=Europe/Zurich date -d "2025-08-25 15:00:00" -u +"%Y-%m-%dT%H:%M:%SZ"
```

### Automation mit Cron
```bash
# Täglich um 02:00 UTC die Logs des Vortages archivieren
0 2 * * * /usr/local/bin/namespace-logs -n production -s "$(date -u -d 'yesterday' +%Y-%m-%dT00:00:00Z)" -e "$(date -u -d 'yesterday' +%Y-%m-%dT23:59:59Z)" -o "/backup/logs/$(date -u -d 'yesterday' +%Y-%m-%d)" --force
```

### Log-Analyse mit Standard-Tools
```bash
# Alle exportierten Logs durchsuchen
grep -r "ERROR" ./logs/

# Log-Zeilen zählen
wc -l ./logs/*.log | sort -n

# Grösste Log-Dateien finden
ls -lhS ./logs/*.log | head -10
```

### Selective Export
```bash
# Nur Logs von Pods mit bestimmtem Label
kubectl get pods -n production -l app=frontend -o jsonpath='{.items[*].metadata.name}'

# Dann manuell mit namespace-logs oder durch Script-Erweiterung
```

## 📚 Verwandte Tools

### Ähnliche Tools in der Toolbox
- **k8s_vuln** - Kubernetes Vulnerability Scanner
- **crane_fqdn** - Container Registry FQDN Resolver

### Externe Tools
- **stern** - Multi-Pod/Container Log Tailing
- **kubetail** - Bash Script für Multi-Pod Logs
- **kubectl-logs** - Extended kubectl logs functionality
- **logcli** - Loki Log CLI (für zentralisierte Logs)

### Kubernetes Dashboard Alternativen
- **k9s** - Terminal UI für Kubernetes
- **lens** - Kubernetes IDE
- **octant** - Web-based Kubernetes Dashboard

## 🔄 Wartung und Updates

### Script-Updates
```bash
# Aktuellste Version holen
cd toolbox
git pull origin main

# Script-Version prüfen (falls implementiert)
namespace-logs --version
```

### Log-Rotation Setup
```bash
# Automatische Bereinigung alter Export-Verzeichnisse
find /backup/logs -type d -name "*-*-*" -mtime +30 -exec rm -rf {} \;
```