#!/usr/bin/env bash
# TP 8, ejercicio 3.a: prueba los tres comandos con cada usuario y resume.
# Cada intento corre en una transaccion que no se confirma, asi el INSERT no
# queda. El GRANT no es transaccional: el que hagan B o A se revierte al final.
# D va primero para que su SELECT se pruebe antes de que alguien le conceda algo.
set -u
cd "$(dirname "$0")/../.."

comandos=(
  "SELECT * FROM A.usuario WHERE nro_u='C'"
  "INSERT INTO A.usuario VALUES ('C','Gerente','Control')"
  "GRANT SELECT ON A.usuario TO D"
)

for u in D C B A; do
  for i in "${!comandos[@]}"; do
    salida=$(docker compose exec -T mysql mysql -u"$u" -p"${u,,}" \
      -e "START TRANSACTION; ${comandos[$i]}; ROLLBACK;" 2>&1 \
      | grep -v 'Using a password')
    printf '%s  comando %d  %s\n' "$u" "$((i + 1))" "${salida:-OK}"
  done
done

docker compose exec -T mysql sh -lc \
  'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "REVOKE IF EXISTS SELECT ON A.usuario FROM D;"' \
  2>&1 | grep -v 'Using a password'
