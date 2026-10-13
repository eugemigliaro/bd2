# TP 9 — Resolución y observaciones

Las consultas están en [consultas.js](consultas.js); las cargas, en
[players.js](players.js) y [bandas.js](bandas.js). Este documento explica el
razonamiento. Fuentes: [P10A, pp. 1–7] y [P10B, pp. 1–2].

## Entorno

MongoDB 7.0.43 en el contenedor `bd2-mongo`, con `mongosh` 2.12 y
`mongoimport` 100.19. La guía propone `docker pull mongo` [P10A, p. 1], pero la
versión actual (9.0.2) no arranca en kernels Linux 6.19 o posteriores; la serie
7.0 no tiene ese problema. Detalle en
[dudas y conflictos](../../wiki/dudas-y-conflictos.md#mongodb-y-kernels-linux-619).

```bash
make db-up                            # levanta MySQL y MongoDB
docker compose exec mongo mongosh lab # o: make mongo-shell
```

`practica/` está montada en `/practica` y los datasets en `/recursos`: `load()`
y `mongoimport` los leen sin `docker cp`.

## Parte I — recorrido guiado (pasos 1–34)

Los pasos son comandos dados; lo que vale anotar es lo que muestran.

| Pasos | Observación |
|---|---|
| 1–3 | `mongosh` arranca en `test`; `use lab` selecciona una base que todavía no existe: se crea con la primera inserción. [P10A, p. 2] |
| 4–8 | Aaron y Cavani conviven en la colección con campos distintos. En SQL serían columnas con `NULL`; en MongoDB el campo directamente no está. [T13, p. 26] |
| 7 | `new Date(1987,2,14)` guarda **marzo**: los meses de JavaScript van de 0 a 11. La guía cae en la trampa: Messi (`new Date(1987,6,24)`) queda nacido el 24 de julio, no de junio; todas las fechas de nacimiento están corridas un mes. |
| 12 | `{height: null}` encuentra a Harry Kane aunque no tiene el campo: `null` coincide con "vale null" **o** "no existe". `$exists: false` distingue la ausencia; `$type: 'null'`, el valor nulo. |
| 13 | `{hobbies: 'Video games'}` sobre un arreglo significa "lo contiene". El `$or` del ejemplo no filtra nada: los 6 diestros cumplen alguna alternativa. |
| 18 | `$push` dos veces deja `'Swimming'` repetido: un arreglo es una lista. `$addToSet` evita duplicados. |
| 19–21 | Sin `upsert`, el `updateOne` sobre `hits` no hace nada (`matchedCount: 0`); con `{upsert: true}` inserta `{page, hits: 1}` tomando `page` del filtro; la siguiente vez incrementa. |
| 25 | Kane, sin `height`, queda último al ordenar descendente: un campo ausente vale como `null`, el menor valor. |
| 26 | `limit(2).skip(1)` y `skip(1).limit(2)` dan lo mismo: `find` aplica siempre sort → skip → limit. En un pipeline de agregación, en cambio, el orden de las etapas sí importa. |
| 27 | `countDocuments` cuenta documentos, no ocurrencias en un arreglo. `cursor.count()` está deprecado. |
| 30–34 | Ya existe el índice `_id_`, como el de la PK en MySQL. `ensureIndex` todavía funciona en mongosh 2.12, pero el nombre actual es `createIndex`. El plan pasa de `COLLSCAN` a `FETCH` sobre `IXSCAN`. Con `name_1` (único) y `name_1_weight_1`, el planificador elige `name_1`. El índice único rechaza un segundo Messi con `E11000 duplicate key`. |

*Complemento del agente (no consta en el material cargado): la semántica de
`null`, el orden de `null` al ordenar, `$addToSet`, el orden fijo de los
modificadores de cursor y los meses de `Date` provienen del manual de MongoDB y
de JavaScript; se verificaron en este entorno.*

## Parte I — bandas

### 1 — el modelo

Las consultas mandan sobre el modelo [P10A, p. 7]:

| Consultas | Qué exigen |
|---|---|
| 2–4, 9–11 | `integrantes` numérico; `barrio` y `genero` consultables |
| 5–6 | `genero` y `estilo` como texto, buscable con regex |
| 7–8 | el **año** de cada disco como número |
| 10 | una vista con solista, género, barrio e integrantes |
| Parte II, 6.b | la fecha de inscripción como fecha |

Decisiones:

- **Una colección `bandas` con los discos embebidos** como arreglo de
  `{titulo, anio}`. Pocos discos por banda y siempre consultados con ella:
  embeber evita el ensamble. [T14, pp. 3–8] Guardar `'MERIDIANO (2006)'` como
  texto haría inviables las consultas 7 y 8.
- **Los vacíos no se guardan.** Sin estilo no hay campo `estilo`; sin discos, no
  hay `discos`.
- **Valores en mayúscula**, como en la tabla y en la consulta de la parte II.
- **`EFECTO ALFONS` es una sola banda.** La tabla la repite con distinta fecha de
  inscripción y distinto disco, y el mismo género, estilo, barrio e integrantes.
  Las consultas cuentan **bandas**: con dos documentos, Barracas daría 3 y ROCK
  pesaría doble esa banda. Se modela con `fecha_inscripcion` como arreglo de
  fechas —en todas las bandas, por uniformidad— y los dos discos. No se pierde
  ningún dato, y un filtro de fechas sobre el arreglo pregunta "¿alguna cumple?".
  Registrado en [dudas y conflictos](../../wiki/dudas-y-conflictos.md#datos-de-bandas-e-identificadores-de-fecha-en-tp-9).

### 2–9 — consultas

| # | Resultado | Punto a notar |
|---|---|---|
| 2 | 11 bandas, de 1 a 7 integrantes | `sort({integrantes: 1})` |
| 3 | LA SURTIDA FOLCK (7), LMV (6) | `sort(-1).limit(2)` |
| 4 | `matchedCount 11, modifiedCount 11` | `updateMany({}, {$inc: …})` |
| 5 | EFECTO ALFONS, AFTERLIFE, VIRGINIA FERREYRA | igualdad simple |
| 6 | los tres + TANTAS PREGUNTAS y TAL VEZ DE PASO | ver abajo |
| 7 | VER K BITCH, TANTAS PREGUNTAS | `'discos.anio'` entre comillas |
| 8 | TROTAMUNDOS | `{$gt: 2010}` |
| 9 | 2 | con una fila por inscripción serían 3 |

**6 — tres errores instructivos del intento.** `find` recibe un documento, así
que `find($or: …)` es error de sintaxis. `"*ROCK*"` es un comodín de `LIKE` o
de la terminal, no una regex: `*` cuantifica lo anterior y al comienzo no tiene
qué repetir. Una regex sin `^` ni `$` ya significa "contiene", así que `ROCK`
equivale a `LIKE '%ROCK%'`; con `/rock/i` se ignoran mayúsculas.
[P10A, p. 4; T15, p. 21] El `genero: 'ROCK'` del `$or` no sobra: EFECTO ALFONS
tiene estilo `POWER TRIO`.

**7 y 8 — arreglos de subdocumentos.** La notación de punto entra en el arreglo y
el filtro pregunta "¿algún disco cumple?". TANTAS PREGUNTAS tiene dos discos de
2006 y aparece una vez: se eligen documentos, no elementos. Si hubiera **dos**
condiciones sobre el disco —"un disco entre 2006 y 2008"—, `{'discos.anio':
{$gte: 2006, $lte: 2008}}` podría satisfacerse con discos distintos; para
exigirlas sobre el mismo elemento se usa `$elemMatch`. [T15, p. 23]

### 10–11 — vista y agregación

```javascript
db.createView('bandas_resumen', 'bandas', [
  {$project: {_id: 0, nombre_solista: 1, genero: 1, barrio: 1, integrantes: 1}}
])
```

La vista es una consulta guardada [T13, pp. 50–52]; en MongoDB es de solo
lectura. El pipeline se traduce de SQL etapa por etapa: `$match` ≈ `WHERE`,
`$group` ≈ `GROUP BY` con sus agregados, `$sort` ≈ `ORDER BY`, `$project` ≈ la
lista del `SELECT`. En `$group`, `_id` es la clave de agrupación y `'$campo'`
—con `$`— es el valor del campo. [T15, pp. 31, 33–34]

**10 — el error de ordenar por un campo que ya no existe.** Los dos primeros
intentos ordenaban por `nombre_solista` y por `genero`. Tras `$group` cada
documento tiene solo `_id` y `promedio_integrantes`: ordenar por un campo
ausente no da error, pero todos empatan y el orden queda arbitrario. **Cada
etapa ve solo lo que dejó la anterior.** Ordenando por `_id`:

| Género | Promedio |
|---|---|
| FOLKLORE | 8 |
| HIP HOP / RAP | 2 |
| INDIE | 5 |
| INSTRUMENTAL | 2 |
| POP | 6 |
| PUNK | 4 |
| ROCK | 4 |
| SOLISTA | 2 |

Los promedios incluyen el integrante sumado en la consulta 4: las operaciones de
la consigna son consecutivas. ROCK = (4 + 6 + 2) / 3.

**11 — desempate.** BARRACAS tiene 2 bandas y los otros nueve barrios, 1. Sin
segunda clave el orden de los empatados es arbitrario; `{$sort: {cant_bandas:
-1, _id: 1}}` lo fija, como `ORDER BY cant DESC, barrio` en SQL.

## Parte II

### 4 — egresados

`mongoimport` carga el CSV desde la terminal del sistema; con `--headerline` la
primera fila da los nombres de campo. [P10B, p. 1] El archivo está montado en
`/recursos`, así que no hace falta `docker cp`.

**Lo que trae el archivo**, revisado antes de contar:

- **Tipos inferidos.** `mongoimport` convierte lo que parece entero en `int` y lo
  que tiene decimales en `double`. *Complemento del agente.*
- **Un registro con celdas vacías.** El legajo 19115 (Ingeniero Naval) trae
  `colacion`, `promedio` y `promedio_lineal` vacíos, que quedan como string
  `''`. `colacion` mezcla tipos: 8222 `int` y 1 `string`. MongoDB no tiene
  esquema que lo impida; con `--ignoreBlanks` los campos se habrían omitido.
- **Títulos frente a personas.** 8223 documentos son títulos; 8094 son legajos
  distintos, porque 129 títulos son segundas carreras. `distinct('legajo')`
  devuelve los valores únicos —el `SELECT DISTINCT`— y `.length` los cuenta en el
  shell; `{$group: {_id: '$legajo'}}` seguido de `{$count: …}` lo hace en el
  servidor.
- **Un duplicado aparente.** El legajo 49394 figura dos veces como Ingeniero
  Mecánico en la colación 50, una con promedio 0. Se informa y no se corrige.

**b — por carrera.** Se cuentan títulos: una persona con dos carreras cuenta una
vez en cada una. 19 carreras; encabezan Ingeniero Industrial (3847),
Electrónico (1099) y Químico (635).

**c — por colación, de mayor a menor.** El `$match` deja afuera el registro sin
colación, que si no aparece como un grupo `''` que no existe; va antes del
`$group`, como un `WHERE`. 58 colaciones; encabezan la 57 (342), la 51 (309) y
la 48 (306). El desempate por número de colación fija el orden.

**Variante: personas por colación.** Hay 72 casos de un legajo dos veces en la
misma colación. Para contar personas se agrupa primero por `{legajo, colacion}`
y después por `colacion`: un `COUNT(DISTINCT legajo)` en dos etapas.

### 1 — ejercicios del día 1 del libro (Do.2–Do.5)

La colección `towns` del libro —New York, Punxsutawney y Portland— se carga con
[towns.js](towns.js), adaptado a `mongosh` (`insertOne` en lugar del `insert`
deprecado). La función `insertCity` del libro muestra que el shell es
JavaScript: se pueden definir funciones y llamarlas. [B01, pp. 95, 97–98]

| Ejercicio (parafraseado) [B01, pp. 109–110] | Consulta | Resultado |
|---|---|---|
| Do.2: ciudad con *new*, sin distinguir mayúsculas | `{name: /new/i}` | New York |
| Do.3: nombre con *e* y famosa por comida o cerveza | `{name: /e/, famousFor: {$in: ['food', 'beer']}}` | New York |
| Do.4: base `blogger`, colección `articles`, un artículo | `insertOne` con `author: {name, email}`, `createdAt`, `text` | — |
| Do.5: agregarle un arreglo de comentarios | `updateOne(…, {$push: {comments: {author, text}}})` | — |

- **Do.3 combina dos condiciones distintas.** Portland es famosa por las dos
  cosas pero no tiene *e*; Punxsutawney tiene *e* pero no es famosa por ninguna.
  `$in` es el `IN` de SQL; sobre un arreglo pregunta si **algún** elemento está
  en la lista. Equivale a `$or: [{famousFor: 'food'}, {famousFor: 'beer'}]`.
- **Do.4: el autor como subdocumento** y no como dos campos sueltos: nombre y
  email describen una misma cosa y se consultan juntos (`'author.email'`).
- **Do.5: `$push` crea el arreglo si no existe.** No hace falta inicializar
  `comments` antes.

### 2 — índices por defecto [B01, pp. 110–111]

**a) Tipo de índice por defecto: B-tree**, el mismo árbol que usan los índices de
MySQL que viste en el TP 5. MongoDB ofrece además otros tipos —geoespaciales
`2d` y `2dsphere`, entre otros— que hay que pedir explícitamente.

**b) Índices automáticos: solo uno por colección, el de `_id`**, único y que no
se puede borrar. `getIndexes()` sobre `phones` recién creada devuelve solo
`_id_`.

