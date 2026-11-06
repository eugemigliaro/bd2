# Incorporación 2026-11-06 — Neo4j, Redis y DynamoDB

## Alcance y procedencia

Se incorporaron los diez archivos pendientes en `material/entrada/`: ocho PDFs, **161 páginas**, y dos archivos de texto. El usuario confirmó que todo fue provisto por la cátedra. No hubo duplicados por SHA-256 frente a fuentes existentes ni entre los archivos.

Los originales se movieron sin alterar sus bytes; los nombres recibidos figuran en el [catálogo](../catalogo.tsv) y los hashes en `material/checksums.sha256`. Se asignaron los siguientes ID libres. Como en lotes anteriores, no equivalen al número de clase o de TP.

## Fuentes incorporadas

| ID | Fuente | Páginas / formato | Fecha disponible |
|---|---|---|---|
| T17 | Clase 16 — Neo4j | 41 | Modificación PDF: 2024-10-09; cita la versión 5.6 (marzo de 2023). |
| C06 | Anexo de Neo4j: MERGE, Causal Clustering y Raft | 13 | Sin fecha en pdfinfo. |
| T18 | Clase 17 — Bases de clave-valor (generalidades) | 31 | Creación PDF: 2023-10-27. |
| T19 | Clase 18 — Bases de clave-valor (hands-on): Redis | 36 | Creación PDF: 2023-10-27; modificación: 2023-11-08. |
| T20 | Clase 20 — Amazon DynamoDB | 34 | Sin fecha en pdfinfo. |
| P15 | TP 11 — Neo4j | 2 | Pie ITBA 2026. Recibido como `ITBA TP 11 - Neo4j(1).pdf`. |
| P16 | TP 12 — Redis | 2 | Pie ITBA 2026. |
| P17 | TP 13 — DynamoDB | 2 | Pie ITBA 2026. |
| P18 | Ejercicio Redis (enunciado) | Texto UTF-8 | Sin fecha. |
| P18A | Solución de cátedra del ejercicio Redis | Texto UTF-8 | Sin fecha. |

El ciclo 2026 indica la cursada en que se recibió el material; los metadatos no se interpretan como fecha de clase. P18A sigue el criterio de P11A: solución oficial archivada como recurso, separada de toda resolución propia.

## Lectura y productos

- Se ejecutó `./scripts/extraer-fuentes.sh`: se generaron T17, C06, T18, T19, T20, P15, P16 y P17, y las extracciones previas no cambiaron.
- Se leyó el texto completo de todas las fuentes. También se revisaron visualmente las 161 páginas renderizadas y se ampliaron las que tienen poco texto o capturas. Se transcribieron las plantillas y consultas Cypher que estaban como imagen (T17, pp. 9–13).
- La revisión visual detectó una corrección manuscrita que el texto extraído no muestra: la restricción de unicidad de T17, p. 28, es sobre `Person`, no sobre `Publication`.
- Se recuperaron **16 figuras**, entre recortes y páginas completas; ver el [índice de figuras](../figuras/README.md#neo4j-redis-y-dynamodb-incorporación-2026-11-06).
- Se crearon cinco apuntes: [Neo4j: grafos y Cypher](../../wiki/temas/23-neo4j-grafos-y-cypher.md), [Neo4j: clústeres, Raft y CAP](../../wiki/temas/24-neo4j-clusteres-y-cap.md), [clave-valor y Redis](../../wiki/temas/25-clave-valor-y-redis.md), [comandos de Redis](../../wiki/temas/26-redis-comandos-y-estructuras.md) y [DynamoDB](../../wiki/temas/27-dynamodb.md).
- Se actualizaron el índice de la wiki, el glosario, las preguntas de repaso (113–161), NoSQL y CAP, persistencia políglota y Docker, y dudas y conflictos.
- Se crearon los espacios del [TP 11](../../practica/tp-11/README.md), [TP 12](../../practica/tp-12/README.md), [TP 13](../../practica/tp-13/README.md) y del [ejercicio Redis](../../practica/ejercicio-redis/README.md), sin soluciones individuales.
- Se actualizó el índice de práctica. En el parcial (P14), la lectura de Cypher dejó de ser complemento puro: ahora se apoya en T17 salvo `*2..3` y `WHERE NOT`.
- Los TP remiten a los capítulos 6–8 de B01. Se verificaron en el PDF local las páginas citadas y los ejercicios Find/Do. El desfase entre página impresa y página del PDF varía por capítulo (+11, +10 y +9), así que se corrigió la nota general del [registro de B01](2026-10-13-seven-databases.md).

## Conflictos y vacíos

Los detalles con citas están en [dudas y conflictos](../../wiki/dudas-y-conflictos.md). Se registraron siete bloques nuevos y se actualizó el del parcial:

- **CAP:** las clasificaciones divergen. Neo4j es AP en T17, CA en T19 y está ausente de T13; Redis es CP en T13 y T20 y CA en T19; DynamoDB es AP en T13, con matices en T20. Los tres TP piden esta clasificación.
- **Neo4j:** mezcla de versiones (3.4.9 a 5.6), sintaxis histórica (`{value}`, `distance()`, API REST, HA), labels en relaciones y generalizaciones sobre rendimiento.
- **Redis:** “atómica” frente a “sin rollback”; siglas y políticas de fsync; el “Redis Cluster” del libro frente al de la diapositiva; licencia, `AUTH` y `rename-command`; comandos deprecados; Bloom filters; erratas menores.
- **Ejercicio Redis:** nombre de la lista, ISBN repetido y dos comentarios imprecisos de la solución.
- **DynamoDB:** rótulo de partition key en la figura LSI; operadores de la sort key; consultas a índices sin `--index-name` y con la palabra reservada `Date`; cadenas vacías; transacciones y modos de capacidad actuales.
- **TP 11–13:** imágenes sin versión, `-sharedDb` en DynamoDB Local, desfase de páginas de B01 y servicios externos (Sandbox de Neo4j, AWS).

Las precisiones externas provienen de documentación oficial de Neo4j, Redis y AWS, consultada el 2026-11-06. Están enlazadas y etiquetadas como **Complemento del agente (no consta en el material cargado)**; se usan como contraste técnico, no como material de cátedra.

Vacíos: no se recibió una Clase 19 (la numeración salta de 18 a 20). El material no presenta un comando para la posición de un miembro de un conjunto ordenado (TP 12, ejercicio 6) ni la fórmula de particiones de DynamoDB (TP 13, ejercicio 4). No se inventaron esos contenidos.

## Cierre y validación

`material/entrada/` quedó sin archivos pendientes (solo `.gitkeep`). Se ejecutó `./scripts/verificar-repo.sh` y se revisó el diff. No se ejecutaron Neo4j, Redis, DynamoDB Local ni los comandos de las guías: la validación cubre la integridad de las fuentes, la extracción, la organización y la trazabilidad de la síntesis.
