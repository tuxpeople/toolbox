# 🚀 Lima Kubernetes Cluster Manager

Lima-basierte Kubernetes und k3s Cluster für lokale Entwicklung verwalten.

## 📋 Überblick

Dieses Tool vereinfacht die Verwaltung von Lima VMs für Kubernetes-Entwicklung. Es unterstützt sowohl vollständige Kubernetes-Cluster als auch leichtgewichtige k3s-Distributionen.

**Unterstützte Cluster-Typen:**
- **k8s** - Vollständiges Kubernetes mit kubeadm
- **k3s** - Lightweight k3s Distribution

## 🚀 Schnellstart

```bash
# k8s Cluster starten
./lima-k8s start k8s

# k3s Cluster starten
./lima-k8s start k3s

# Status aller Cluster anzeigen
./lima-k8s status

# Cluster stoppen
./lima-k8s stop k8s

# Cluster komplett zerstören (stoppen + löschen)
./lima-k8s destroy k3s --force
```

## ⚙️ Installation

### Voraussetzungen

```bash
# Lima installieren (macOS)
brew install lima

# Lima installieren (andere Systeme)
# Siehe: https://github.com/lima-vm/lima#installation
```

### System-Anforderungen
- **RAM:** Mindestens 4GB verfügbar
- **CPU:** Mindestens 2 Kerne
- **Speicher:** Ca. 10GB für jeden Cluster

## 📖 Verwendung

### Grundlegende Syntax

```bash
./lima-k8s <command> <type> [options]
```

### Commands

| Command | Beschreibung |
|---------|-------------|
| `start` | Erstellt und startet einen Cluster |
| `stop` | Stoppt einen laufenden Cluster |
| `destroy` | Stoppt und löscht einen Cluster komplett |
| `status` | Zeigt Status aller Cluster an |
| `list` | Listet verfügbare Cluster-Typen auf |

### Cluster-Typen

| Typ | Beschreibung | Konfiguration |
|-----|-------------|---------------|
| `k8s` | Vollständiges Kubernetes | [k8s.yaml](https://raw.githubusercontent.com/lima-vm/lima/master/examples/k8s.yaml) |
| `k3s` | Lightweight k3s | [k3s.yaml](https://raw.githubusercontent.com/lima-vm/lima/master/examples/k3s.yaml) |

### Optionen

| Option | Beschreibung |
|--------|-------------|
| `-f, --force` | Keine Bestätigung vor destructiven Operationen |
| `-v, --verbose` | Detaillierte Ausgabe |
| `-h, --help` | Hilfe anzeigen |

## 💡 Beispiele

### Cluster-Management

```bash
# Neuen k8s Cluster erstellen und starten
./lima-k8s start k8s

# k3s Cluster mit detaillierter Ausgabe starten
./lima-k8s start k3s --verbose

# Cluster stoppen (mit Bestätigung)
./lima-k8s stop k8s

# Cluster ohne Bestätigung zerstören
./lima-k8s destroy k3s --force

# Status aller Cluster prüfen
./lima-k8s status
```

### Kubectl-Integration

Nach dem Start eines Clusters:

```bash
# Kubeconfig-Pfad exportieren (k8s)
export KUBECONFIG=$HOME/.lima/k8s/copied-from-guest/kubeconfig.yaml

# Kubeconfig-Pfad exportieren (k3s)
export KUBECONFIG=$HOME/.lima/k3s/copied-from-guest/kubeconfig.yaml

# Cluster testen
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🔧 Erweiterte Verwendung

### Mehrere Cluster parallel

```bash
# Beide Cluster-Typen gleichzeitig betreiben
./lima-k8s start k8s
./lima-k8s start k3s

# Status beider Cluster prüfen
./lima-k8s status
```

### Troubleshooting

```bash
# Detaillierte Ausgabe für Debugging
./lima-k8s start k8s --verbose

# Cluster-Status direkt über Lima prüfen
limactl list

# In Cluster-VM einloggen
limactl shell k8s
limactl shell k3s

# Cluster-Logs anzeigen
limactl show-log k8s
limactl show-log k3s
```

## 🛠️ Fehlerbehebung

### Häufige Probleme

**Problem:** "limactl: command not found"
```bash
# Lösung: Lima installieren
brew install lima
```

**Problem:** Cluster startet nicht
```bash
# Prüfen ob genügend Ressourcen verfügbar sind
# RAM: mindestens 4GB, CPU: 2+ Kerne

# Lima-Status prüfen
limactl list

# Logs überprüfen
limactl show-log k8s --follow
```

**Problem:** kubectl kann nicht auf Cluster zugreifen
```bash
# Kubeconfig-Pfad prüfen und setzen
ls $HOME/.lima/k8s/copied-from-guest/kubeconfig.yaml
export KUBECONFIG=$HOME/.lima/k8s/copied-from-guest/kubeconfig.yaml
```

**Problem:** Port-Konflikte
```bash
# Andere Cluster oder Services stoppen
./lima-k8s stop k8s
./lima-k8s stop k3s

# Oder andere Lima VMs prüfen
limactl list
```

### Cluster zurücksetzen

```bash
# Kompletter Reset eines Clusters
./lima-k8s destroy k8s --force
./lima-k8s start k8s
```

## ⚡ Performance-Tipps

- **Multi-Core Nutzung:** Lima nutzt standardmässig mehrere CPU-Kerne
- **Memory-Optimierung:** k3s verbraucht deutlich weniger RAM als k8s
- **SSD empfohlen:** Für bessere I/O-Performance
- **Resource Limits:** Bei mehreren Clustern Limits beachten

## 🔐 Sicherheitshinweise

⚠️ **Wichtige Sicherheitsaspekte:**

- **Lokale Entwicklung:** Nur für lokale Entwicklung verwenden
- **Netzwerk-Zugriff:** Cluster sind standardmässig nur lokal erreichbar
- **Authentifizierung:** Kubeconfig-Dateien sicher aufbewahren
- **Destructive Operations:** `destroy` löscht alle Daten unwiderruflich
- **Resource Usage:** Cluster können signifikante Systemressourcen verwenden

## 📊 Cluster-Vergleich

| Feature | k8s | k3s |
|---------|-----|-----|
| **RAM-Verbrauch** | ~2-4GB | ~0.5-1GB |
| **Startup-Zeit** | 3-5 Minuten | 1-2 Minuten |
| **Features** | Vollständig | Core-Features |
| **Use Case** | Production-ähnlich | Entwicklung/Edge |
| **Komplexität** | Hoch | Niedrig |

## 🤝 Beitragen

Verbesserungsvorschläge und Fehlermeldungen sind willkommen!

### Entwicklung

```bash
# Script testen
./lima-k8s --help

# Syntax prüfen
shellcheck lima-k8s

# Funktionstest
./lima-k8s list
./lima-k8s status
```

## 📚 Weiterführende Links

- [Lima Documentation](https://github.com/lima-vm/lima)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [k3s Documentation](https://k3s.io/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

**⚠️ Verwendung auf eigene Gefahr** - Keine Garantie für Funktionalität oder Sicherheit