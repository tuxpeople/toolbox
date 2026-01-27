# kubectl-backup - Kubernetes Cluster Backup Tool

Exportiert alle Kubernetes-Ressourcen (cluster-weit und namespace-spezifisch) in YAML-Dateien für Backup, Disaster Recovery oder Cluster-Migration.

## 🎯 Zweck

Das `kubectl-backup` Tool automatisiert das Exportieren aller Kubernetes-Ressourcen in einem Cluster oder spezifischen Namespace. Es erstellt eine vollständige Struktur von YAML-Dateien, die alle Cluster-Ressourcen (wie Nodes, ClusterRoles) und Namespace-Ressourcen (wie Deployments, Services, ConfigMaps, Secrets) enthält. Zusätzlich werden mit einer eingebauten yq-basierten Bereinigungsfunktion automatisch bereinigte Versionen erstellt, die nur die wesentlichen Konfigurationen ohne Kubernetes-interne Metadaten enthalten.

## 📋 Voraussetzungen

### Pflicht
- **kubectl** - Kubernetes Command Line Tool (muss installiert und konfiguriert sein)
- **Bash 4.0+** - Für erweiterte Funktionen
- **Kubernetes-Cluster-Zugriff** - kubectl muss mit einem funktionsfähigen Cluster verbunden sein
- **Berechtigungen** - Leserechte auf alle zu exportierenden Ressourcen

### Optional (für automatische YAML-Bereinigung)
- **yq** - YAML-Prozessor für eingebaute Bereinigungsfunktion (empfohlen)
- **kubectl-neat** - Fallback-Alternative zu yq (deprecated, nicht mehr aktiv maintained)

**Hinweis**: Das Script hat eine **eingebaute Bereinigungsfunktion** die yq verwendet, um Kubernetes-Metadaten zu entfernen. Falls yq nicht verfügbar ist, wird kubectl-neat als Fallback versucht. Nur wenn **beide Tools fehlen**, werden bereinigte Versionen übersprungen und nur Standard-YAMLs exportiert.

## 🚀 Installation

### kubectl installieren (Pflicht)
```bash
# macOS
brew install kubectl

# Linux
# Siehe https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
```

### yq installieren (Optional, aber empfohlen)
```bash
# macOS
brew install yq

# Linux
# Siehe https://github.com/mikefarah/yq#install
```

### kubectl-neat installieren (Optional, deprecated)
```bash
# macOS
brew install kubectl-neat

# Alternativ via Go
go install github.com/itaysk/kubectl-neat/cmd/kubectl-neat@latest

# Hinweis: kubectl-neat ist nicht mehr aktiv maintained
# yq ist die empfohlene Alternative
```

### kubectl-backup installieren (Das Tool selbst)
```bash
# Repository klonen
git clone https://github.com/tuxpeople/toolbox.git
cd toolbox/kubectl-backup

# Script ausführbar machen (falls noch nicht geschehen)
chmod +x kubectl-backup

# Zu PATH hinzufügen (optional)
sudo ln -s "$(pwd)/kubectl-backup" /usr/local/bin/kubectl-backup
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
kubectl-backup [OPTIONEN]
```

### Parameter

| Option | Lang-Form | Beschreibung | Standard |
|--------|-----------|--------------|----------|
| `-o` | `--output-dir DIR` | Output-Verzeichnis | `backup` |
| `-n` | `--namespace NS` | Nur spezifischen Namespace exportieren | Alle Namespaces |
| | `--skip-clean` | Bereinigte Versionen überspringen | - |
| | `--use-kubectl-neat` | kubectl-neat statt yq verwenden (deprecated) | - |
| `-v` | `--verbose` | Detaillierte Ausgabe | - |
| | `--dry-run` | Nur anzeigen was gemacht würde | - |
| `-f` | `--force` | Überschreibe ohne Nachfrage | - |
| `-h` | `--help` | Hilfe anzeigen | - |

### Beispiele

```bash
# Standard-Backup ins 'backup' Verzeichnis
kubectl-backup

# Backup in spezifisches Verzeichnis
kubectl-backup -o cluster-backup-2025-01-22

# Nur einen spezifischen Namespace exportieren
kubectl-backup -n production -o production-backup

# Dry-Run um zu sehen was exportiert würde
kubectl-backup --dry-run

# Mit detaillierter Ausgabe
kubectl-backup --verbose

# Ohne bereinigte Versionen (nur Standard-YAML)
kubectl-backup --skip-clean

# Mit kubectl-neat statt yq (deprecated)
kubectl-backup --use-kubectl-neat

# Existierendes Verzeichnis ohne Nachfrage überschreiben
kubectl-backup -o backup --force

# Kombination mehrerer Optionen
kubectl-backup -o production-backup -n production --verbose
```

