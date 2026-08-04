#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalogo="$repo_dir/material/catalogo.tsv"
salida="$repo_dir/material/extraido"

command -v pdftotext >/dev/null || {
    echo "Error: falta pdftotext (paquete poppler-utils)." >&2
    exit 1
}

mkdir -p "$salida"

tail -n +2 "$catalogo" | while IFS=$'\t' read -r id tipo titulo ruta paginas ciclo estado original; do
    [[ "$ruta" == *.pdf ]] || continue
    pdf="$repo_dir/$ruta"
    destino="$salida/$id.txt"
    temporal="$(mktemp)"

    if [[ ! -f "$pdf" ]]; then
        echo "Error: no existe $ruta (fuente $id)." >&2
        rm -f "$temporal"
        exit 1
    fi

    pdftotext -layout "$pdf" "$temporal"
    awk -v id="$id" -v titulo="$titulo" -v ruta="$ruta" '
        BEGIN {
            RS="\f"
            print "FUENTE: " id
            print "TITULO: " titulo
            print "ORIGINAL: " ruta
        }
        {
            sub(/[[:space:]]+$/, "", $0)
            print "\n===== PAGINA " NR " =====\n"
            print $0
        }
    ' "$temporal" > "$destino"
    rm -f "$temporal"
    echo "Extraída $id -> material/extraido/$id.txt"
done