| | MySQL (InnoDB) | MongoDB |
|---|---|---|
| Clave primaria | índice automático (agrupado: la tabla misma) | índice automático sobre `_id` |
| `UNIQUE` | crea un índice | no hay restricción sin índice: la unicidad **es** un índice `unique` |
| Clave foránea | crea un índice si no hay uno utilizable | no existen claves foráneas |

El libro menciona dos cosas desactualizadas: la colección `system.indexes`
(hoy se usa `getIndexes()`) y la opción `dropDups`, que MongoDB 7 acepta pero
ignora; si hay duplicados, la creación del índice único falla. *Complemento del
agente (no consta en el material cargado).*

### 3 — `EXPLAIN` de MySQL frente a `explain()` de MongoDB

Se reprodujo el experimento del libro (100 000 teléfonos, búsqueda por
`display`) en los dos motores. [B01, pp. 110–112]

| | MongoDB | MySQL 9.7 (formato TREE) |
|---|---|---|
| Sin índice | `COLLSCAN`, `totalDocsExamined: 100000`, ~120 ms | `Table scan on phones`, `rows=102591` estimadas |
| Con índice único | `FETCH` ← `IXSCAN display_1`, ~2 ms | `Rows fetched before execution`: la fila se resolvió al optimizar |

**Semejanzas:**