## 📄 Ausgabe-Beispiel

### Erfolgreicher Backup
```bash
$ kubectl-backup -o cluster-backup

[INFO] kubectl-backup - Kubernetes Cluster Backup Tool
[INFO] Verwende yq für bereinigte YAMLs (empfohlen)
[INFO] Exportiere cluster-weite Ressourcen...
[PROGRESS] Cluster-weite Ressourcen: 1/25 - Typ: nodes
[PROGRESS] Cluster-weite Ressourcen: 2/25 - Typ: namespaces
[PROGRESS] Cluster-weite Ressourcen: 3/25 - Typ: persistentvolumes
...
[INFO] Exportiere namespace-spezifische Ressourcen...
[PROGRESS] Namespace 1/5: production
[PROGRESS]   └─ Namespace production: 10/67 Ressourcen-Typen
[PROGRESS]   └─ Namespace production: 20/67 Ressourcen-Typen
...
[PROGRESS] Namespace 2/5: staging
[PROGRESS]   └─ Namespace staging: 10/67 Ressourcen-Typen
...
[SUCCESS] Backup abgeschlossen
[INFO] Statistiken:
[INFO]   Total Ressourcen: 247
[INFO]   Erfolgreich: 245
[WARN]   Fehler: 2
[SUCCESS] Alle Ressourcen exportiert nach: cluster-backup
[WARN] ⚠️  WICHTIG: Backup enthält möglicherweise Secrets - sichere Aufbewahrung erforderlich!
```

### Verzeichnis-Struktur
```
backup/
├── global/                          # Cluster-weite Ressourcen
│   ├── nodes/
│   │   ├── node-1.yaml
│   │   ├── node-1-clean.yaml
│   │   ├── node-2.yaml
│   │   └── node-2-clean.yaml
│   ├── clusterroles/
│   │   ├── admin.yaml
│   │   ├── admin-clean.yaml
│   │   ├── edit.yaml
│   │   └── edit-clean.yaml
│   ├── clusterrolebindings/
│   ├── storageclasses/
│   └── persistentvolumes/
├── production/                      # Namespace: production
│   ├── deployments/
│   │   ├── frontend.yaml
│   │   ├── frontend-clean.yaml
│   │   ├── backend.yaml
│   │   └── backend-clean.yaml
│   ├── services/
│   │   ├── frontend.yaml
│   │   ├── frontend-clean.yaml
│   │   ├── backend.yaml
│   │   └── backend-clean.yaml
│   ├── configmaps/
│   ├── secrets/
│   ├── persistentvolumeclaims/
│   └── ingresses/
├── staging/                         # Namespace: staging
│   ├── deployments/
│   ├── services/
│   └── ...
└── kube-system/                     # Namespace: kube-system
    ├── deployments/
    ├── services/
    └── ...
```

### Verbose-Ausgabe
```bash
$ kubectl-backup --verbose

[INFO] kubectl-backup - Kubernetes Cluster Backup Tool
[INFO] Verwende yq für bereinigte YAMLs (empfohlen)
[INFO] Exportiere cluster-weite Ressourcen...
[VERBOSE] Verarbeite Ressourcen-Typ: nodes
[VERBOSE] Exportiert: backup/global/nodes/node-1.yaml
[VERBOSE] Exportiert (clean/yq): backup/global/nodes/node-1-clean.yaml
[VERBOSE] Verarbeite Ressourcen-Typ: clusterroles
[VERBOSE] Exportiert: backup/global/clusterroles/admin.yaml
[VERBOSE] Exportiert (clean/yq): backup/global/clusterroles/admin-clean.yaml
[INFO] Exportiere namespace-spezifische Ressourcen...
[VERBOSE] Verarbeite Namespace: production
[VERBOSE] Verarbeite Ressourcen-Typ: deployments in Namespace: production
[VERBOSE] Exportiert: backup/production/deployments/frontend.yaml
[VERBOSE] Exportiert (clean/yq): backup/production/deployments/frontend-clean.yaml
...
```

