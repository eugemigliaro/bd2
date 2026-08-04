#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <texto o expresión regular>" >&2
    exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rg -n -i --glob '*.md' --glob '*.txt' --glob '*.sql' -- "$1" \
    "$repo_dir/wiki" \
    "$repo_dir/material/extraido" \
    "$repo_dir/material/catedra/practica/recursos" \
    "$repo_dir/notas" \
    "$repo_dir/practica"
