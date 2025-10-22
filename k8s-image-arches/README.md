# Kubernetes Image Architecture Scanner

Dieses Skript (`k8s-image-arches.sh`) analysiert alle im Kubernetes-Cluster verwendeten Container-Images und zeigt, welche **CPU-Architekturen** (z. B. `linux/amd64`, `linux/arm64`) pro Image verfügbar sind.

Zusätzlich ermittelt es am Ende den **gemeinsamen Nenner** aller Images – also die Architekturen, die *von allen Images im Cluster unterstützt werden*.

---

## 🔧 Voraussetzungen

- `kubectl` (mit Cluster-Zugriff)
- `curl`
- `jq`
- (optional) Lesezugriff auf `imagePullSecrets` in den Namespaces – für private Registries

---

## 🚀 Verwendung

```bash
chmod +x k8s-image-arches.sh
./k8s-image-arches.sh
```

Optional mit Debug-Ausgabe:

```bash
DEBUG=1 ./k8s-image-arches.sh
```

---

## 🧠 Features

- Liest alle Images (Container + InitContainer) aus allen Namespaces
- Unterstützt Docker Hub, GHCR, Quay, Harbor, Rancher/SUSE Registry u.a.
- Prüft jede Registry per OCI-API (`/v2/.../manifests/...`)
- Erkennt Multi-Arch-Images und zeigt alle enthaltenen Plattformen
- Lädt bei fehlenden `os/arch`-Informationen den Child-Manifest + Config nach
- Nutzt vorhandene `imagePullSecrets` (dockerconfigjson) für Authentifizierung
- Ignoriert `arm64/v8`–Variante → behandelt sie als `arm64`
- Zeigt am Ende die Schnittmenge aller Architekturen („gemeinsamer Nenner“)

---

## 📄 Beispielausgabe

```
Image: registry-1.docker.io/library/nginx:1.27
Registry: registry-1.docker.io  Repo: library/nginx  Ref: 1.27
Typ: Multi-Arch Index
  - linux/amd64
  - linux/arm64

Image: registry.rancher.com/rancher/fleet-agent:v0.12.2
Registry: registry.rancher.com  Repo: rancher/fleet-agent  Ref: v0.12.2
Typ: Multi-Arch Index
  - linux/amd64
  - linux/arm64

Gemeinsamer Nenner (Architekturen, die ALLE Images unterstützen):
  - linux/amd64
  - linux/arm64
```

---

## ⚙️ Optionen & Anpassung

- **Nur bestimmte Namespaces scannen:**
  ```bash
  kubectl get pods -n <namespace> ...
  ```
  im Skript anpassen.

- **Weitere Normalisierungen:**  
  Bei Bedarf kann `normalize_arch_lines()` erweitert werden (z. B. um `arm/v7` zusammenzufassen).

- **Nicht-Linux-Systeme:**  
  Standardmäßig filtert das Skript nur `linux/*` heraus.

---

## 🛠 Fehlerbehebung

- `curl: (3) URL rejected`:  
  → tritt auf, wenn Registry-Service-Namen Leerzeichen enthalten; wurde behoben (URL-Encoding).
- Keine Ausgabe?  
  → `set -Euo pipefail` verwenden (nicht `set -e`).
- Auth-Fehler bei privaten Registries?  
  → Sicherstellen, dass der ausführende Benutzer Secrets lesen darf (`kubectl get secrets --all-namespaces`).

---

## 📜 Lizenz

MIT License © 2025  
Autor: [Tobias Deutsch]
