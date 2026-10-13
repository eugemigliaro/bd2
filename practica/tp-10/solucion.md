# TP 10 — Resolución y observaciones

Registro ejecutable: [parte1.cql](parte1.cql). Fuentes: [P12, pp. 1–3] y
[P13, pp. 1–2].

## Entorno

Cassandra 5.0.9 en el contenedor `bd2-cassandra`, un solo nodo, heap de 1 GB.
La guía usa `cassandra` sin versión [P12, p. 1]; hoy `latest` apunta a una 6.0
alfa, así que se fija la última 5.0 estable. La imagen corre sin autenticación
(`AllowAllAuthenticator`): el usuario `cassandra`/`cassandra` que menciona la
guía no hace falta. El puerto 9042 se publica solo en `127.0.0.1`.

```bash
make db-up        # levanta MySQL, MongoDB y Cassandra
make cql-shell    # o: docker compose exec cassandra cqlsh
```

## Marco conceptual

Cassandra es distribuida, escala horizontalmente y no tiene maestro: los nodos
son pares. [T16, pp. 1–5, 11–14] Cada fila tiene una **clave de partición**; su
hash decide el nodo, y las filas con la misma clave forman una **partición**.
La `PRIMARY KEY` tiene dos partes: la clave de partición (dónde vive la fila) y
las columnas de **clustering** (en qué orden se guardan dentro de la partición).
[T16, pp. 63–69]

```
PRIMARY KEY ((clave de partición), clustering1, clustering2)
```

No hay joins ni subconsultas, y una consulta es eficiente cuando indica qué
partición leer. Por eso se diseña **desde las consultas** y se desnormaliza.
[T16, pp. 13, 16–19]

## Parte I — servicio de música

### Particiones de las dos tablas

| Tabla | `PRIMARY KEY` | Una partición es | Filas por partición |
|---|---|---|---|
| `canciones` | `(id)` | una canción | una |
| `lista_reproduccion` | `(id, nro_cancion)` | **una playlist entera** | una por canción, ordenadas por `nro_cancion` |

La consulta frecuente es "dame la playlist X": vive completa en una partición y
se lee de una vez, ya ordenada. [P12, p. 2]

### Desnormalización

`lista_reproduccion` copia título, álbum y artista de `canciones`. Sin joins,
guardar solo `cancion_id` obligaría a una consulta extra por canción; con la
copia, la playlist sale en una lectura. El costo es mantener las copias: si se
corrige un título en `canciones`, la playlist lo sigue mostrando viejo, y
sincronizarlo es responsabilidad de la aplicación. [P12, p. 2]

### `INSERT` es un upsert

Un `INSERT` con una clave primaria existente no da error: pisa la fila.
Cassandra no lee antes de escribir; ante dos escrituras gana la más reciente.
Verificado: reinsertar "Asilo" con otro álbum lo reemplazó en `canciones`, y la
copia de la playlist quedó desactualizada —la desnormalización en vivo—.
*Complemento del agente (no consta en el material cargado).*

### Paso 7 — detalles de CQL

- `now()` genera un `timeuuid` basado en la hora, por eso los ids generados
  seguidos empiezan casi igual. Se acepta en una columna `uuid`.
- **Una fila por `INSERT`**: CQL no admite `VALUES (…), (…)`.
- `SELECT * FROM canciones` no devuelve las filas en orden de inserción sino en
  el del hash de la clave de partición. Solo se ordena **dentro** de una
  partición.

### Pasos 8–11 — por qué se rechaza filtrar por artista

| Consulta | Particiones que lee | Resultado |
|---|---|---|
| `WHERE id = …` (paso 8) | **una**: la que indica el hash del id | se acepta; `ORDER BY nro_cancion` funciona porque es clustering |
| `WHERE artista = …` (paso 9) | **todas**, en todos los nodos | se rechaza |
| `… ALLOW FILTERING` (paso 10) | todas, aceptado explícitamente | funciona, sin optimizar |
| con índice secundario (paso 11) | todos los nodos, cada uno vía su tabla oculta | funciona; más lento que por clave |

