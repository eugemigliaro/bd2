#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 \"tema de la clase\" [AAAA-MM-DD]" >&2
    exit 2
fi

tema="$1"
fecha="${2:-$(date +%F)}"
slug="$(printf '%s' "$tema" | iconv -f UTF-8 -t ASCII//TRANSLIT | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
destino="$repo_dir/notas/bandeja/$fecha-$slug.md"

if [[ -e "$destino" ]]; then
    echo "Error: ya existe $destino" >&2
    exit 1
fi

sed -e "s/{{FECHA}}/$fecha/g" -e "s/{{TEMA}}/$tema/g" \
    "$repo_dir/notas/PLANTILLA.md" > "$destino"

echo "$destino"