### Dry-Run Ausgabe
```bash
$ kubectl-backup --dry-run

Würde exportieren: global nodes node-1
Würde exportieren: global nodes node-2
Würde exportieren: global clusterroles admin
Würde exportieren: deployments frontend aus Namespace production
Würde exportieren: services frontend aus Namespace production
...
[SUCCESS] Backup abgeschlossen
[INFO] Statistiken:
[INFO]   Total Ressourcen: 247
[INFO]   Erfolgreich: 247
[INFO] Dry-Run abgeschlossen - keine Dateien erstellt
```

## 🔧 Funktionsweise

1. **Cluster-Verbindung prüfen**: Stellt sicher, dass kubectl korrekt konfiguriert ist
2. **Abhängigkeiten prüfen**: Validiert, dass kubectl verfügbar ist
3. **Bereinigungsmethode wählen**:
   - **Standard**: yq mit eingebauter Bereinigungsfunktion (empfohlen)
   - **Fallback**: kubectl-neat (via `--use-kubectl-neat`, deprecated)
   - **Überspringen**: `--skip-clean` oder automatisch wenn beide Tools fehlen
4. **Cluster-weite Ressourcen exportieren**:
   - Listet alle cluster-weiten Ressourcen-Typen auf (via `kubectl api-resources --namespaced=false`)
   - Zeigt Fortschritt: `[PROGRESS] Cluster-weite Ressourcen: 1/25 - Typ: nodes`
   - Für jeden Ressourcen-Typ werden alle Instanzen exportiert
   - Erstellt YAML-Dateien unter `{output_dir}/global/{resource_type}/{name}.yaml`
5. **Namespace-spezifische Ressourcen exportieren**:
   - Listet alle Namespaces auf (oder verwendet den angegebenen Namespace)
   - Zeigt Fortschritt: `[PROGRESS] Namespace 1/5: production`
   - Für jeden Namespace werden alle Ressourcen-Typen exportiert
   - Zeigt Sub-Fortschritt: `[PROGRESS]   └─ Namespace production: 10/67 Ressourcen-Typen`
   - Erstellt YAML-Dateien unter `{output_dir}/{namespace}/{resource_type}/{name}.yaml`
6. **Bereinigte Versionen erstellen**:
   - Mit eingebauter yq-Bereinigungsfunktion (Standard) oder kubectl-neat (Fallback) werden bereinigte Versionen ohne Kubernetes-Metadaten erstellt
   - Die eingebaute Funktion entfernt automatisch: `.status`, `.metadata.uid`, `.metadata.resourceVersion`, `.metadata.generation`, `.metadata.creationTimestamp`, `.metadata.managedFields`, `.metadata.selfLink`
   - Suffixiert mit `-clean.yaml`
7. **Statistiken anzeigen**: Zeigt Anzahl exportierter Ressourcen und Fehler an

## 🏢 Anwendungsfälle

### Disaster Recovery Backup
```bash
# Tägliches Cluster-Backup
kubectl-backup -o "backup-$(date +%Y-%m-%d)" --force

# Mit Cron automatisieren
0 2 * * * /usr/local/bin/kubectl-backup -o /backups/cluster-$(date +\%Y-\%m-\%d) --force
```

### Cluster-Migration
```bash
# Vollständigen Cluster exportieren
kubectl-backup -o migration-source --verbose

# Später: Ressourcen im neuen Cluster anwenden (bereinigte Versionen)
cd migration-source
for yaml in $(find . -name "*-clean.yaml"); do
  kubectl apply -f "$yaml"
done
```

### Namespace-Backup vor Änderungen
```bash
# Backup vor grossen Änderungen
kubectl-backup -n production -o production-backup-before-update

# Nach erfolgreichem Update
kubectl-backup -n production -o production-backup-after-update

# Vergleich
diff -r production-backup-before-update production-backup-after-update
```

### Audit und Compliance
```bash
# Monatliches Compliance-Backup
kubectl-backup -o "audit/cluster-$(date +%Y-%m)" --force

# Nur sicherheitsrelevante Namespaces
for ns in production staging security; do
  kubectl-backup -n "$ns" -o "audit/$(date +%Y-%m)/${ns}"
done
```

### Development Environment Snapshot
```bash
# Entwicklungs-Cluster sichern (ohne bereinigte Versionen)
kubectl-backup -o dev-snapshot --skip-clean

# Später wiederherstellen
kubectl apply -f dev-snapshot/
```

## ⚠️ Hinweise