[P12, pp. 2–3; T16, pp. 61–62, 67–71] Si una consulta es frecuente, la solución
no es el índice sino **otra tabla** particionada por ese campo: la base de la
parte II.

`ORDER BY` sin restringir la clave de partición también se rechaza: "ORDER BY is
only supported when the partition key is restricted by an EQ or an IN".

**Hallazgo:** el índice se construye en segundo plano. Consultar inmediatamente
después del `CREATE INDEX` puede fallar con "The secondary index … is not yet
available"; a los pocos segundos funciona. *Verificado en 5.0.9.*

### Pasos 12–14 — colecciones

`etiquetas set<text>` es un conjunto: agregar `'2017'` dos veces lo deja una
vez, a diferencia del doble `$push` sobre un arreglo de MongoDB. `CONTAINS`
busca un elemento de la colección y necesita el índice del paso 14. [T16, p. 57;
P12, p. 3]

### Pasos 15–18 — borrados y tombstones

Con la clave primaria completa, `DELETE` borra una fila; con solo la clave de
partición, la partición entera —la playlist completa—. [P12, p. 3]

Las SSTables son inmutables: un borrado es una escritura más, una **tombstone**,
que tapa los valores anteriores. El `SELECT` devuelve 0 filas y no la muestra.
La compactación elimina datos y marca recién pasado un período de gracia (10
días por defecto), para que una réplica caída reciba el borrado al volver y no
"resucite" el dato. [T16, pp. 33–34, 38–39, 47] Con `TRACING ON` se ven las
tombstones leídas.

## Parte II, ejercicio 1 — blog de noticias

Registro ejecutable: [ejercicio1.cql](ejercicio1.cql), keyspace `blog`.

### Método

Los dos objetivos de la guía —repartir los datos y leer la menor cantidad de
particiones— [P13, p. 1] se traducen en **una tabla por consulta frecuente**,
con la clave de partición igual a lo que la consulta usa para buscar. Es el
camino inverso al del TP 1: se parte de las consultas, no de las entidades, y
repetir datos es lo esperable. [T16, pp. 13, 16–19]

### Las cuatro tablas

| Consulta | Tabla | `PRIMARY KEY` | Lee |
|---|---|---|---|
| 1. usuario por nombre de usuario | `usuarios_por_username` | `(username)` | 1 partición |
| 2. usuario por cuenta de X | `usuarios_por_cuenta_x` | `(cuenta_x)` | 1 partición |
| 3. noticias de un usuario, con su descripción, por fecha | `noticias_por_usuario` | `((username), fecha_publicacion, id_noticia)`, `fecha DESC` | 1 partición |
| 4. comentarios en un rango de fechas, con título y usuario | `comentarios_por_dia` | `((dia), momento, id_comentario)` | 1 partición por día del rango |

**1 y 2 — los mismos datos con otra clave.** Un autor se guarda dos veces. Cada
alta escribe en las dos tablas dentro de un `BEGIN BATCH … APPLY BATCH`, que
aplica todas las escrituras o ninguna. *Complemento del agente.*

**3 — tres decisiones:**

- **Una partición por autor** y `fecha_publicacion` como clustering con
  `CLUSTERING ORDER BY (fecha_publicacion DESC)`: las noticias ya están
  guardadas de la más nueva a la más vieja y la consulta no necesita
  `ORDER BY`.
- **`id_noticia` en la clave.** Sin él, dos noticias del mismo autor con el
  mismo instante tendrían la misma clave primaria y la segunda **pisaría** a la
  primera: el upsert de la parte I.
- **`descripcion_autor` es `STATIC`**: una columna estática se guarda una sola
  vez por partición y aparece en todas sus filas. La descripción es del autor,
  no de cada noticia, y así no se repite. *Complemento del agente (no consta en
  el material cargado).*

**4 — la decisión difícil: qué es la partición.** El enunciado pide comentarios
"en un rango de fechas" sin acotarlos a una noticia ni a un usuario. Las
alternativas:

