#!/usr/bin/env bash
set -Euo pipefail
trap 'code=$?;
      case "$BASH_COMMAND" in
        *"[[ "* ) ;;                # ignoriere [[ … ]] Bedingungen
        *dbg\ * ) ;;                # ignoriere dbg()-Aufrufe
        *echo* ) ;;                 # ignoriere reine echo-Zeilen
        * ) echo "[ERR] Zeile $LINENO: $BASH_COMMAND (exit $code)" >&2 ;;
      esac' ERR

# ------------------------------------------
# Kubernetes: Images -> verfügbare Architekturen
# Requires: kubectl, curl, jq
# Optional: liest imagePullSecrets für Auth
# DEBUG=1 bash ./k8s-image-arches.sh
# ------------------------------------------

accept_headers=(
  "application/vnd.oci.image.index.v1+json"
  "application/vnd.docker.distribution.manifest.list.v2+json"
  "application/vnd.oci.image.manifest.v1+json"
  "application/vnd.docker.distribution.manifest.v2+json"
)
ACCEPT=$(IFS=, ; echo "${accept_headers[*]}")

declare -A REG_BASIC_B64     # registry -> base64(user:pass)
declare -A REG_IDTOKEN       # registry -> identitytoken

log() { echo >&2 "[INFO] $*"; return 0; }
dbg() {
  if [ "${DEBUG:-0}" = "1" ]; then
    echo >&2 "[DEBUG] $*"
  fi
  return 0
}

# Gemeinsamer Nenner (Set-Intersection)
declare -A COMMON_ARCHES=()
COMMON_INIT=0

update_common() {
  # Liest Arch-Zeilen aus STDIN und intersected sie mit COMMON_ARCHES
  local line
  declare -A CUR=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    CUR["$line"]=1
  done

  if (( COMMON_INIT == 0 )); then
    # Erste Menge initialisiert den COMMON-Satz
    COMMON_ARCHES=()
    for k in "${!CUR[@]}"; do
      COMMON_ARCHES["$k"]=1
    done
    COMMON_INIT=1
  else
    # Intersection: entferne alles aus COMMON, was nicht in CUR ist
    for k in "${!COMMON_ARCHES[@]}"; do
      if [[ -z "${CUR[$k]:-}" ]]; then
        unset 'COMMON_ARCHES[$k]'
      fi
    done
  fi
}


