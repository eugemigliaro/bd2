# TP 10 — Cassandra, partes I y II

- Fuentes: [P12](../../material/catedra/practica/tp-10-cassandra-parte-1.pdf), parte I, tres páginas; [P13](../../material/catedra/practica/tp-10-cassandra-parte-2.pdf), parte II, dos páginas. Ambas ITBA 2026.
- Motor y cliente: Cassandra, CQL y `cqlsh`; DataGrip es una alternativa de la guía.
- Apuntes: [modelado/CQL](../../wiki/temas/20-cassandra-modelado-y-cql.md), [almacenamiento/Bloom](../../wiki/temas/21-cassandra-almacenamiento-y-bloom.md), [consistencia/DIGEST](../../wiki/temas/22-cassandra-consistencia-y-digest.md), [NoSQL y CAP](../../wiki/temas/15-nosql-y-cap.md).
- Estado: enunciados leídos completos e indexados; pendientes de resolución. No se generaron respuestas individuales ni se ejecutó un servidor.

## Preparación indicada por la guía

P12 propone descargar la imagen `cassandra`, crear la red `network-cassandra` e iniciar `Mycassandra`. Se accede con `docker exec -it Mycassandra bash` y luego `cqlsh`. Para DataGrip, la guía ofrece otro comando de creación que publica `9042:9042`; `SHOW HOST` permite consultar el nodo conectado. Las dos variantes de `docker run` son alternativas para el mismo contenedor. [P12, p. 1]

No está fijada la versión de la imagen ni consta la configuración de autenticación. La guía menciona usuario y contraseña `cassandra`; revisar el [registro de dudas](../../wiki/dudas-y-conflictos.md) antes de reproducir la instalación. El laboratorio MySQL del repo no configura Cassandra. [P12, p. 1]

## Parte I, ejercicio 1: servicio de música

| Pasos | Alcance | Página |
|---|---|---|
| 1–4 | Crear `demo_cql_music` con `SimpleStrategy`, RF=1; seleccionar el keyspace; crear `canciones` e insertar un registro. | 1–2 |
| 5–7 | Crear `lista_reproduccion`, insertar la primera canción y agregar otras con IDs generados por `now()`. | 2 |
| 8–11 | Ordenar canciones de una playlist; observar rechazo de filtro por artista; comparar `ALLOW FILTERING` e índice secundario. | 2–3 |
| 12–14 | Agregar `etiquetas set<text>`, actualizar etiquetas, crear índice y consultar con `CONTAINS`. | 3 |
| 15–18 | Eliminar una fila, una playlist completa, la tabla y finalmente el keyspace. | 3 |

[P12, pp. 1–3]

## Esquemas de la parte I

| Tabla | Columnas declaradas | Clave |
|---|---|---|
| `canciones` | `id uuid`, `titulo text`, `album text`, `artista text`, `data blob` | `id`: primary key y partition key. |
| `lista_reproduccion` | `id uuid`, `nro_cancion int`, `cancion_id uuid`, `titulo text`, `album text`, `artista text` | `PRIMARY KEY (id, nro_cancion)`: `id` particiona y `nro_cancion` ordena. |

La columna de audio se llama `data` en el DDL, aunque la introducción dice “datos”; los inserts provistos no cargan audio. `etiquetas` se agrega después con `ALTER TABLE`. La guía desnormaliza los atributos de canciones en las filas de la playlist porque Cassandra no soporta joins. [P12, pp. 1–3]

## Parte II: diseño de modelos desde las consultas

P13 no trae una práctica guiada: pide diseñar tablas para dos dominios a partir de sus consultas frecuentes, y clasificar Cassandra según CAP. Se reutiliza la instalación de la parte I. Antes de diseñar, la guía fija dos objetivos: distribuir los datos en el clúster y acceder a la menor cantidad posible de particiones por consulta. [P13, p. 1]

| Ejercicio | Alcance | Página |
|---|---|---|
| 1 | Blog de noticias: column families, registros de prueba y ejecución de las consultas frecuentes. | 1 |
| 2 | E-commerce: estructuras CQL a partir de un DER y cinco consultas. | 2 |
| 3 | Clasificar Cassandra según el teorema CAP. | 2 |

[P13, pp. 1–2]

### Ejercicio 1: blog de noticias

| Entidad | Atributos del enunciado |
|---|---|
| Autor | Nombre, nombre de usuario, cuenta de X y descripción. |
| Noticia | Título, cuerpo, fecha de publicación, autor y lista de tags opcional. |
| Comentario | Persona que lo escribió, texto y momento en que lo hizo. |

Consultas frecuentes que deben resolverse:

1. Usuarios por nombre de usuario.
2. Usuarios por cuenta de X.
3. Noticias de un usuario, por nombre de usuario, con su descripción y ordenadas por fecha.
4. Comentarios en un rango de fechas, ordenados por fecha, con el título de la noticia y el usuario que comentó.

Los incisos piden (a) crear las column families, (b) insertar registros de prueba y (c) ejecutar esas consultas para comprobar el diseño. [P13, p. 1]

### Ejercicio 2: e-commerce

El [DER del enunciado](../../material/figuras/P13-p2-der-ecommerce.png), revisado visualmente porque `pdftotext` no lo recupera, define:

| Elemento | Atributos o cardinalidad |
|---|---|
| `Usuario` | `id` (identificador), nombre, email, password. |
| `Producto` | `id` (identificador), título, tags, descripción. |
| `Categoría` | `nombre` (identificador), fecha de creación, descripción. |
| publica / publicado | Usuario n : m Producto, con fecha. |
| comenta / comentado | Usuario n : m Producto, con fecha y comentario. |
| califica / calificado | Usuario n : m Producto, con dos atributos rotulados “Fecha”. |
| pertenece | Producto m : 1 Categoría. |

Consultas requeridas: usuario por ID; producto por ID; productos publicados por un usuario, por nombre de usuario; usuarios que comentaron un producto, por nombre de producto; qué producto calificó un usuario “X” por fecha. [P13, p. 2]

El diagrama y las consultas no coinciden del todo: `califica` repite “Fecha” y no tiene puntaje, y las consultas buscan por “nombre producto” aunque `Producto` declara `título`. Fijar e informar esos supuestos al resolver; ver el [registro de dudas](../../wiki/dudas-y-conflictos.md#tp-10-parte-ii-supuestos-de-modelado). [P13, p. 2]

### Ejercicio 3: CAP

Pide clasificar Cassandra según el teorema CAP. El criterio de cátedra está en [NoSQL y CAP](../../wiki/temas/15-nosql-y-cap.md#cap-lectura-de-cátedra). [P13, p. 2]

## Alcance de este espacio

Conservar acá los intentos y consultas CQL propios. La práctica guiada de la parte I contiene resultados esperados en el PDF; la incorporación no la convierte en una solución individual. La parte II es de diseño abierto y no trae resultados esperados ni solución de cátedra.