- Los dos muestran el **plan elegido** como un árbol que se lee desde las hojas
  y dicen si se recorrió todo o se usó un índice (`COLLSCAN`/`IXSCAN` frente a
  `Table scan`/`Index lookup`). [T08, pp. 4–5]
- Los dos tienen un modo que **no ejecuta** (`explain()` en modo `queryPlanner`,
  `EXPLAIN`) y otro que **ejecuta y mide** (`explain('executionStats')`,
  `EXPLAIN ANALYZE`). [T08, p. 1]

**Diferencias:**

- **Cómo elige.** MySQL estima costos con estadísticas (`cost=`, `rows=`
  estimadas; sin índice supone que el filtro deja ~10 %: `rows=10259`). MongoDB
  no muestra costos: si hay varios índices candidatos, los **prueba en paralelo**
  un rato y se queda con el que avanza más rápido, y guarda la decisión en un
  caché de planes.
- **Qué muestra.** MongoDB informa también los **planes descartados**
  (`rejectedPlans`; con dos índices sobre `display`, uno queda descartado).
  MySQL solo muestra el elegido.
- **Formato y métricas.** MongoDB devuelve un documento JSON con contadores
  reales (`nReturned`, `totalKeysExamined`, `totalDocsExamined`); MySQL, una
  tabla o un árbol de texto, con filas estimadas y, con `ANALYZE`, reales.