| Partición | Problema |
|---|---|
| una sola para todos los comentarios | rompe el objetivo 1: todo en un nodo y una partición que crece sin límite |
| la noticia | la consulta no es por noticia: habría que leer todas |
| **el día** (*bucket*) | reparte los comentarios y acota cada partición; un rango de *n* días lee *n* particiones |

Se eligió el día. Dentro de él, `momento` como clustering ordena y permite el
rango (`momento >= … AND momento < …`). Un rango de varios días enumera las
particiones con `dia IN (…)`. El orden por `momento` vale dentro de cada
partición; entre días, la respuesta sigue el orden de la lista del `IN`, y la
aplicación recorre los días en orden. Con mucho volumen el bucket podría ser la
hora; con poco, el mes. Es el supuesto que pedía explicitar el
[registro de dudas](../../wiki/dudas-y-conflictos.md#tp-10-parte-ii-supuestos-de-modelado).
*Análisis del agente.*

Cada comentario lleva copiados el título de la noticia y el usuario: la consulta
los pide y no hay joins.

### El costo de la desnormalización

Cambiar la descripción de un autor exige tres escrituras: las dos tablas de
usuarios y la columna estática de su partición en `noticias_por_usuario`.
Corregir el título de una noticia exige reescribir cada comentario que lo copió.
Las lecturas son de una partición; las actualizaciones, responsabilidad de la
aplicación.

### Verificación

Las cuatro consultas devuelven lo esperado sobre los datos de prueba: Laura
García por `lgarcia`; Martín Pérez por `@martinperez`; las tres noticias de
`lgarcia` de la más nueva a la más vieja, cada una con su descripción; los dos
comentarios del 5 de octubre entre las 12 y las 21, y los del rango del 5 a las
18 al 6 a las 23 leyendo dos particiones.

## Parte II, ejercicio 2 — e-commerce

Registro ejecutable: [ejercicio2.cql](ejercicio2.cql), keyspace `ecommerce`.
El DER se revisó visualmente. [P13, p. 2]

### Supuestos

El enunciado y el DER no coinciden del todo; se fijan estos supuestos, como
pide el [registro de dudas](../../wiki/dudas-y-conflictos.md#tp-10-parte-ii-supuestos-de-modelado):

- **"Nombre producto" es el `título`**: `Producto` no tiene otro nombre.
- **Nombres de usuario y títulos no son únicos**: el DER no lo declara. Cada
  tabla consultada por nombre lleva también el id en la clave, para no mezclar
  homónimos ni pisar sus filas.
- **"Califica" tiene un solo atributo, la fecha.** El DER repite "Fecha" y no
  trae puntaje; no se inventa uno, aunque en un sistema real lo tendría.
- **"Califica un usuario 'X' por fecha"** se resuelve con la fecha como
  clustering: sirve tanto para ordenar como para filtrar un período.
- **Categoría no participa de ninguna consulta.** Como `pertenece` es m:1, cada
  producto guarda el nombre de su categoría; no hace falta otra tabla.

### Las cinco tablas

| Consulta | Tabla | `PRIMARY KEY` |
|---|---|---|
| 1. usuario por id | `usuarios` | `(id_usuario)` |
| 2. producto por id | `productos` | `(id_producto)` |
| 3. productos publicados por un usuario (nombre) | `productos_por_usuario` | `((nombre_usuario), id_usuario, fecha_publicacion, id_producto)` |
| 4. usuarios que comentaron un producto (título) | `comentarios_por_producto` | `((titulo_producto), id_producto, id_usuario, fecha_comentario)` |
| 5. productos que calificó un usuario, por fecha | `calificaciones_por_usuario` | `((nombre_usuario), fecha_calificacion, id_usuario, id_producto)`, fecha `DESC` |

**Las tres relaciones n:m se transforman en tablas orientadas a una consulta.**
En un relacional, *publica*, *comenta* y *califica* serían tablas intermedias
con dos claves foráneas que se recorren con joins en cualquier dirección. Acá
cada relación se guarda **solo en la dirección que se consulta**: publicaciones
por usuario, comentarios por producto, calificaciones por usuario. Si mañana se
necesitara "qué usuarios calificaron el producto P", haría falta otra tabla.

**Clave por nombre, id en el clustering.** Con dos "Juan Gómez" homónimos, la
consulta 3 devuelve los productos de ambos, separados por `id_usuario`; sin el
id en la clave, sus filas se mezclarían o se pisarían.

**Consulta 4 — usuarios, no comentarios.** Hay una fila por comentario: un
usuario que comentó dos veces aparece dos veces. `SELECT DISTINCT` no sirve,
porque solo admite columnas de la partition key o estáticas. Como `id_usuario`
es el segundo componente del clustering, `GROUP BY id_producto, id_usuario`
devuelve un usuario por fila, con su cantidad de comentarios. *Verificado en
5.0.9; `GROUP BY` sobre un prefijo de la clave es un complemento del agente.*

**Publicar escribe dos tablas.** Un producto nuevo va a `productos` y a
`productos_por_usuario` en el mismo `BATCH`.

**`password_hash`, no `password`.** El DER dice "password"; se guarda su hash,
nunca la contraseña en claro. *Complemento del agente.*

### Verificación

| Consulta | Resultado sobre los datos de prueba |
|---|---|
| 1 | Ana Torres por su id |
| 2 | Mate de calabaza, con su categoría |
| 3 | `'Juan Gómez'` → Mate de calabaza (id …002) y Bombilla de acero (id …003) |
| 4 | Auriculares → 3 comentarios; con `GROUP BY`, 2 usuarios (…002 con 2, …003 con 1) |
| 5 | Ana Torres → Teclado, Bombilla, Mate, del más reciente al más viejo; entre el 24/9 y el 1/10, solo Bombilla |

## Parte II, ejercicio 3 — Cassandra según CAP

La cátedra clasifica a Cassandra como **AP**: prioriza disponibilidad y
tolerancia a particiones, y acepta inconsistencias temporales.
[T13, p. 18; T16, p. 11]

**Por qué.** No hay maestro: cualquier nodo puede coordinar una petición y
cualquier réplica acepta escrituras. Si una partición de red separa el clúster,
los dos lados siguen respondiendo con las réplicas que alcanzan. El precio es
que pueden divergir: las copias se reconcilian después —consistencia
eventual—, con mecanismos como el *read repair* que compara réplicas al leer.
[T16, pp. 12, 25–29, 40–43; C05]

**El matiz, que el propio material señala:** la consistencia es **configurable
por operación** con el *consistency level*. [T16, pp. 11, 44–46] Con `ONE`, una
sola réplica alcanza para responder: máxima disponibilidad, posible dato viejo.
Con `QUORUM` en lectura y escritura (R + W > N) cada lectura ve la última
escritura confirmada, pero si no hay mayoría disponible la operación **falla**:
en ese escenario se comporta como CP. AP describe el comportamiento por defecto
y la filosofía de diseño, no una garantía fija. *El cálculo R + W > N es un
complemento del agente.*

Contraste con MongoDB, clasificado como CP en el TP 9: allá las escrituras van a
un primario único, y sin mayoría no se escribe. Cassandra, sin primario, sigue
escribiendo.

## Lo más relevante del TP

1. **La clave de partición decide todo**: en qué nodo vive el dato y qué
   consultas son posibles. Filtrar por otra columna obliga a leer todas las
   particiones; por eso Cassandra lo rechaza salvo `ALLOW FILTERING` o un
   índice. [P12, pp. 2–3]
2. **Una tabla por consulta.** El diseño parte de las consultas y desnormaliza;
   las relaciones n:m se guardan solo en la dirección que se consulta.
3. **`INSERT` es un upsert**: una clave repetida pisa sin error. Por eso los ids
   entran en la clave cuando un nombre o una fecha podrían repetirse.
4. **Particiones acotadas**: los comentarios por rango de fechas se agrupan por
   día, ni en una partición única ni por noticia.
5. **Borrar es escribir** una tombstone; la limpieza es diferida.
6. **CAP**: AP por diseño, con la consistencia ajustable por operación.
