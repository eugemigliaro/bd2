# Incorporación 2026-10-13 — Ejercicios tipo parcial

## Alcance y procedencia

Se incorporó un PDF de **7 páginas** con ejercicios tipo parcial, provisto por la
cátedra según indicó el usuario. Sin duplicados por SHA-256 frente a las fuentes
existentes. Se movió sin alterar sus bytes a
`material/catedra/practica/p14-ejercicios-tipo-parcial.pdf`, con ID **P14**,
hash en `checksums.sha256` y el nombre recibido en el catálogo.

## Contenido

| Páginas | Ejercicio | Temas |
|---|---|---|
| 1 | Investigadores | vistas SQL con agregación, fechas y edad; una vista sobre otra; ensamble externo |
| 1 | Mensajería | consulta con conteo acotado de adjuntos; jerarquía de subtipos |
| 2 | Voluntarios | `SUM`, `COUNT(*)` y `COUNT(col)` sobre nulos |
| 2–3 | Películas | corrección de una consulta con joins |
| 3 | Teoría | SGBD, modelo conceptual, jerarquías, entidad débil |
| 3 | Roles y privilegios | `GRANT`, `WITH GRANT OPTION`, `REVOKE`, vistas |
| 4 | MongoDB, Neo4j, Cassandra | traducción SQL → agregación, lectura de Cypher, `CREATE KEYSPACE` |
| 5–6 | Adicionales MongoDB | CRUD, `$nin`, `$all`, `$elemMatch`, índices, agregación |
| 6–7 | Adicionales Cassandra | modelado por consulta, replicación y consistencia, arquitectura, escritura, borrado, Bloom filters |

[P14, pp. 1–7]

## Lectura y productos

- Se leyó el texto completo y se revisaron las siete páginas renderizadas.
- Se extrajeron las cuatro imágenes embebidas como figuras; ver el
  [índice de figuras](../figuras/README.md#ejercicios-tipo-parcial-incorporación-2026-10-13).
- Se creó el [espacio de práctica](../../practica/parcial/README.md). No se
  generaron soluciones durante la incorporación.
- Se agregaron enlaces en el índice de la wiki y en el de prácticas. Los
  ejercicios no introducen teoría nueva salvo Neo4j.

## Conflictos y vacíos

Registrados en [dudas y conflictos](../../wiki/dudas-y-conflictos.md#ejercicios-tipo-parcial-p14):
la ausencia de material de Neo4j/Cypher, la ambigüedad de "a lo sumo 3
adjuntos", las unidades de `tamanio` y el tipo `date` de `anio_creacion`, y la
notación de esquema PostgreSQL de la consulta de Películas.
