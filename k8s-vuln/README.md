# Kubernetes Vulnerability Scanner

Ein leistungsstarker Scanner zur Erkennung von Sicherheitslücken in Container-Images eines Kubernetes-Clusters mit Trivy.

## 🎯 Zweck

Kubernetes-Cluster enthalten oft viele Container-Images aus verschiedenen Quellen. Dieses Tool:

1. **Extrahiert alle Container-Images** aus dem Cluster
2. **Scannt auf spezifische CVEs** oder Vulnerability-Pattern
3. **Unterstützt verschiedene Namespaces** und Severity-Level
4. **Bietet verschiedene Output-Formate** (Table, JSON, SARIF)
5. **Integriert mit CI/CD-Pipelines** durch Exit-Codes

## 📋 Voraussetzungen

- **Trivy** - Vulnerability Scanner:
  ```bash
  # macOS
  brew install trivy
  
  # Linux
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
  ```

- **kubectl** - Kubernetes CLI:
  ```bash
  # macOS
  brew install kubectl
  
  # Linux
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  ```

- **Konfigurierter Kubernetes-Zugriff**

## 🚀 Installation

```bash
# Script herunterladen
curl -o k8s_vuln https://raw.githubusercontent.com/tuxpeople/toolbox/main/k8s_vuln/k8s_vuln
chmod +x k8s_vuln
```

## 💻 Verwendung

### Grundlegende Syntax
```bash
./k8s_vuln <cve-id|vulnerability> [options]
```

### Optionen
- `-n, --namespace NAMESPACE` - Nur bestimmten Namespace scannen
- `-s, --severity SEVERITY` - Minimum Severity (LOW,MEDIUM,HIGH,CRITICAL)
- `-o, --output FORMAT` - Ausgabeformat (table,json,sarif)
- `-v, --verbose` - Detaillierte Ausgabe
- `-q, --quiet` - Nur vulnerable Images anzeigen
- `--no-progress` - Fortschrittsbalken deaktivieren
- `--timeout SECONDS` - Timeout pro Image (Standard: 300)

### Beispiele

**Standard CVE-Scan:**
```bash
./k8s_vuln CVE-2021-44228                    # Log4j
./k8s_vuln CVE-2022-0492                     # Container Escape
./k8s_vuln CVE-2021-3156                     # Sudo Baron Samedit
```

**Mit Optionen:**
```bash
./k8s_vuln CVE-2021-44228 -s HIGH            # Nur HIGH+ Severity
./k8s_vuln log4j -n production               # Nur production Namespace
./k8s_vuln CVE-2021-44228 --quiet            # Nur vulnerable Images
./k8s_vuln CVE-2021-44228 -v                 # Detaillierte Ausgabe
```

**JSON/SARIF Output:**
```bash
./k8s_vuln CVE-2021-44228 -o json > results.json
./k8s_vuln CVE-2021-44228 -o sarif > results.sarif
```

## 📄 Ausgabe-Beispiel

```bash
$ ./k8s_vuln CVE-2021-44228 -v

[INFO] Kubernetes Vulnerability Scanner gestartet
[INFO] Prüfe Kubernetes-Zugriff...
[INFO] Verbunden mit Cluster: production-cluster
[INFO] Starte Vulnerability-Scan für: CVE-2021-44228
[INFO] Namespace: Alle
[INFO] Extrahiere Container-Images aus Cluster...
[INFO] Gefundene Images: 12
[INFO] Scanne Image (1/12): nginx:1.21
[SAFE] nginx:1.21 ist sicher
[INFO] Scanne Image (2/12): openjdk:11-jre-slim
[VULNERABLE] openjdk:11-jre-slim ist vulnerable!
[INFO] Scanne Image (3/12): postgres:13
[SAFE] postgres:13 ist sicher

[INFO] === Scan-Zusammenfassung ===
[INFO] Gescannte Images: 12
[SUCCESS] Sichere Images: 10
[VULNERABLE] Vulnerable Images: 2
```

## 🔧 Funktionsweise

### Workflow:

1. **Abhängigkeits-Check**
   - Prüft trivy und kubectl Verfügbarkeit
   - Validiert Kubernetes-Cluster-Zugriff

2. **Image-Extraktion**
   - Holt alle Container-Images aus Pods
   - Berücksichtigt sowohl normale als auch Init-Container
   - Dedupliziert automatisch

3. **Vulnerability-Scanning**
   - Scannt jedes Image mit Trivy
   - Filtert nach Severity-Level
   - Sucht nach spezifischen CVEs oder Patterns

4. **Ergebnis-Verarbeitung**
   - Kategorisiert sichere vs. vulnerable Images
   - Generiert detaillierte Reports bei Bedarf
   - Liefert strukturierte Exit-Codes

### Exit-Codes:
- **0** - Alle Images sicher
- **1** - Scan-Fehler aufgetreten
- **2** - Vulnerable Images gefunden

## 🏢 Anwendungsfälle

### Security Audits
```bash
# Vollständiger Cluster-Audit
./k8s_vuln CVE-2021-44228 -v > audit_log4j.txt

# Kritische Vulnerabilities
./k8s_vuln CVE-2022-0492 -s CRITICAL
```

### CI/CD Integration
```bash
#!/bin/bash
# In CI-Pipeline
if ! ./k8s_vuln CVE-2021-44228 -q; then
    echo "❌ Vulnerable Images gefunden!"
    exit 1
fi
echo "✅ Alle Images sicher"
```