# --- Pull-Secrets laden (dockerconfigjson) ---
load_pull_secrets() {
  local items
  items=$(kubectl get secrets --all-namespaces -o json 2>/dev/null | jq -c '.items[] | select(.type=="kubernetes.io/dockerconfigjson")' || true)
  [[ -z "$items" ]] && { dbg "Keine dockerconfigjson-Secrets (oder keine Rechte)"; return 0; }

  while IFS= read -r item; do
    local cfgb64 cfg
    cfgb64=$(jq -r '.data[".dockerconfigjson"] // empty' <<<"$item")
    [[ -z "$cfgb64" ]] && continue
    cfg=$(base64 -d <<<"$cfgb64" 2>/dev/null || true)
    [[ -z "$cfg" ]] && continue
    jq -r '.auths | to_entries[] | [.key,
        ( .value.auth // ( (.value.username // "") + ":" + (.value.password // "") ) ),
        ( .value.identitytoken // "" )
      ] | @tsv' <<<"$cfg" | while IFS=$'\t' read -r reg auth_or_userpass idtok; do
        [[ -z "$reg" || "$reg" == "null" ]] && continue
        # docker.io Namensraum-Varianten mappen
        if [[ "$reg" == "docker.io" || "$reg" == "index.docker.io" ]]; then reg="registry-1.docker.io"; fi
        if [[ "$auth_or_userpass" == *":"* && "$auth_or_userpass" != *"="* ]]; then
          REG_BASIC_B64["$reg"]=$(printf '%s' "$auth_or_userpass" | base64 -w0)
        elif [[ -n "$auth_or_userpass" && "$auth_or_userpass" != "null" ]]; then
          REG_BASIC_B64["$reg"]="$auth_or_userpass"
        fi
        if [[ -n "$idtok" && "$idtok" != "null" ]]; then REG_IDTOKEN["$reg"]="$idtok"; fi
      done
  done <<<"$items"
}

# --- Image-Ref -> registry repo :tag | @digest ---
normalize_image() {
  local ref="$1"
  ref="${ref//$'\r'/}"        # CR entfernen
  ref="${ref//[$'\t ']/}"     # Tabs/Spaces entfernen

  local registry repo tag digest

  # Digest?
  if [[ "$ref" == *@* ]]; then digest="${ref##*@}"; ref="${ref%@*}"; fi
  # Tag? (Port vs. Tag beachten)
  if [[ "$ref" == *:* && "$ref" != *://* && "${ref##*:}" != */* ]]; then
    tag="${ref##*:}"; ref="${ref%:*}"
  fi

  # Registry bestimmen
  local first rest
  IFS=/ read -r first rest <<<"$ref"
  if [[ "$first" == *.* || "$first" == *:* || "$first" == "localhost" ]]; then
    registry="$first"; repo="$rest"
  else
    registry="registry-1.docker.io"; repo="$ref"
    [[ "$repo" != */* ]] && repo="library/$repo"
  fi

  # Docker-Hub Varianten mappen
  if [[ "$registry" == "docker.io" || "$registry" == "index.docker.io" ]]; then
    registry="registry-1.docker.io"
  fi

  # Defaults
  if [[ -z "${tag:-}" && -z "${digest:-}" ]]; then tag="latest"; fi

  # Minimal-Validierung
  if [[ -z "${registry:-}" || -z "${repo:-}" ]]; then
    return 1
  fi

  if [[ -n "${digest:-}" ]]; then
    printf '%s %s @%s\n' "$registry" "$repo" "$digest"
  else
    printf '%s %s :%s\n' "$registry" "$repo" "$tag"
  fi
}

# --- Bearer-Token (mit URL-Encoding und Pull-Secrets) ---
bearer_token() {
  local registry="$1" repo="$2" scope="${3:-repository:$repo:pull}"

  local hdr
  hdr=$(curl -sS -I "https://$registry/v2/$repo/tags/list" || true)
  if ! grep -qi '^www-authenticate: Bearer' <<<"$hdr"; then
    dbg "Keine Bearer-Challenge für $registry/$repo (evtl. Basic möglich)"
    echo ""; return 0
  fi

  local realm service
  realm=$(grep -i '^www-authenticate:' <<<"$hdr" | sed -n 's/.*realm="\([^"]*\)".*/\1/ip')
  service=$(grep -i '^www-authenticate:' <<<"$hdr" | sed -n 's/.*service="\([^"]*\)".*/\1/ip')

  local auth_hdr=()
  if [[ -n "${REG_IDTOKEN[$registry]:-}" ]]; then
    auth_hdr=(-H "Authorization: Bearer ${REG_IDTOKEN[$registry]}")
  elif [[ -n "${REG_BASIC_B64[$registry]:-}" ]]; then
    auth_hdr=(-H "Authorization: Basic ${REG_BASIC_B64[$registry]}")
  fi

  # URL-encoden (fix für "SUSE Linux Docker Registry")
  local token_json
  token_json=$(curl -sS "${auth_hdr[@]}" --get \
                 --data-urlencode "service=${service}" \
                 --data-urlencode "scope=${scope}" \
                 "$realm" || true)
  jq -r '.token // empty' <<<"$token_json"
}

# --- HTTP JSON holen (Bearer oder Basic) ---
fetch_json() {
  local url="$1" token="$2" registry_for_basic="$3"
  local args=(-sS -H "Accept: $ACCEPT")
  if [[ -n "$token" ]]; then
    args+=(-H "Authorization: Bearer $token")
  elif [[ -n "${REG_BASIC_B64[$registry_for_basic]:-}" ]]; then
    args+=(-H "Authorization: Basic ${REG_BASIC_B64[$registry_for_basic]}")
  fi
  dbg "GET $url"
  curl "${args[@]}" "$url"
}

# --- Multi-Arch: Aus Index lesen, bei unknown/missing per Child-Manifest/Config nachladen ---
list_arches_from_index() {
  local registry="$1" repo="$2" token="$3"
  local index_json
  index_json="$(cat)"   # Index aus STDIN

  # 1) Zuerst alle sauberen Plattform-Einträge (ohne "unknown") ausgeben
  echo "$index_json" | jq -r '
    .manifests[]? 
    | select(.platform and .platform.os and .platform.architecture)
    | select(.platform.os != "unknown" and .platform.architecture != "unknown")
    | {os: .platform.os, arch: .platform.architecture, variant: (.platform.variant // "")}
    | "\(.os)\t\(.arch)\t\(.variant)"
  ' | while IFS=$'\t' read -r os arch variant; do
      if [[ -n "$variant" && "$variant" != "null" ]]; then
        echo "$os/$arch/$variant"
      else
        echo "$os/$arch"
      fi
    done

  # 2) Für fehlende/unknown Plattformen: Child-Manifest holen, dann Config-Blob lesen
  echo "$index_json" | jq -r '
    .manifests[]? 
    | select((.platform|not) or (.platform.os=="unknown") or (.platform.architecture=="unknown"))
    | .digest
  ' | while read -r child_digest; do
      [[ -z "$child_digest" ]] && continue
      # Child-Manifest (Single-Arch) laden
      mjson=$(fetch_json "https://$registry/v2/$repo/manifests/${child_digest}" "$token" "$registry" || true)
      [[ -z "$mjson" ]] && continue
      cfg=$(jq -r '.config.digest // empty' <<<"$mjson")
      [[ -z "$cfg" ]] && continue
      # Config-Blob lesen → os/architecture/variant
      cjson=$(fetch_json "https://$registry/v2/$repo/blobs/${cfg}" "$token" "$registry" || true)
      os=$(jq -r '.os // empty' <<<"$cjson")
      arch=$(jq -r '.architecture // empty' <<<"$cjson")
      variant=$(jq -r '.variant // empty' <<<"$cjson")
      if [[ -n "$os" && -n "$arch" ]]; then
        [[ -n "$variant" && "$variant" != "null" ]] && echo "$os/$arch/$variant" || echo "$os/$arch"
      fi
    done | sort -u
}

print_arch_from_single_manifest() {
  local registry="$1" repo="$2" token="$3" json="$4"
  local cfg_digest
  cfg_digest=$(jq -r '.config.digest // empty' <<<"$json")
  if [[ -z "$cfg_digest" ]]; then echo "unknown"; return; fi
  local cfg
  cfg=$(fetch_json "https://$registry/v2/$repo/blobs/${cfg_digest}" "$token" "$registry")
  jq -r '"\(.os)/\(.architecture)\(if .variant then "/"+.variant else "" end)"' <<<"$cfg"
}

normalize_arch_lines() {
  # Liest Arch-Zeilen von STDIN und gibt normalisierte Zeilen auf STDOUT aus.
  # - nur linux behalten
  # - arm64/v8 -> arm64
  # - Deduplizieren
  awk '
    /^[[:space:]]*$/ { next }
    !/^linux\// { next }                         # nur linux
    { gsub(/\r/,""); gsub(/[[:space:]]+$/,"") }  # säubern
    {
      # arm64/v8 => arm64
      if ($0 ~ /^linux\/arm64\/v8$/) $0="linux/arm64";
      print $0
    }
  ' | sort -u
}


# --- Start ---
load_pull_secrets

log "Sammle Images aus dem Cluster ..."
mapfile -t images < <(kubectl get pods --all-namespaces \
  -o jsonpath='{range .items[*]}{range .spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' \
  | tr -d '\r' | sed '/^$/d' | sort -u)

if [[ ${#images[@]} -eq 0 ]]; then log "Keine Images gefunden."; exit 0; fi

for img in "${images[@]}"; do
  # Normalisieren
  if ! out=$(normalize_image "$img"); then
    echo
    echo "Image: $img"
    echo "  (Übersprungen: konnte Ref nicht parsen)"
    continue
  fi

  # Drei Felder lesen
  registry="${out%% *}"; rest="${out#* }"
  repo="${rest% *}"; refname="${rest##* }"

  # Sicherstellen, dass alle Felder da sind
  if [[ -z "$registry" || -z "$repo" || -z "$refname" ]]; then
    echo
    echo "Image: $img"
    echo "  (Übersprungen: unvollständige Normalisierung: '$out')"
    continue
  fi

  # Ref extrahieren
  if [[ "$refname" == @* ]]; then
    refid="${refname#@}"
  else
    refid="${refname#:}"
  fi

  url="https://${registry}/v2/${repo}/manifests/${refid}"
  dbg "Image=$img → Reg=$registry Repo=$repo Ref=$refid"
  dbg "Manifest URL: $url"

token=$(bearer_token "$registry" "$repo" || true)
manifest_json=$(fetch_json "$url" "$token" "$registry" || true)

  echo
  echo "Image: $img"
  echo "Registry: $registry  Repo: $repo  Ref: $refid"

  if [[ -z "$manifest_json" ]]; then
    echo "  (Abruf fehlgeschlagen oder leere Antwort) -> $url"
    continue
  fi

if jq -e '.manifests' >/dev/null 2>&1 <<<"$manifest_json"; then
  echo "Typ: Multi-Arch Index"
  arches=$(list_arches_from_index "$registry" "$repo" "$token" <<<"$manifest_json")
else
  echo "Typ: Single-Arch"
  arches=$(print_arch_from_single_manifest "$registry" "$repo" "$token" "$manifest_json" || echo "")
fi

# ---> NEU: normalisieren (linux-only, arm64/v8 -> arm64, uniq)
arches=$(normalize_arch_lines <<<"$arches")

# Ausgabe + Intersection
if [[ -n "${arches:-}" ]]; then
  while IFS= read -r a; do
    [[ -z "$a" ]] && continue
    echo "  - $a"
  done <<<"$arches"
  update_common <<<"$arches"
else
  echo "  - (keine Daten)"
fi

done

echo
echo "Gemeinsamer Nenner (Architekturen, die ALLE Images unterstützen):"
if (( COMMON_INIT == 0 )); then
  echo "  - (keine Daten gesammelt)"
else
  if (( ${#COMMON_ARCHES[@]} == 0 )); then
    echo "  - (kein gemeinsamer Schnitt)"
  else
    for k in "${!COMMON_ARCHES[@]}"; do
      echo "  - $k"
    done | sort
  fi
fi


echo
log "Fertig."