### Sicherheit
- **Secrets werden exportiert**: Das Backup enthält alle Kubernetes-Secrets im Klartext
- **Sichere Aufbewahrung**: Backups müssen verschlüsselt und sicher gespeichert werden
- **Zugriffsrechte**: Setze restriktive Berechtigungen auf Backup-Verzeichnisse (`chmod 700`)
- **Verschlüsselung empfohlen**: Verwende Tools wie `gpg` oder `age` zur Verschlüsselung

### Performance
- **Grosse Cluster**: Bei Clustern mit vielen Ressourcen kann der Export Zeit brauchen
- **Netzwerk-Latenz**: Jede Ressource wird einzeln über kubectl abgefragt
- **Speicherplatz**: Backups können mehrere GB gross werden
- **Parallele Ausführung**: Aktuell keine Parallelisierung - sequenzieller Export
- **Minimal-Modus**: Ohne yq/kubectl-neat ist das Script am schnellsten (nur Standard-YAMLs)

### Bereinigungsmethoden
- **yq mit eingebauter Funktion (empfohlen)**:
  - Das Script hat eine eigene Bereinigungsfunktion die yq verwendet
  - Entfernt automatisch alle Kubernetes-Metadaten (status, uid, resourceVersion, etc.)
  - Aktiv maintained, zuverlässig, universell einsetzbar
  - Installation: `brew install yq`
- **kubectl-neat (Fallback, deprecated)**:
  - Wird nur verwendet wenn yq nicht verfügbar ist oder via `--use-kubectl-neat` explizit gewählt
  - Nicht mehr aktiv maintained
  - Installation: `brew install kubectl-neat`
- **Bereinigte YAMLs**: Einfacher zu lesen, zu versionieren und für Git geeignet
- **Automatisches Fallback**: yq (mit eingebauter Funktion) → kubectl-neat → keine Bereinigung

### Ressourcen-Filter
- **Alle Ressourcen**: Exportiert wirklich ALLE API-Ressourcen
- **Custom Resources**: CRDs und Custom Resources werden mit exportiert
- **Events**: Auch Events werden exportiert (können sehr gross werden)

## 🔍 Troubleshooting

### Script funktioniert ohne yq/kubectl-neat
```bash
# Das Script benötigt nur kubectl als Pflicht-Abhängigkeit
kubectl-backup -o backup

# Ausgabe wenn weder yq noch kubectl-neat verfügbar:
[INFO] kubectl-backup - Kubernetes Cluster Backup Tool
[WARN] Weder yq noch kubectl-neat installiert - bereinigte Versionen werden übersprungen
[INFO] Installation: brew install yq (empfohlen für eingebaute Bereinigungsfunktion)
[INFO] Exportiere cluster-weite Ressourcen...
# ... Export läuft normal, nur ohne -clean.yaml Dateien
```

**Ergebnis**: Alle Standard-YAMLs werden exportiert, nur die bereinigten `-clean.yaml` Versionen fehlen, da die eingebaute Bereinigungsfunktion yq benötigt.

### Fehler: "Keine Verbindung zum Kubernetes-Cluster möglich"
```bash
# kubectl-Konfiguration prüfen
kubectl cluster-info
kubectl config get-contexts

# Kontext wechseln
kubectl config use-context <context-name>

# KUBECONFIG prüfen
echo $KUBECONFIG
```

### Warnung: "Weder yq noch kubectl-neat installiert"
```bash
# yq installieren (empfohlen)
brew install yq              # macOS

# Oder kubectl-neat installieren (deprecated)
brew install kubectl-neat    # macOS
go install github.com/itaysk/kubectl-neat/cmd/kubectl-neat@latest

# Oder bereinigte Versionen überspringen
kubectl-backup --skip-clean
```

### Fehler beim Exportieren einzelner Ressourcen
- **Berechtigungen prüfen**: `kubectl auth can-i get <resource>`
- **Verbose-Modus**: `kubectl-backup --verbose` zeigt Details
- **Ressource manuell prüfen**: `kubectl get <resource> -o yaml`

### Backup ist sehr gross
```bash
# Nur einen Namespace exportieren
kubectl-backup -n production -o production-only

# Ohne bereinigte Versionen (spart ~50% Platz)
kubectl-backup --skip-clean

# Events ausschliessen (manuell)
# Editiere das Script und füge Events zur Ausschlussliste hinzu
```