- **Alcance.** Un `EXPLAIN` de MySQL describe joins entre tablas; en MongoDB el
  plan es sobre una colección, y los ensambles aparecen como etapas `$lookup`
  de un pipeline.

*Complemento del agente (no consta en el material cargado): la selección de
planes por prueba y el caché de planes provienen del manual de MongoDB.*

El libro busca `'+1 800-5650001'`, que no existe: `populatePhones` genera hasta
5649999. La comparación sigue valiendo, porque lo que se mide es el recorrido.

### 5 — ciudades, índice `2d` y Do.1 del día 3

Se importaron las 99 838 ciudades a `test.cities` y se creó el índice
`{location: '2d'}`. [P10B, p. 1; B01, p. 130] El ejercicio pide las ciudades a
50 millas o menos del centro de Londres. [B01, p. 132]

**El hallazgo más importante del TP: las coordenadas están mezcladas, con una
regla exacta.**

| Documentos | Orden guardado | Ejemplos |
|---|---|---|
| ambos componentes ≥ 0 (62 678) | `[lat, lon]` | Cambridge `[52.2, 0.11667]`, Paris `[48.85, 2.35]`, Tokyo |
| algún componente < 0 (37 160) | `[lon, lat]` | London `[-0.12574, 51.50853]`, Buenos Aires, Sydney |

