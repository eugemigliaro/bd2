# Cassandra: modelado y CQL

## Alcance y vocabulario

Cassandra se presenta como una base NoSQL distribuida, escalable horizontalmente y con comunicación peer-to-peer y soporte para varios data centers. La unidad la ubica en la familia tabular o de familias de columnas; su [representación visual](../../material/figuras/T16-p1-familias-columnas.png) permite filas con distintos pares columna–valor. Esa representación conceptual no basta para definir una tabla CQL. [T16, pp. 1–5, 9, 11–14]

| Término | Función en la unidad |
|---|---|
| Cluster | Conjunto completo de nodos; puede contener varios data centers y keyspaces. |
| Data center | Agrupación lógica de nodos para distribución y replicación. |
| Keyspace | Agrupación de tablas/familias de columnas, con opciones de replicación. |
| Familia de columnas | Contenedor de filas; la práctica lo declara con `CREATE TABLE`. |
| Columna | El modelo interno presentado distingue nombre, valor y timestamp. |

[T16, pp. 4, 29, 50–52, 59; P12, p. 1]

**Complemento del agente (no consta en el material cargado):** CQL define columnas y tipos en el esquema de la tabla; se agregan columnas mediante `ALTER TABLE`. No confundir el modelo histórico de columnas variables y supercolumnas con columnas arbitrarias en cada `INSERT` de CQL. [Apache Cassandra: definición de datos](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/ddl.html). Ver [dudas y conflictos](../dudas-y-conflictos.md).

## Diseñar desde las consultas

Antes de crear tablas, identificar las consultas de la aplicación. Elegir una partition key que distribuya los datos y permita acceder a pocas particiones; diseñar las tablas para esos patrones. La unidad contrapone este criterio con el diseño relacional centrado en relaciones y normalización: CQL no ofrece joins ni subconsultas como SQL. [T16, pp. 13, 16–19]

El TP concreta la desnormalización con `canciones` y `lista_reproduccion`: esta última guarda `cancion_id`, título, álbum y artista junto con la posición de la canción. La guía copia esos valores para consultar una lista sin hacer un join. [P12, pp. 1–2]

## Primary key, partition key y clustering key

La primary key identifica la fila y se compone de la clave de partición y, cuando existen, columnas de clustering. La primera determina qué filas pertenecen a la misma partición; las segundas ordenan las filas dentro de ella. El orden y los paréntesis de la declaración cambian el modelo. Los [ejemplos de claves](../../material/figuras/T16-p64-claves-compuestas.png) y la [comparación de formas](../../material/figuras/T16-p69-formas-primary-key.png) se revisaron visualmente. [T16, pp. 56, 63–69]

| Declaración | Partition key | Clustering |
|---|---|---|
| `PRIMARY KEY (a)` | `a` | Ninguno; una fila por partición. |
| `PRIMARY KEY (a, b, c)` | `a` | `b`, luego `c`. |
| `PRIMARY KEY ((a, b), c)` | Compuesta: `(a, b)` | `c`. |
| `PRIMARY KEY ((idusuario, mes), nombre, registro)` | `(idusuario, mes)` | `nombre`, luego `registro`. |

[T16, pp. 64, 66, 69]

En la [figura de particiones](../../material/figuras/T16-p65-particiones-clustering.png), `PRIMARY KEY (mes, nombre)` agrupa las filas de mes 5 en una partición y las de mes 11 en otra, ordenadas por nombre. En la [alternativa sin clustering](../../material/figuras/T16-p66-particiones-una-fila.png), `PRIMARY KEY (idusuario)` deja una sola fila por partición. [T16, pp. 65–66]

En el TP, `PRIMARY KEY (id, nro_cancion)` agrupa cada playlist por `id` y ordena sus canciones por `nro_cancion`. La pareja completa identifica una fila; el mismo `id` puede repetirse con distintos números de canción. [P12, p. 2]

## Consultas y filtrado

Para una consulta dirigida a una partición con clave compuesta, especificar todos sus componentes. El [ejemplo de usuarios](../../material/figuras/T16-p68-consulta-partition-key-compuesta.png) define `PRIMARY KEY ((idusuario, mes), nombre)`: filtrar solo por `mes` se rechaza; combinar `mes` e `idusuario` identifica la partición. La unidad presenta `ORDER BY` sobre columnas de clustering. [T16, pp. 67–69]

El recorrido de la playlist consulta una partición y ordena por `nro_cancion DESC`. En cambio, buscar por `artista` sin índice se rechaza en el escenario de la guía. `ALLOW FILTERING` permite realizar el filtrado, pero puede exigir recorrer muchos datos para devolver pocas filas. Es una opción explícita de ejecución, no una mejora del diseño. [P12, p. 2; T16, pp. 70–71]

Los índices secundarios amplían búsquedas sobre columnas; T16 los describe mediante una tabla oculta, y el TP crea índices sobre `artista` y el set `etiquetas`, consultado con `CONTAINS`. El propio material advierte que un índice no equivale al acceso dirigido por partition key ni resulta conveniente para todos los volúmenes y patrones. [T16, pp. 61–62; P12, p. 3]

**Complemento del agente (no consta en el material cargado):** los filtros sobre clustering y el orden permitido siguen la estructura de la clave; no habilitan ordenamientos arbitrarios como en SQL. Para decidir qué consulta admite el motor elegido, consultar [CQL: manipulación de datos](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/dml.html). La síntesis de T16, p. 67, es incompleta: también existen filtros válidos sobre clustering.

## Operaciones y funcionalidades del material

El TP recorre `CREATE KEYSPACE`, `USE`, `CREATE TABLE`, `INSERT`, `SELECT`, `CREATE INDEX`, `ALTER TABLE`, `UPDATE` y `DELETE`. Agrega etiquetas con `etiquetas = etiquetas + {...}` sobre `set<text>`; distingue eliminar una canción de una playlist, eliminar toda la partición de la playlist, eliminar la tabla y eliminar el keyspace. El último tramo de la guía son operaciones de limpieza, no pasos para conservar el trabajo. [P12, pp. 1–3]

T16 enumera tipos de colección `SET`, `LIST` y `MAP`, contadores, tipos definidos por el usuario y tuplas. También presenta una vista materializada con otra primary key: se modifica la tabla base y el motor mantiene la vista, que no se actualiza directamente. [T16, pp. 57, 72]

La clase distingue funciones escalares y agregadas, y muestra `SUM(players)`. Esto contradice la afirmación inicial de que `sum`/`avg` deben calcularse en el cliente; no memorizar esa prohibición como una regla general. Los triggers de esta unidad implementan lógica en clases JVM externas al texto CQL; no son los cuerpos SQL procedural estudiados para MySQL/PostgreSQL. Las recetas requieren revisión de sintaxis y versión antes de ejecutarse. [T16, pp. 6, 73–74]

## Continuar

- [Almacenamiento, borrados y Bloom filters](21-cassandra-almacenamiento-y-bloom.md).
- [Replicación, consistencia y DIGEST](22-cassandra-consistencia-y-digest.md).
- [TP 10, parte I](../../practica/tp-10/README.md): enunciado indexado, pendiente de resolución.
- [Dudas y conflictos](../dudas-y-conflictos.md): ejemplos con tipos incompatibles y diferencias de versión.