### Berechtigungsfehler
```bash
# Erforderliche Berechtigungen prüfen
kubectl auth can-i get pods --all-namespaces
kubectl auth can-i get nodes

# Als Cluster-Admin ausführen (falls verfügbar)
kubectl config use-context admin-context
```

## 💡 Tipps & Tricks

### Automatisches Tägliches Backup
```bash
# Crontab-Eintrag (täglich um 2 Uhr nachts)
0 2 * * * /usr/local/bin/kubectl-backup -o /backups/k8s-$(date +\%Y-\%m-\%d) --force 2>&1 | logger -t kubectl-backup

# Mit Log-Rotation (behalte nur letzte 7 Backups)
0 2 * * * /usr/local/bin/kubectl-backup -o /backups/k8s-$(date +\%Y-\%m-\%d) --force && find /backups -name "k8s-*" -mtime +7 -delete
```

### Verschlüsseltes Backup
```bash
# Backup erstellen und verschlüsseln
kubectl-backup -o backup-temp && tar czf - backup-temp | gpg -c > backup-$(date +%Y-%m-%d).tar.gz.gpg && rm -rf backup-temp

# Entschlüsseln und extrahieren
gpg -d backup-2025-01-22.tar.gz.gpg | tar xzf -
```

### Git-Versionierung
```bash
# Backup in Git-Repository
kubectl-backup -o k8s-backup --force
cd k8s-backup
git init
git add .
git commit -m "Cluster backup $(date +%Y-%m-%d)"
git remote add origin <your-repo-url>
git push origin main
```

### Nur bereinigte YAMLs
```bash
# Standard-YAMLs nach Export löschen
kubectl-backup -o backup
find backup -name "*.yaml" ! -name "*-clean.yaml" -delete
```

### Vergleich zwischen Backups
```bash
# Zwei Backups vergleichen
diff -r backup-2025-01-20 backup-2025-01-22 | less

# Nur geänderte Dateien anzeigen
diff -r backup-2025-01-20 backup-2025-01-22 | grep "differ"

# Mit git diff (bessere Lesbarkeit)
git diff --no-index backup-2025-01-20 backup-2025-01-22
```

### Selektiver Restore
```bash
# Nur Deployments wiederherstellen (bereinigte Version)
find backup/production/deployments -name "*-clean.yaml" -exec kubectl apply -f {} \;

# Nur spezifischen Namespace (bereinigte Versionen)
find backup/production -name "*-clean.yaml" -exec kubectl apply -f {} \;

# Nur spezifischen Namespace (Standard-Versionen)
kubectl apply -R -f backup/production/
```

### Backup-Grösse reduzieren
```bash
# Ohne Events
kubectl-backup -o backup
find backup -type d -name "events" -exec rm -rf {} \;

# Nur bereinigte YAMLs behalten (spart ~50% Platz)
kubectl-backup -o backup
find backup -name "*.yaml" ! -name "*-clean.yaml" -delete

# Komprimieren
tar czf backup-$(date +%Y-%m-%d).tar.gz backup/
```

## 📚 Verwandte Tools

### Kubernetes-Tools in dieser Toolbox
- **[k8s-vuln](../k8s-vuln/)** - Kubernetes Vulnerability Scanner
- **[namespace-logs](../namespace-logs/)** - Namespace Log Exporter
- **[k8s-image-arches](../k8s-image-arches/)** - Image Architecture Analyzer

### Externe Tools
- **[velero](https://velero.io/)** - Professionelles Kubernetes Backup Tool mit Volume-Support
- **[yq](https://github.com/mikefarah/yq)** - YAML-Prozessor (empfohlen für Bereinigung)
- **[kubectl-neat](https://github.com/itaysk/kubectl-neat)** - YAML-Bereinigung (deprecated)
- **[k9s](https://k9scli.io/)** - Terminal UI für Kubernetes
- **[kustomize](https://kustomize.io/)** - Kubernetes-Konfigurationsmanagement
- **[helm](https://helm.sh/)** - Kubernetes Package Manager
- **[git-crypt](https://github.com/AGWA/git-crypt)** - Verschlüsselung für Git-Repositories

### Alternative Backup-Strategien
- **Velero**: Für produktive Backups mit Volumes
- **Kube-backup**: Ähnliches Tool mit Git-Integration
- **ETCD-Backup**: Direkte ETCD-Datenbank-Backups
- **Helm-Charts**: Versionierte Application-Deployments