Ningún documento contradice la regla. La explicación más probable: el archivo
del libro estaba entero en `[lat, lon]` —su ejemplo rotula al revés Sant Julià de
Lòria y su `$geoNear` sobre Portland pone la latitud primero [B01, pp. 116,
130]— y la versión `fixed` de la cátedra invirtió solo los documentos con algún
valor negativo. *Inferencia del agente a partir de los datos.*

Londres está **sobre el meridiano de Greenwich**, así que la regla parte su
entorno en dos:

| Consulta | Ciudades | Al este de Greenwich |
|---|---|---|
| sobre los datos tal cual | 297 | **0** |
| sobre `cities_lonlat`, normalizada a `[lon, lat]` | **453** | 156 |

La consulta ingenua no da error: devuelve un resultado **plausible e
incompleto**. `cities_lonlat` se genera con un `$out` que da vuelta los pares
no negativos, sin tocar el original.

```javascript
const radio = 50 / 3963.2;   // millas a radianes
db.cities_lonlat.find(
  {location: {$geoWithin: {$centerSphere: [[-0.12574, 51.50853], radio]}}}
).sort({population: -1})
```

Encabezan London, City of London, Islington, Reading, Harrow, Luton, Sutton y
Milton Keynes.

**`$centerSphere` y no `$center`.** El índice `2d` modela un **plano**. `$center`
toma el radio en grados y dibuja un círculo en ese plano: con el radio de 50
millas pasado a grados de latitud devuelve 332 ciudades, porque a la latitud de
Londres un grado de longitud mide ~69 km y no 111. `$centerSphere` calcula
sobre la esfera —con el radio en radianes y la longitud primero— aunque el
índice sea `2d`. Para datos terrestres, lo recomendado es un índice `2dsphere`.
*Complemento del agente (no consta en el material cargado).*

### 6 — SQL a MongoDB

**a)** `WHERE genero = 'ROCK' AND integrantes > 2` → `find` con dos condiciones
en el mismo filtro (AND implícito) y proyección de `nombre_solista`:
**EFECTO ALFONS y AFTERLIFE**. VIRGINIA FERREYRA tiene 2 integrantes tras el
punto 4 de la parte I: el estado es acumulativo.

**b)** Cada cláusula es una etapa: `WHERE` → `$match`, `GROUP BY` con `AVG` y
`COUNT(*)` → `$group` con `$avg` y `$sum: 1`, `ORDER BY … DESC` → `$sort`.

| Género | Promedio | Bandas |
|---|---|---|
| FOLKLORE | 8 | 1 |
| POP | 6 | 2 |
| PUNK | 4 | 1 |
| ROCK | 4 | 3 |
| HIP HOP / RAP | 2 | 1 |
| SOLISTA | 2 | 1 |

Tres puntos finos:

