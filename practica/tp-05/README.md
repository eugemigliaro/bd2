# TP 5 — Planes de ejecución

- Fuente: [P05](../../material/catedra/practica/tp-05-planes-ejecucion.pdf)
- Datos: [materia](../../material/catedra/practica/recursos/tp-05-materia.csv) e [inscripto](../../material/catedra/practica/recursos/tp-05-inscripto.csv)
- Instancia inicial: [datos pequeños de materia](../../material/figuras/P05-p1-datos-materia.png)
- Apunte: [planes de ejecución](../../wiki/temas/10-planes-de-ejecucion.md)
- Motor: MySQL
- Estado: resolución registrada de los ejercicios 1–3
- Resolución SQL y planes observados: [planes.sql](planes.sql)
- Análisis completo: [solucion.md](solucion.md)

La guía compara `EXPLAIN` y `EXPLAIN ANALYZE`, y luego observa cómo PK, índices únicos, índices no únicos, claves compuestas y volumen de datos cambian los planes. [P05, pp. 1–3]

Registrá cada consulta, DDL previo y plan observado. Eliminá los índices del caso anterior cuando la consigna lo indique para que las comparaciones no acumulen estructuras.

## Ejecución

Los ejercicios usan la base `tp5`, separada de `mydb`, para crear y borrar
índices sin afectar los TP anteriores. Se crea una sola vez como `root`:

```sql
CREATE DATABASE IF NOT EXISTS tp5;
GRANT ALL PRIVILEGES ON `tp5`.* TO `bd2`@`%`;
```

```bash
make db-up
docker compose exec -T mysql sh -lc \
  'mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" tp5' < practica/tp-05/planes.sql
```

`planes.sql` está pensado para leerse y ejecutarse por bloques: cada caso trae
el DDL previo, la consulta y el plan observado como comentario. Dos detalles de
operación:

- `SET @@explain_format=TREE` es de sesión y necesario: en MySQL
  `EXPLAIN ANALYZE` solo existe en formato de árbol. El formato `TRADITIONAL`
  se usó en paralelo porque expone `type`, `possible_keys`, `key`, `key_len`,
  `filtered` y `Extra`.
- `SHOW CREATE TABLE ... \G` aborta la ejecución en modo batch por tubería.

La carga del ejercicio 3 se generó como sentencias `INSERT` a partir de los CSV,
porque `LOAD DATA LOCAL INFILE` no está habilitado en el contenedor:

```bash
tail -n +2 material/catedra/practica/recursos/tp-05-materia.csv \
  | awk -F, '{printf "INSERT INTO materia VALUES (%s, '\''%s'\'');\n", $1, $2}'
```

## Avance registrado

- Ejercicio 1: diferencias entre `EXPLAIN` y `EXPLAIN ANALYZE` sobre la instancia pequeña.
- Ejercicio 2.A: siete casos de `WHERE codigo = 10` (sin índices, PK simple y compuesta, `UNIQUE` simple y compuesto, no únicos simple y compuesto).
- Ejercicio 2.B: `AND` sobre las dos columnas, con PK compuesta y con dos `UNIQUE` separados.
- Ejercicio 2.C: `ORDER BY` con y sin PK; desaparición del `filesort`.
- Ejercicio 2.D: join con hash join, nested loop y `eq_ref`, y el caso en que un índice nuevo no se usa.
- Ejercicio 2.E: `OR` contra una PK compuesta, más un caso propio con `index_merge`.
- Ejercicio 3: carga de los CSV y comparación de costo y tiempo con y sin índices, incluido un `BETWEEN` que ilustra B-tree frente a hash.
- Pendiente anotado en `solucion.md`: repetir el ejercicio 3 con un volumen amplificado.
