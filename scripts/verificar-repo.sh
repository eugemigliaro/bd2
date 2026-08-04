#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
catalogo="$repo_dir/material/catalogo.tsv"
errores=0

if ! (cd "$repo_dir" && sha256sum --check --quiet material/checksums.sha256); then
    echo "Alguna fuente oficial no coincide con su checksum." >&2
    errores=$((errores + 1))
fi

while IFS=$'\t' read -r id tipo titulo ruta paginas ciclo estado original; do
    [[ "$id" == "id" ]] && continue
    [[ -z "$id" ]] && continue
    if [[ ! -f "$repo_dir/$ruta" ]]; then
        echo "Falta la fuente $id: $ruta" >&2
        errores=$((errores + 1))
    fi
    if [[ "$ruta" == *.pdf && ! -f "$repo_dir/material/extraido/$id.txt" ]]; then
        echo "Falta el texto extraído de $id" >&2
        errores=$((errores + 1))
    fi
    if [[ "$ruta" == *.pdf && "$paginas" =~ ^[0-9]+$ && -f "$repo_dir/material/extraido/$id.txt" ]]; then
        paginas_extraidas="$(rg -c '^===== PAGINA [0-9]+ =====$' "$repo_dir/material/extraido/$id.txt")"
        if [[ "$paginas_extraidas" -ne "$paginas" ]]; then
            echo "$id declara $paginas página(s), pero se extrajeron $paginas_extraidas." >&2
            errores=$((errores + 1))
        fi
    fi
done < "$catalogo"

while IFS= read -r citado; do
    if ! awk -F $'\t' -v id="$citado" '$1 == id { encontrado=1 } END { exit !encontrado }' "$catalogo"; then
        echo "La wiki usa un ID sin catálogo: $citado" >&2
        errores=$((errores + 1))
    fi
done < <(rg -o --no-filename '\b(T|C|P|SQL|X)[0-9]+[A-Z]?\b' "$repo_dir/wiki" | sort -u)

for script in "$repo_dir"/scripts/*.sh; do
    if [[ ! -x "$script" ]]; then
        echo "El script no es ejecutable: ${script#"$repo_dir/"}" >&2
        errores=$((errores + 1))
    fi
done

if rg -n '\[TODO|TODO:|\[TODO:' "$repo_dir" \
    --glob '*.md' \
    --glob '!practica/**' \
    --glob '!notas/PLANTILLA.md'; then
    echo "Hay marcadores TODO fuera de los espacios de trabajo." >&2
    errores=$((errores + 1))
fi

if [[ $errores -ne 0 ]]; then
    echo "Validación fallida: $errores problema(s)." >&2
    exit 1
fi

echo "Repositorio válido: fuentes presentes, extracciones disponibles y sin TODO estructurales."
