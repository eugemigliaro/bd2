# Incorporación 2026-10-13 — TP 10, parte II

## Alcance y procedencia

`material/entrada/` tenía tres archivos. Por SHA-256, dos eran copias exactas de fuentes ya catalogadas y se descartaron sin volver a incorporarlos:

| Archivo recibido | Coincide con |
|---|---|
| `Slides_Bloom_Filters_Cassandra.pdf` | C04, `material/catedra/teoria/c04-cassandra-bloom-filters.pdf` |
| `mecanismo de obtencion de resultados DIGEST (cassandra).png` | C05, `material/catedra/teoria/recursos/c05-cassandra-digest.png` |

El tercero es nuevo: la parte II del TP 10, con el mismo encabezado y pie ITBA 2026 que la parte I (P12). Se clasificó como material oficial de práctica, igual que el resto del lote Cassandra, cuya procedencia ya estaba confirmada.

| ID | Fuente | Páginas | Fecha disponible |
|---|---|---|---|
| P13 | TP 10 — Cassandra, parte II | 2 | Pie de página ITBA 2026; sin fecha de creación en pdfinfo. |

El original se movió sin alterar sus bytes a `material/catedra/practica/tp-10-cassandra-parte-2.pdf`. Su nombre recibido figura en el [catálogo](../catalogo.tsv) y el hash se agregó a `material/checksums.sha256`. P13 es el siguiente ID libre de práctica; no equivale al número de TP.

## Lectura y productos

- Se extrajo el texto por página con `./scripts/extraer-fuentes.sh` y se revisaron las dos páginas renderizadas.
- La página 2 trae un DER que no aparece en el texto extraído. Se recortó como [figura](../figuras/P13-p2-der-ecommerce.png) y se transcribieron sus entidades, atributos y cardinalidades.
- Se amplió el [espacio del TP 10](../../practica/tp-10/README.md) con los tres ejercicios, las entidades y las consultas. No se generó solución individual.
- Se actualizaron los apuntes de [modelado y CQL](../../wiki/temas/20-cassandra-modelado-y-cql.md), [NoSQL y CAP](../../wiki/temas/15-nosql-y-cap.md) y [persistencia políglota/Docker](../../wiki/temas/07-persistencia-poliglota-y-docker.md), además de wiki/README, preguntas de repaso (109–112), dudas y conflictos, y los índices de material, figuras y práctica.

## Conflictos y vacíos

Se registraron en [dudas y conflictos](../../wiki/dudas-y-conflictos.md#tp-10-parte-ii-supuestos-de-modelado):

- La consulta de comentarios por rango de fechas del ejercicio 1 no indica a qué partición acotarse.
- En el DER del ejercicio 2, `califica` tiene dos atributos “Fecha” y ningún puntaje.
- Las consultas buscan por “nombre producto” aunque `Producto` declara `título`. Tampoco se aclara si los nombres de usuario son únicos.
- La clasificación CAP del ejercicio 3 coincide con T13 y T16, pero T16 aclara que el nivel de consistencia se configura por consulta.

P13 no trae resultados esperados ni solución de cátedra, y sigue sin fijar la versión de Cassandra. No se ejecutaron Cassandra, Docker ni los comandos de la guía.

## Cierre

`material/entrada/` quedó sin archivos pendientes (solo `.gitkeep`). `./scripts/verificar-repo.sh` dio resultado válido y `git diff --check` no marcó errores. También se revisaron los enlaces y anclas locales de las páginas modificadas, sin enlaces rotos.

El lote se commiteó por separado del TP 9, que estaba en curso en paralelo. Sus cambios (entorno MongoDB y bibliografía remitida por el TP 9) quedaron fuera de este lote.