### Namespace-spezifische Scans
```bash
# Production-Umgebung
./k8s_vuln CVE-2021-44228 -n production

# Alle kritischen Namespaces
for ns in production staging kube-system; do
    echo "=== Scanning $ns ==="
    ./k8s_vuln CVE-2021-44228 -n $ns
done
```

### Compliance-Reports
```bash
# SARIF für Security-Tools
./k8s_vuln CVE-2021-44228 -o sarif > compliance_report.sarif

# JSON für weitere Verarbeitung
./k8s_vuln CVE-2021-44228 -o json | jq '.Results[] | select(.Vulnerabilities)'
```

## 🌐 Unterstützte Vulnerability-Types

**CVE-Identifiers:**
- `CVE-2021-44228` (Log4j)
- `CVE-2022-0492` (Container Escape)
- `CVE-2021-3156` (Sudo Baron Samedit)
- Alle anderen CVE-IDs

**Pattern-Matching:**
- `log4j` - Log4j-bezogene Vulnerabilities
- `sudo` - Sudo-bezogene Vulnerabilities
- `openssl` - OpenSSL-Vulnerabilities

**Severity-Level:**
- `LOW` - Niedrige Priorität
- `MEDIUM` - Mittlere Priorität  
- `HIGH` - Hohe Priorität
- `CRITICAL` - Kritische Vulnerabilities

## ⚠️ Hinweise

- **Netzwerk erforderlich** - Trivy lädt Vulnerability-Datenbanken
- **Cluster-Zugriff** - kubectl muss konfiguriert sein
- **Performance** - Grosse Cluster können längere Scan-Zeiten haben
- **Rate-Limiting** - Bei vielen Images können Registry-Limits greifen

## 🔍 Troubleshooting

### Häufige Probleme

**"trivy nicht gefunden"**
```bash
# Installation prüfen
which trivy

# macOS Installation
brew install trivy

# Manual Installation
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
```

**"Keine Verbindung zum Kubernetes-Cluster"**
```bash
# Cluster-Info prüfen
kubectl cluster-info

# Context prüfen
kubectl config current-context

# Credentials erneuern
kubectl config view
```

**"Timeout bei Image-Scans"**
```bash
# Timeout erhöhen
./k8s_vuln CVE-2021-44228 --timeout 600

# Einzelne Images testen
trivy image nginx:latest
```

**"Keine Images gefunden"**
```bash
# Pods prüfen
kubectl get pods -A

# Namespace prüfen
kubectl get pods -n specific-namespace

# Permissions prüfen
kubectl auth can-i get pods --all-namespaces
```

### Debug-Modus

```bash
# Maximale Ausgabe
./k8s_vuln CVE-2021-44228 --verbose

# Trivy direkt testen
trivy image --severity CRITICAL nginx:latest

# kubectl direkt testen
kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{" "}'
```

## 💡 Performance-Tipps

### Optimierung für grosse Cluster
```bash
# Nur kritische Vulnerabilities
./k8s_vuln CVE-2021-44228 -s CRITICAL

# Spezifische Namespaces
./k8s_vuln CVE-2021-44228 -n production

# Quiet Mode für Automation
./k8s_vuln CVE-2021-44228 --quiet --no-progress
```

### Parallelisierung
```bash
# Namespaces parallel scannen
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
    ./k8s_vuln CVE-2021-44228 -n $ns &
done
wait
```

## 🚨 Bekannte Vulnerabilities

### Kritische CVEs zum Testen:
- **CVE-2021-44228** - Log4Shell (Log4j)
- **CVE-2022-0492** - Container Escape via cgroups
- **CVE-2021-3156** - Sudo Baron Samedit
- **CVE-2022-22965** - Spring4Shell
- **CVE-2021-34527** - PrintNightmare
- **CVE-2022-26134** - Atlassian Confluence RCE

## 🔗 Integration mit anderen Tools

### GitLab CI/CD
```yaml
vuln_scan:
  stage: security
  script:
    - ./k8s_vuln CVE-2021-44228 -o json > vulnerability_report.json
  artifacts:
    reports:
      security: vulnerability_report.json
  only:
    - main
```

### GitHub Actions
```yaml
- name: K8s Vulnerability Scan
  run: |
    ./k8s_vuln CVE-2021-44228 --quiet
  env:
    KUBECONFIG: ${{ secrets.KUBECONFIG }}
```

### Prometheus/Grafana Monitoring
```bash
# Metriken für Monitoring generieren
vuln_count=$(./k8s_vuln CVE-2021-44228 --quiet | grep VULNERABLE | wc -l)
echo "k8s_vulnerable_images{cve=\"CVE-2021-44228\"} $vuln_count" | curl -X POST http://pushgateway:9091/metrics/job/k8s_vuln
```

## 📚 Verwandte Tools

- **[Trivy](https://github.com/aquasecurity/trivy)** - Container Vulnerability Scanner
- **[Grype](https://github.com/anchore/grype)** - Alternative Vulnerability Scanner
- **[Kubectl](https://kubernetes.io/docs/tasks/tools/)** - Kubernetes CLI
- **[Popeye](https://github.com/derailed/popeye)** - Kubernetes Cluster Sanitizer
- **[Falco](https://falco.org/)** - Runtime Security Monitoring

## 🤝 Beitragen

Verbesserungen und Bug-Fixes sind willkommen! Siehe [Haupt-Repository](../) für Details zur Lizenz.

## 📚 Siehe auch

- [Trivy Dokumentation](https://aquasecurity.github.io/trivy/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [NIST Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [CVE Database](https://cve.mitre.org/)