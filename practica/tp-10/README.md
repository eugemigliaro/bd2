# TP 10 — Cassandra, parte I

- Fuente: [P12](../../material/catedra/practica/tp-10-cassandra-parte-1.pdf), tres páginas, ITBA 2026.
- Motor y cliente: Cassandra, CQL y `cqlsh`; DataGrip es una alternativa de la guía.
- Apuntes: [modelado/CQL](../../wiki/temas/20-cassandra-modelado-y-cql.md), [almacenamiento/Bloom](../../wiki/temas/21-cassandra-almacenamiento-y-bloom.md), [consistencia/DIGEST](../../wiki/temas/22-cassandra-consistencia-y-digest.md).
- Estado: enunciado leído completo e indexado; pendiente de resolución. No se generaron respuestas individuales ni se ejecutó un servidor.

## Preparación indicada por la guía

P12 propone descargar la imagen `cassandra`, crear la red `network-cassandra` e iniciar `Mycassandra`. Se accede con `docker exec -it Mycassandra bash` y luego `cqlsh`. Para DataGrip, la guía ofrece otro comando de creación que publica `9042:9042`; `SHOW HOST` permite consultar el nodo conectado. Las dos variantes de `docker run` son alternativas para el mismo contenedor. [P12, p. 1]

No está fijada la versión de la imagen ni consta la configuración de autenticación. La guía menciona usuario y contraseña `cassandra`; revisar el [registro de dudas](../../wiki/dudas-y-conflictos.md) antes de reproducir la instalación. El laboratorio MySQL del repo no configura Cassandra. [P12, p. 1]

## Ejercicio 1: servicio de música

| Pasos | Alcance | Página |
|---|---|---|
| 1–4 | Crear `demo_cql_music` con `SimpleStrategy`, RF=1; seleccionar el keyspace; crear `canciones` e insertar un registro. | 1–2 |
| 5–7 | Crear `lista_reproduccion`, insertar la primera canción y agregar otras con IDs generados por `now()`. | 2 |
| 8–11 | Ordenar canciones de una playlist; observar rechazo de filtro por artista; comparar `ALLOW FILTERING` e índice secundario. | 2–3 |
| 12–14 | Agregar `etiquetas set<text>`, actualizar etiquetas, crear índice y consultar con `CONTAINS`. | 3 |
| 15–18 | Eliminar una fila, una playlist completa, la tabla y finalmente el keyspace. | 3 |

[P12, pp. 1–3]

## Esquemas asociados

| Tabla | Columnas declaradas | Clave |
|---|---|---|
| `canciones` | `id uuid`, `titulo text`, `album text`, `artista text`, `data blob` | `id`: primary key y partition key. |
| `lista_reproduccion` | `id uuid`, `nro_cancion int`, `cancion_id uuid`, `titulo text`, `album text`, `artista text` | `PRIMARY KEY (id, nro_cancion)`: `id` particiona y `nro_cancion` ordena. |

La columna de audio se llama `data` en el DDL, aunque la introducción dice “datos”; los inserts provistos no cargan audio. `etiquetas` se agrega después con `ALTER TABLE`. La guía desnormaliza los atributos de canciones en las filas de la playlist porque Cassandra no soporta joins. [P12, pp. 1–3]

## Alcance de este espacio

Conservar acá los intentos y consultas CQL propios. La práctica guiada contiene resultados esperados en el PDF; la incorporación no la convierte en una solución individual. Solo se recibió la parte I: no reconstruir una parte II ni inventar consignas faltantes.