- **La fecha se compara con una fecha.** `{$lte: '2017-11-27'}` no da error y
  devuelve **0** documentos: MongoDB compara solo valores del mismo tipo. En SQL
  el string se convierte solo; acá hay que escribir `new Date('2017-11-27')`.
- **El modelo cambia el resultado.** En la tabla SQL, con dos filas para EFECTO
  ALFONS, ROCK tendría `cant_bandas = 4`. Con un documento por banda da 3; el
  promedio coincide por casualidad. Sobre el arreglo de fechas, `$lte` pregunta
  si **alguna** inscripción es anterior.
- La consulta escribe `fecha_incripcion`, sin la *s*: errata registrada.
  PUNK y ROCK empatan en 4; el género desempata.

### 7 — fortalezas y debilidades de MongoDB [B01, p. 133; T13, pp. 26–30]

**Fortalezas:**

- **Escala horizontal**: replicación para disponibilidad y sharding para
  repartir datos y carga. [T13, p. 30; C02, pp. 1–2]
- **Modelo flexible**: no hay que declarar esquema y lo que en SQL sería un join
  se puede embeber; agregar un campo no requiere migración.
- **Fácil de adoptar** desde SQL: las operaciones tienen equivalentes directos
  (`find` ≈ `SELECT`, `$group` ≈ `GROUP BY`). [T13, p. 32]

**Debilidades:**

- **La flexibilidad no protege.** Sin esquema, un error de tipeo en un campo o
  un tipo inesperado pasa en silencio. Este TP lo mostró tres veces: la
  colación `''` de egresados, la fecha comparada con un string y las coordenadas
  invertidas —todas sin error, con resultados incorrectos—.
- **Desnormalizar duplica**: actualizar un dato repetido en muchos documentos es
  responsabilidad de la aplicación.
- **Un cluster exige diseño**: sumar nodos no es transparente como en otros
  motores distribuidos.

**Cuándo usarlo:** datos con estructura variable o que evoluciona, documentos
que se leen enteros (catálogos, perfiles, contenido, eventos), aplicaciones con
mucho volumen que necesitan escalar horizontalmente. **Cuándo no:** muchas
relaciones N:N consultadas en todas direcciones, o reglas de integridad
fuertes entre entidades, donde un relacional las garantiza por declaración.

### 8 — MongoDB según CAP

La cátedra clasifica MongoDB como **CP**. [T13, p. 18] La razón está en el
replica set: las escrituras van a un único primario. Si una partición deja a un
grupo de nodos sin mayoría, ese lado no puede elegir primario y **deja de
aceptar escrituras**: se resigna disponibilidad para no tener dos versiones
divergentes de los datos. [T13, pp. 12–18; C02, pp. 1–2]

El matiz: la clasificación describe la configuración por defecto. Leer de
secundarios devuelve datos posiblemente desactualizados, lo que acerca el
comportamiento a AP; las garantías dependen de los niveles de lectura y
escritura configurados. Ver [NoSQL y CAP](../../wiki/temas/15-nosql-y-cap.md).
*Complemento del agente (no consta en el material cargado).*

## Lo más relevante del TP

1. **El modelo se decide por las consultas** [P10A, p. 7]: discos con año
   numérico, una banda por documento. Esa decisión cambia resultados (Barracas
   2 o 3; ROCK 3 o 4 bandas).
2. **MongoDB falla en silencio.** Fecha contra string, colación vacía,
   coordenadas invertidas: ninguno da error y los tres dan resultados
   incorrectos. Hay que mirar los datos antes de consultarlos.
3. **El orden de las coordenadas del JSON de ciudades sigue una regla de signo**:
   alrededor de Londres, la consulta ingenua pierde 156 de 453 ciudades.
4. **Arreglos: el filtro pregunta "¿algún elemento cumple?"**. Con dos
   condiciones sobre el mismo elemento hace falta `$elemMatch`.
5. **En `find`, sort → skip → limit siempre; en un pipeline, el orden escrito.**
   Cada etapa solo ve lo que dejó la anterior.
6. **Trampas del material**: meses 0–11 en `new Date`, el `$or` del paso 13 que
   no filtra, `ensureIndex`/`count()`/`dropDups` desactualizados, el teléfono
   inexistente del libro.
