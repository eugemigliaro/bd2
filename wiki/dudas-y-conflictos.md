# Dudas y conflictos detectados

Este registro evita resolver silenciosamente diferencias entre fuentes, notas y entorno.

## Versión de MySQL de Clase I

- **Fuente:** C01 indica `mysql:9.7.2` y `docker pull mysql:9.7.2`. [C01, p. 15]
- **Verificación externa al 2026-08-22:** MySQL 9.7.2 fue publicado el 2026-07-28 y la imagen oficial ofrece la etiqueta `mysql:9.7.2` para `amd64` y `arm64`.
- **Decisión actual del repo:** fijar `mysql:9.7.2`, alineando el laboratorio con la versión indicada por la cátedra.
- **Corrección:** se retira la decisión anterior de usar 9.7.1; la afirmación de que 9.7.2 no estaba publicada al 2026-08-04 quedó invalidada por la información oficial.

Referencias externas: [release notes oficiales de MySQL 9.7](https://dev.mysql.com/doc/relnotes/mysql/9.7/en/) y [imagen oficial de MySQL en Docker Hub](https://hub.docker.com/_/mysql).

## Mezcla de dialectos

- T03 y T04 enseñan parte del DDL con sintaxis PostgreSQL. [T03, p. 10; T04, p. 3]
- T05C combina construcciones de MySQL y SQL Server. [T05C, pp. 7–16]
- **Decisión:** preservar las fuentes, explicar conceptos y producir soluciones relacionales en MySQL.

## Actualización de vistas de ensamble en MySQL

- T07 enumera los ensambles entre las construcciones que vuelven no actualizable una vista en MySQL. [T07, p. 13]
- Un ejemplo visual anterior muestra `INSERT` y `UPDATE` sobre una vista que ensambla `alumnos` y `profesores`; las capturas posteriores rechazan ciertos `INSERT`, permiten un `UPDATE` sobre columnas de la parte actualizable y rechazan el `DELETE` directo de la vista de ensamble mostrada. [T07, pp. 9–10, 14–16]
- **Decisión:** no usar “tiene join” como respuesta única. En ejercicios MySQL, analizar por separado cada DML y la tabla/columna que se pretende afectar.

## Ejemplo de vista materializada

- T07 muestra una sentencia PostgreSQL `CREATE MATERIALIZED VIEW` que además incluye `WITH LOCAL CHECK OPTION`. [T07, p. 21]
- La misma unidad trata `CHECK OPTION` como una condición de vistas automáticamente actualizables, mientras que las materializadas se describen como copias almacenadas que requieren sincronización. [T06, p. 15; T07, p. 17]
- **Decisión:** conservar la diapositiva como ejemplo de la cátedra, pero no usar esa combinación como receta ejecutable sin verificar el dialecto.

## Inconsistencias tipográficas en ejemplos de vistas

- T06 define `PROV_COMP_TANDIL` y luego usa `PR_COMP_TANDIL`; también alterna `ENVIOS500`, `ENVIO500` y un identificador `Envios500-999` que contiene guion. [T06, pp. 5–7, 16–17]
- P04 adopta nombres consistentes con guion bajo: `ENVIOS500` y `ENVIOS500_999`. [P04, p. 1]
- **Decisión:** usar los nombres de P04 al preparar SQL ejecutable.

## Cálculo porcentual en el caso `LIKE '%'`

- T08 afirma que pasar de costo `933897` a `511017` es un incremento de 45,3 %. [T08, p. 16]
- Esos valores representan en realidad una disminución aproximada de 45,3 %; además, costo estimado y tiempo real no son equivalentes.
- **Decisión:** conservar las cifras y corregir el sentido del porcentaje al explicar el ejemplo.

## Alcance PostgreSQL de T08

- La unidad usa comandos, catálogo, parámetros y planes de PostgreSQL, aunque el motor relacional de trabajo del repositorio es MySQL. [T08, pp. 1–10; C01, pp. 15–17]
- **Decisión:** incorporar su método de lectura y diagnóstico, pero adaptar y verificar cualquier comando antes de ejecutarlo en MySQL.

## TP4: clave proyectada y chequeos encadenados

- La regla de cátedra exige conservar todas las columnas de la PK. [T06, p. 12] En el laboratorio MySQL 9.7.2, `Departamento_dist_200` figura con `IS_UPDATABLE = YES` aunque omite parte de la PK. **Decisión:** distinguir el criterio teórico de las posibilidades por operación del motor; no presentar la falta de PK proyectada como prohibición universal de UPDATE.
- T06 resume LOCAL como control del predicado propio. [T06, p. 15] Complemento del agente (no consta en el material cargado): MySQL mantiene además los chequeos propios de las vistas inferiores; LOCAL no los desactiva. Véase el [manual oficial](https://dev.mysql.com/doc/refman/5.7/en/view-check-option.html), reglas desde 5.7.6. **Decisión:** explicitar ese alcance en la [matriz del TP4](../practica/tp-04/solucion.md), sin atribuir el detalle a las diapositivas.

## Tipos de `MATCH` y acciones referenciales en MySQL

- T09 presenta `MATCH SIMPLE`, `PARTIAL` y `FULL`, además de `NO ACTION`, `RESTRICT`, `CASCADE`, `SET NULL` y `SET DEFAULT`, según SQL estándar/PostgreSQL. [T09, pp. 8–14]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/constraint-foreign-key.html) indica que MySQL aplica semántica `MATCH SIMPLE`; una cláusula `MATCH` explícita no implementa los otros modos y puede hacer que se ignoren las acciones referenciales de la misma definición. También indica que InnoDB rechaza `SET DEFAULT` y trata `NO ACTION` como `RESTRICT`.
- **Decisión:** resolver los tres tipos de matching desde la teoría cuando lo pida P06, pero omitir `MATCH` explícito en DDL MySQL y usar solo acciones admitidas por InnoDB.

## `CHECK`, subconsultas y `ASSERTION`

- T09 presenta `CHECK` con subconsultas para reglas entre filas y `CREATE ASSERTION` para reglas globales. [T09, pp. 22–25]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-table-check-constraints.html) confirma que un `CHECK` admite referencias a columnas de la fila, pero prohíbe subconsultas. La propia cátedra señala que los DBMS comerciales no implementan `ASSERTION`. [T09, p. 23; T10, pp. 16–19]
- **Decisión:** usar `CHECK` para reglas de atributo o tupla y diseñar triggers u otra representación para reglas entre filas o tablas.

## Granularidad y sintaxis de triggers

- T09 muestra sintaxis PostgreSQL con `BEFORE`, `AFTER`, `INSTEAD OF`, eventos combinados y granularidad por fila o sentencia; además usa `EXECUTE PROCEDURE`. [T09, pp. 27–30]
- P07 aclara que MySQL no soporta `FOR EACH STATEMENT`. [P07, p. 1] El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-trigger.html) exige `FOR EACH ROW`, un único evento y tiempo `BEFORE` o `AFTER`, y usa `OLD.columna`/`NEW.columna`.
- La documentación actual de [PostgreSQL `CREATE TRIGGER`](https://www.postgresql.org/docs/current/sql-createtrigger.html) prefiere `EXECUTE FUNCTION`; acepta `PROCEDURE` como palabra histórica, pero el objeto invocado sigue siendo una función trigger.
- **Decisión:** conservar T09 para teoría y escribir los ejercicios ejecutables con sintaxis MySQL.

## Procedimientos en versiones actuales de PostgreSQL

- T10 afirma que para PostgreSQL “todos son funciones” y llama procedimientos a las funciones que devuelven `void`. [T10, p. 6]
- PostgreSQL actual posee objetos procedimiento creados con [`CREATE PROCEDURE`](https://www.postgresql.org/docs/current/sql-createprocedure.html) e invocados mediante `CALL`.
- **Decisión:** interpretar la diapositiva como material de una versión anterior; no usar esa frase para describir versiones actuales.

## `FLUSH PRIVILEGES` después de `GRANT` o `REVOKE`

- T11 indica ejecutar `FLUSH PRIVILEGES` una vez terminada la configuración con `GRANT` o `REVOKE`. [T11, pp. 12–13]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/privilege-changes.html) establece que las sentencias de administración como `GRANT` y `REVOKE` recargan los cambios inmediatamente; `FLUSH PRIVILEGES` hace falta cuando se modifican directamente las tablas de privilegios o en flujos especiales.
- **Decisión:** omitir `FLUSH PRIVILEGES` después de `GRANT`/`REVOKE` en soluciones ordinarias y explicar el caso excepcional si aparece.

## Índices hash y motor de almacenamiento

- T11 concluye con `CREATE INDEX MYINDEX ON USERS (DNI) USING HASH` sin declarar el motor de la tabla. [T11, p. 38]
- El [manual oficial de MySQL 9.7](https://dev.mysql.com/doc/refman/9.7/en/create-index.html) lista B-tree para InnoDB y permite elegir hash o B-tree en `MEMORY`.
- **Decisión:** estudiar las propiedades de hash desde T11, pero no esperar un índice hash sobre las tablas InnoDB habituales del laboratorio.

## Nombre del rol en TP 8

- P08 pide crear el rol `ins_vol` en 2.g y luego asignar/modificar/eliminar `ins_prov` en 2.h–2.j. [P08, p. 2]
- Leída literalmente, la consigna falla en MySQL 9.7.2: `GRANT ins_prov TO …` da `ERROR 3523`, `GRANT … TO ins_prov` da `ERROR 1410` y `DROP ROLE ins_prov` da `ERROR 1396`. Verificado en la [resolución del TP 8](../practica/tp-08/solucion.md).
- **Decisión:** tratar `ins_prov` como error tipográfico de `ins_vol` y resolver 2.h–2.j con `ins_vol`; la lectura literal se conserva solo para explicar esos errores.

## Nombre del CSV de materias en TP 5

- P05 indica importar `materias.csv`, pero el archivo recibido y catalogado se llama `materia.csv`. [P05, p. 3; P05A]
- **Decisión:** usar `material/catedra/practica/recursos/tp-05-materia.csv`; el contenido y sus columnas corresponden a la tabla `materia` pedida por la guía.

## Diferencias entre el PDF y SQL de stored procedures

- P09 define `RegistrarEntrega` sin parámetro de ID de entrega, mientras SQL02 agrega `p_id_en`; también difieren algunos valores y longitudes de columnas. [P09, pp. 1–3; SQL02]
- **Decisión:** ambas fuentes provienen de la cátedra. Fijar explícitamente el esquema elegido antes de ejecutar o corregir una solución, sin ocultar la diferencia entre el enunciado y su implementación.

## NoSQL: generalizaciones sobre esquema, rendimiento y ACID

- T13 presenta ausencia de esquema, alta velocidad y ausencia de cuellos de botella como propiedades generales; también afirma que NoSQL no trata datos críticos que requieren ACID. [T13, pp. 4, 6–11]
- **Complemento del agente (no consta en el material cargado):** MongoDB permite validación de esquema y transacciones ACID sobre múltiples documentos. Las garantías transaccionales dependen de read/write concern. Véanse [validación](https://www.mongodb.com/docs/manual/core/schema-validation/) y [transacciones](https://www.mongodb.com/docs/manual/core/transactions/).
- **Decisión:** estudiar la motivación y los compromisos de la unidad; no usar esas frases como garantía universal de rendimiento ni como descripción actual de todos los motores NoSQL. El esquema flexible sigue requiriendo decisiones de diseño. [T14, pp. 2–8]

## CAP: simplificación “elegir dos” y clasificación de motores

- T13 formula CAP como elegir dos propiedades; define disponibilidad en términos de servicio ininterrumpido/porcentaje de tiempo y clasifica MongoDB como CP, Cassandra como AP y MySQL/PostgreSQL como CA. La clasificación se verificó visualmente. [T13, pp. 12–18]
- **Complemento del agente (no consta en el material cargado):** el compromiso C/A surge ante particiones; la C de CAP no equivale a la C de ACID. La disponibilidad formal exige respuesta eventual a cada petición del servicio considerado. Referencias primarias: [Brewer, apartados “Why 2 of 3…” y “ACID, BASE, and CAP”](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/) y [Gilbert y Lynch, sección 2](https://groups.csail.mit.edu/tds/papers/Gilbert/Brewer2.pdf).
- **Decisión:** conservar la clasificación de T13 para el ejercicio de cátedra y explicitar escenario, configuración y operaciones al analizar un sistema concreto. No atribuir la precisión externa a la diapositiva. [P10B, p. 2]

## MongoDB y kernels Linux 6.19+

- P10A propone `docker pull mongo`, sin etiqueta de versión. [P10A, p. 1]
- **Complemento del agente (no consta en el material cargado):** al 2026-10-12, `mongo:latest` es 9.0.2 y aborta al iniciar con “MongoDB cannot start: Linux kernel versions 6.19 and newer has a known incompatibility”. El ticket [SERVER-121912](https://jira.mongodb.org/browse/SERVER-121912) lo atribuye a TCMalloc y a un cambio de `rseq` en el kernel que afecta a MongoDB 8.0+; [SERVER-125742](https://jira.mongodb.org/browse/SERVER-125742) indica que los kernels 7.0.14+ y 7.1+ restauran el comportamiento y que la serie 7.0 no está afectada. El entorno corre Ubuntu `7.0.0-30-generic`, basado en 7.0.12.
- **Decisión:** fijar `mongo:7.0.43` en `compose.yaml`. Todo lo que pide el TP 9 —CRUD, agregación, vistas, índices `2d`, `mongoimport`— existe en 7.0. Revisar al actualizar el kernel.

## MongoDB: métodos históricos y datos de versión

- Las fuentes usan `insert`, `update`, `remove`, `count` y `ensureIndex`; T15 también muestra `mongo`, `system.js.save`, `loadServerScripts` y un ejemplo Python con `print` sin paréntesis. [T13, pp. 32, 37–39; T15, pp. 12–14, 20, 25, 27–29, 38–39, 41; P10A, p. 6]
- **Complemento del agente (no consta en el material cargado):** el manual de [compatibilidad de mongosh](https://www.mongodb.com/docs/mongodb-shell/reference/compatibility/) ofrece métodos actuales de CRUD y conteo; para índices se usa [`createIndex`](https://www.mongodb.com/docs/manual/reference/method/db.collection.createIndex/). No asegurar compatibilidad de funciones históricas sin comprobar el entorno.
- T15 muestra release 6.0.5 con fecha 2023-03-13 y un ranking de abril de 2023. Son datos de la captura; el ciclo 2026 del catálogo identifica la cursada en que se recibió el archivo. [T15, pp. 2–3]
- **Decisión:** conservar las fuentes y adaptar comandos al cliente elegido, sin tratar la versión o el ranking históricos como actuales. Las recetas no se ejecutaron en esta incorporación.

## Upsert en TP 9, parte I

- La prosa de la guía pide un tercer parámetro “true”, pero el ejemplo correcto pasa `{upsert: true}` a `updateOne`. [P10A, pp. 4–5]
- **Complemento del agente (no consta en el material cargado):** el tercer argumento es un documento de opciones, según el [manual de `updateOne`](https://www.mongodb.com/docs/manual/reference/method/db.collection.updateOne/).
- **Decisión:** usar el objeto de opciones que muestra el ejemplo.

## Datos de bandas e identificadores de fecha en TP 9

- La tabla visual repite `EFECTO ALFONS` en dos filas: inscripción 27/11/2017, disco de 2000, y 06/11/2017, disco de 1995. No especifica si son dos inscripciones de una banda o filas que deben unificarse. [P10A, p. 7]
- La cabecera usa `FECHA_INSCRIPCION`, pero la consulta de la parte II escribe `fecha_incripcion`. [P10A, p. 7; P10B, p. 2]
- **Decisión:** no deduplicar automáticamente; fijar identidad/granularidad al resolver. Mantener el nombre de campo elegido de manera coherente y señalar la errata de la consulta.
- **Resolución adoptada en el TP 9:** un documento por banda. `EFECTO ALFONS` reúne sus dos discos y `fecha_inscripcion` es un arreglo de fechas en todas las bandas, porque las consultas cuentan bandas. Ver la [resolución](../practica/tp-09/solucion.md).

## Fechas de nacimiento de `players` en TP 9

- P10A crea las fechas con `new Date(año, mes, día, 0, 0)` usando el mes calendario: Messi figura como `new Date(1987,6,24,0,0)`. [P10A, pp. 2–3]
- **Complemento del agente (no consta en el material cargado):** en JavaScript el mes va de 0 a 11, así que esa expresión guarda el 24 de julio; Messi nació el 24 de junio. Todas las fechas de nacimiento de la guía quedan corridas un mes.
- **Decisión:** reproducir los comandos tal como están, porque ninguna consulta del TP depende de esas fechas, y señalar la trampa. Las fechas propias se escriben como texto ISO (`new Date('2017-11-27')`).

## Egresados: esquema de ejemplo frente al CSV recibido

- T15 muestra un documento con campos `Legajo`, `Apellido`, `Nombre`, `Título` y `promedio_lineal`; P10C contiene `legajo`, `nivel`, `titulo`, `colacion`, `promedio` y `promedio_lineal`. [T15, p. 8; P10C]
- **Decisión:** para el TP 9 usar la cabecera real del CSV, incluida la escritura de `titulo` sin tilde y en minúscula. No copiar campos del ejemplo de T15 ni asumir que ambas instancias contienen los mismos atributos.

## Ciudades: orden de coordenadas pendiente de revisión

- P10D tiene coordenadas de Buenos Aires (AR) `[-58.37723, -34.61315]`, pero el primer documento, Sant Julià de Lòria (AD), tiene `[42.46372, 1.49129]`. También hay documentos como Teknāf (BD) `[20.86243, 92.30582]`, cuyo segundo componente supera 90. Son observaciones directas del archivo; el nombre recibido contiene `fixed`, pero no garantiza homogeneidad. [P10D]
- **Complemento del agente (no consta en el material cargado):** para coordenadas terrestres se usa longitud primero y latitud después; la documentación de [`2dsphere`](https://www.mongodb.com/docs/manual/core/indexes/index-types/geospatial/2dsphere/) exige longitud en [-180,180] y latitud en [-90,90]. [`2d`](https://www.mongodb.com/docs/manual/core/indexes/index-types/geospatial/2d/) modela un plano y no es equivalente a geometría esférica.
- **Inferencia del agente a partir de los datos:** el orden parece mezclado. Los ejemplos y rangos no permiten corregir con certeza todos los registros, especialmente cuando ambos componentes están entre -90 y 90.
- **Decisión:** conservar el JSON recibido y auditar el orden antes del ejercicio geoespacial. No intercambiar todas las coordenadas ni sustituir silenciosamente el índice `2d` pedido por la guía. [P10B, p. 1]
- **Auditoría del 2026-10-13 (inferencia del agente a partir de los datos):** el orden sigue una regla de signo sin excepciones. Los 62 678 documentos con ambos componentes ≥ 0 están en `[lat, lon]`; los 37 160 con algún componente negativo, en `[lon, lat]`. Es compatible con un archivo original del libro entero en `[lat, lon]` —su ejemplo rotula al revés Sant Julià de Lòria y su `$geoNear` pone la latitud primero— al que se le invirtieron solo los pares con algún negativo. [B01, pp. 116, 130]
- **Resolución adoptada en el TP 9:** derivar `cities_lonlat` con un `$out` que invierte los pares no negativos y consultar con `$centerSphere` sobre el índice `2d`. Alrededor de Londres, sobre el meridiano de Greenwich, la consulta sin normalizar devuelve 297 ciudades y ninguna al este; normalizada, 453. Ver la [resolución](../practica/tp-09/solucion.md).

## MapReduce deprecado

- T15 y C03 enseñan el método MapReduce y sus resultados. [T15, pp. 35–37; C03, pp. 1–2]
- **Complemento del agente (no consta en el material cargado):** el [manual de MongoDB](https://www.mongodb.com/docs/v8.0/reference/method/db.collection.mapreduce/) informa deprecación desde 5.0 y propone pipelines de agregación.
- **Decisión:** mantener el concepto y el ejemplo de la cátedra, indicando el alcance histórico del método al preparar código.

## Consulta de cliente en T14

- La consigna dice obtener teléfono y número de cliente de Wanda Baker, pero la proyección muestra solo `codigo_area` y `nro_telefono`, además del `_id` devuelto por defecto. No identifica un campo explícito de número de cliente. [T14, p. 26]
- **Decisión:** no inventar ese campo; al resolver, confirmar si `_id` representa el número pedido o si falta una columna en la proyección.

## Solución oficial e-commerce: alcance y empates

- El top 5 pide nombre, país y monto. La solución indica agregar `$limit: 5` al pipeline del gasto por cliente, pero esa proyección tiene nombre, email y gasto, sin país. [P11, p. 1; P11A, pp. 2, 4]
- El punto opcional pide listar órdenes por cliente incluyendo productos. La solución agrupa por nombre del cliente y acumula nombres de productos; pierde ID/fecha de orden y cantidades, y podría unir clientes homónimos. [P11, p. 1; P11A, p. 4]
- **Análisis del agente sobre los datos provistos:** auriculares y libro suman tres unidades cada uno; el pipeline ordena solo por unidades y limita a uno, sin un criterio de desempate. [P11, pp. 1–2; P11A, pp. 2–3]
- **Decisión:** conservar la solución como oficial, pero corregir su alcance al preparar una respuesta completa y fijar el tratamiento de empates. Los pipelines calculan ingresos con el precio del catálogo; no se modela precio histórico por renglón. [P11, pp. 1–2; P11A, pp. 2–3]

## Vacíos de cobertura del TP 9 y figuras

- P10B remite a *Seven Databases in Seven Weeks*, segunda edición, capítulo 4. [P10B, pp. 1–2] El libro se incorporó el 2026-10-13 como B01, con estado `local`: la copia tiene licencia institucional para la biblioteca del ITBA, así que no se versiona en el repositorio público y su texto extraído también queda fuera de git.
- En el capítulo 4, la página impresa N del libro es la página N + 13 del PDF; en otros capítulos el desfase cambia (ver [TP 11, 12 y 13](#tp-11-12-y-13-preparación-bibliografía-y-vacíos)). Los enunciados de Do.2–Do.5 están en las pp. 109–110 y el de Do.1 en la p. 132. [B01, pp. 109–110, 132]
- **Decisión:** usar B01 solo para lo que el TP 9 remite, sin volcar el libro a la wiki, que no es de lectura completa obligatoria. Las soluciones parafrasean los enunciados en vez de copiarlos.
- La captura de resultado de `$lookup` se interrumpe al mostrar el documento con `_id: 3`; el recorte ya está en el original. [T14, p. 24]
- **Decisión:** no atribuir a esa imagen un resultado completo que no se ve. La semántica adicional se documenta como complemento del manual oficial.

## Cassandra: modelo histórico de columnas frente a CQL

- T16 presenta filas con columnas variables, supercolumnas y el modelo nombre–valor–timestamp; luego declara tablas CQL con nombres y tipos de columnas. La introducción no distingue explícitamente ambas representaciones. [T16, pp. 2, 5, 18, 50–58, 63–69]
- **Complemento del agente (no consta en el material cargado):** las tablas CQL tienen columnas definidas por su esquema, ampliables mediante `ALTER TABLE`. [Apache Cassandra: DDL](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/ddl.html).
- **Decisión:** estudiar la familia de columnas como modelo conceptual y usar el esquema CQL para las operaciones del TP. No deducir que cada insert puede inventar columnas ni que las supercolumnas sean una receta CQL del TP.

## Cassandra: contradicción sobre agregaciones y recetas CQL

- T16 afirma que las agregaciones `sum`/`avg` deben hacerse del lado del cliente, pero la misma clase muestra funciones agregadas con `SELECT SUM(players) FROM plays`. [T16, pp. 6, 73]
- **Complemento del agente (no consta en el material cargado):** el manual documenta `sum`, `avg`, `count`, `min` y `max` como agregados nativos. [Funciones CQL](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/functions.html).
- **Decisión:** no enseñar una prohibición general de agregaciones. Registrar el desacuerdo interno y separar capacidad del lenguaje de conveniencia para una carga analítica.
- La clase adjunta `USING CONSISTENCY QUORUM` a un `SELECT`, mientras que el cliente de la práctica es `cqlsh`. [T16, p. 45; P12, p. 1]
- **Complemento del agente (no consta en el material cargado):** en `cqlsh` se establece el nivel con el comando independiente `CONSISTENCY QUORUM;`. [Manual de cqlsh](https://cassandra.apache.org/doc/latest/cassandra/managing/tools/cqlsh.html).
- El ejemplo de trigger contiene `#(java class)`, una comilla de cierre tipográfica y `DROP TRIGGER myTrigger;` sin tabla. Se preserva como exposición conceptual, sin convertirlo en código ejecutable. La lógica se implementa fuera de CQL en una clase JVM. [T16, p. 74]

## Cassandra: tipos y límites de los ejemplos de usuarios/blogs

- Las imágenes de usuarios declaran `registro time` pero representan fechas como 21-05-2015. [T16, pp. 63–68]
- **Complemento del agente (no consta en el material cargado):** `time` almacena una hora sin fecha; usar `date` si solo importa el día o `timestamp` si se necesita fecha y hora. [Tipos CQL](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/types.html).
- `blogs` declara `time1 int`, pero filtra con `1418306451235`. **Análisis del agente:** ese literal supera el máximo 2.147.483.647 de un entero con signo de 32 bits. El ejemplo introduce un problema de tipo además del filtrado que quiere explicar. [T16, p. 70]
- **Complemento del agente (no consta en el material cargado):** CQL define `int` de 32 bits y `bigint` de 64; elegir el tipo según la semántica del dato antes de reproducir ese ejemplo. [Tipos CQL](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/types.html).
- La lámina de consultas limita su explicación de `WHERE` a partition key/índices, sin explicar filtros de clustering. [T16, p. 67]
- **Complemento del agente (no consta en el material cargado):** CQL admite restricciones de clustering conforme a la estructura de la clave; `ORDER BY` sigue el orden de clustering permitido. [DML](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/dml.html).
- **Decisión:** mantener las figuras originales, explicar su objetivo de particionado y anotar la adaptación antes de ejecutar; no atribuir a `ALLOW FILTERING` la solución del desbordamiento de tipo.

## Cassandra: DIGEST, reparación de lectura y versiones

- T16 y C05 presentan reparación en segundo plano después de devolver el resultado. C05 omite la recuperación de valores completos tras encontrar digests distintos y dibuja consulta de las tres réplicas con RF=3, mencionando varios CL. La secuencia no distingue qué réplicas se necesitan para cada CL. [T16, pp. 28, 41–43, 45; C05]
- **Complemento del agente (no consta en el material cargado):** un digest distinto requiere datos completos para reconciliar; pueden combinarse valores de columnas. Desde 4.0 se retiró background read repair y la tabla configura `read_repair` como `BLOCKING` o `NONE`. La lectura consulta las réplicas necesarias para su CL, con posibles solicitudes adicionales; no implica reparar siempre todas las copias. [Apache Cassandra: read repair](https://cassandra.apache.org/doc/latest/cassandra/managing/operating/read_repair.html).
- **Decisión:** conservar la secuencia de cátedra con alcance histórico explícito. No equiparar read repair con mantenimiento periódico `repair` ni asumir que una lectura garantiza el dato más reciente de una réplica que no consultó.

## Cassandra: consistencia, disponibilidad y durabilidad

- T16 afirma que al caer un nodo el servicio no se degrada y presenta escalabilidad lineal; más adelante hace depender el éxito de la operación de la cantidad de réplicas que responden. La tabla de escritura llama a QUORUM “consistencia fuerte” sin fijar el CL de lectura. [T16, pp. 11, 24, 36–37, 41, 44–46]
- **Inferencia del agente a partir de la clase:** disponibilidad y rendimiento no son garantías independientes de RF, CL, carga, distribución de particiones y cantidad de fallas. Registrar los supuestos al analizar una instalación.
- **Complemento del agente (no consta en el material cargado):** el solapamiento de respuestas de lectura y escritura se expresa con `R + W > RF`; `ANY` puede confirmar con un hint y solo se admite para escrituras. [Apache Cassandra: Dynamo/consistencia](https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html). La tabla de ANY de T16, p. 46, omite esa diferencia.
- **Decisión:** separar RF de CL y usar mayoría entera `floor(N/2)+1` al interpretar QUORUM. No tratar todas las filas de las tablas históricas como niveles intercambiables entre lectura, escritura, cliente y versión.
- T16 vincula éxito con commit log y memtable y dice que el log garantiza durabilidad, sin precisar sincronización en disco. [T16, pp. 32, 37]
- **Complemento del agente (no consta en el material cargado):** `commitlog_sync` distingue modos de sincronización y confirmación; en modo periódico el reconocimiento no espera siempre al `fsync`. [Storage engine](https://cassandra.apache.org/doc/latest/cassandra/architecture/storage-engine.html).
- **Decisión:** explicar el recorrido del log sin extrapolar sincronización inmediata universal.

## Cassandra: Bloom filters, compactación y expiración

- T16 describe un Bloom filter como algoritmo “no determinista” y “tipo especial de caché”; C04 lo explica como vector de bits y hashes que descarta SSTables, sin localizar ni devolver el dato. [T16, p. 30; C04, pp. 1–8]
- **Decisión:** usar la explicación detallada de C04. “Probabilístico” caracteriza la posibilidad de falsos positivos; no significa que al repetir una consulta sobre el mismo vector el resultado deba variar.
- T16 afirma que la compactación elimina las filas marcadas y escribe `LLTS` para caducidad. También describe una familia de columnas como un fichero separado, aunque previamente explica que una partición puede ocupar varias SSTables. [T16, pp. 33–34, 38–39, 57]
- **Complemento del agente (no consta en el material cargado):** la expiración por TTL genera tombstones; la purga requiere período de gracia y condiciones de compactación, no solo el paso del tiempo. [Tombstones](https://cassandra.apache.org/doc/latest/cassandra/managing/operating/compaction/tombstones.html). Una SSTable contiene varios componentes y una tabla puede tener varias SSTables. [Storage engine](https://cassandra.apache.org/doc/latest/cassandra/architecture/storage-engine.html).
- **Decisión:** tratar `LLTS` como errata probable, preservar el original y evitar prometer eliminación física inmediata en la siguiente compactación.

## Cassandra: contexto histórico y versión del entorno

- T16 combina fecha de proyecto top-level en 2010 con la frase “Proyecto apache en 2009”, incluye un ranking de mayo de 2021 y atribuye mantenimiento a DataStax en una frase que dice “hoy en día”. El PDF fue creado en 2024; no consta la fecha de cada fragmento. [T16, pp. 8, 10, 22]
- **Decisión:** no usar esas fechas como equivalentes ni el ranking/atribución empresarial como información actual. La incorporación no resuelve la cronología del proyecto; preserva el contenido con alcance histórico.
- T16 enumera `RandomPartitioner` y `OrderPreservingPartitioner`, pero no presenta la configuración predeterminada documentada para el motor de referencia. [T16, p. 60]
- **Complemento del agente (no consta en el material cargado):** la configuración documentada usa `Murmur3Partitioner`; conserva los anteriores por compatibilidad. [Configuración de Cassandra](https://cassandra.apache.org/doc/latest/cassandra/managing/configuration/cass_yaml_file.html).
- **Decisión:** no configurar un motor nuevo copiando el listado histórico; la versión real del laboratorio sigue sin fijarse.

## TP 10: preparación y vacíos

- P12 descarga `cassandra` sin etiqueta de versión. Para DataGrip menciona credenciales `cassandra/cassandra`, pero no configura autenticación. La alternativa que publica 9042 omite la red del primer `docker run`. [P12, p. 1]
- **Complemento del agente (no consta en el material cargado):** la configuración documentada predeterminada usa `AllowAllAuthenticator`, sin comprobación de contraseña; `PasswordAuthenticator` debe configurarse para autenticación por credenciales. [Configuración: authenticator](https://cassandra.apache.org/doc/latest/cassandra/managing/configuration/cass_yaml_file.html).
- **Decisión:** son variantes de instalación; no iniciar ambas con el mismo nombre. Registrar versión y autenticación al preparar el laboratorio. No se ejecutó Docker ni se creó un servidor durante la incorporación.
- La guía dice “no tendremos réplicas” con RF=1: T16 define RF como número de copias; interpretar una sola copia y ninguna redundancia adicional. La prosa llama `datos` a la columna que el DDL declara como `data blob`; los inserts no cargan el audio. [T16, p. 59; P12, pp. 1–2]
- P12 pide `now()` para IDs declarados `uuid`. **Complemento del agente (no consta en el material cargado):** `now()` genera `timeuuid`, mientras que `uuid()` genera UUID aleatorio; no sustituirlo silenciosamente ni usar una nueva llamada a `now()` para buscar el ID ya generado. [Funciones CQL](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/functions.html).
- **Vacíos:** la parte II se incorporó el 2026-10-13 como P13 y reutiliza la instalación de la parte I, sin fijar versión. C04 no incluye fórmulas de dimensionamiento del filtro; C05 no indica versión ni fecha. No inventar esa cobertura. [P13, p. 1]

## TP 10, parte II: supuestos de modelado

- P13 no trae solución ni resultados esperados: los ejercicios 1 y 2 son de diseño abierto y el 3 es de clasificación. Habla de “column families”, mientras la parte I las declara como tablas CQL; ver el [modelo histórico frente a CQL](#cassandra-modelo-histórico-de-columnas-frente-a-cql). [P13, pp. 1–2; P12, p. 1]
- El ejercicio 1 pide comentarios “en un rango de fechas, ordenados por fecha” sin acotarlos a una noticia ni a un usuario. El material exige especificar la partition key completa para dirigir una consulta y presenta el filtrado sin ella como rechazado o dependiente de `ALLOW FILTERING`. [P13, p. 1; T16, pp. 67–71]
- **Análisis del agente:** el enunciado no fija la granularidad de partición de esa consulta. Cualquier diseño debe explicitar ese supuesto y su efecto sobre los dos objetivos que la guía declara: distribuir datos y leer pocas particiones. [P13, p. 1]
- En el DER del ejercicio 2, revisado visualmente, `califica` tiene dos atributos rotulados “Fecha” y ninguno de puntaje; la consulta “qué producto calificó un usuario ‘X’ por fecha” no aclara si la fecha filtra u ordena. [P13, p. 2]
- Las consultas buscan por “nombre usuario” y “nombre producto”: `Usuario` tiene `nombre` sin indicar unicidad y `Producto` declara `título`, no nombre. `Categoría` y `pertenece` no intervienen en ninguna consulta. [P13, p. 2]
- **Decisión:** preservar el original y declarar los supuestos al resolver: equivalencia entre “nombre producto” y `título`, papel de cada fecha de `califica`, unicidad de nombres y títulos, y partición elegida para el rango de comentarios. No presentar un puntaje como si constara en el DER.
- **Resolución adoptada en el TP 10:** “nombre producto” es el título; nombres y títulos no son únicos, así que el id va en el clustering; `califica` tiene una sola fecha y ningún puntaje; los comentarios por rango se particionan por día. Ver la [resolución](../practica/tp-10/solucion.md).
- El ejercicio 3 coincide con la clasificación AP de T13; T16 afirma lo mismo y agrega que el nivel de consistencia es configurable incluso por consulta. Para el alcance de esa clasificación, ver [CAP](#cap-simplificación-elegir-dos-y-clasificación-de-motores). [P13, p. 2; T13, p. 18; T16, p. 11]

## Ejercicios tipo parcial (P14)

- **Neo4j: cobertura parcial.** P14 pide leer una consulta Cypher. Al incorporarse P14, el material solo nombraba Neo4j como ejemplo de base de grafos y de persistencia políglota. [P14, p. 4; T13, pp. 21–23; C01, p. 6] **Actualización 2026-11-06:** T17 enseña patrones, dirección, longitud variable (`[:FRIEND*..5]`) y amigos de amigos. [T17, pp. 9–13, 25–27] Siguen sin cubrirse el rango con mínimo (`*2..3`) y la negación de un patrón en `WHERE NOT`.
- **Mensajería: "a lo sumo 3 adjuntos".** No aclara si incluye los mensajes con **cero** adjuntos que cumplan las condiciones. Un `JOIN` con `HAVING COUNT(*) <= 3` los pierde. Además, `ADJUNTO.anio_creacion` es de tipo `date` pese a su nombre, y `tamanio` es `int` sin unidad declarada frente a "50 Mb". [P14, p. 1]
- **Mensajería: dos caminos entre mensaje y adjunto.** `CONTIENE` registra qué adjuntos tiene cada mensaje (n:m); las columnas `tipo_mensaje`/`cod_mensaje` de `ADJUNTO` registran solo el primer mensaje en que se incluyó. "Contienen" corresponde a `CONTIENE`. [P14, p. 1]
- **Películas: notación PostgreSQL.** La consulta califica las tablas con el esquema `unc_esq_peliculas.`; en el entorno MySQL del repositorio el esquema equivalente es la base `mydb` [SQL01]. [P14, p. 2]
- **Decisión:** resolver con los supuestos explícitos en el [espacio de práctica](../practica/parcial/README.md) y marcar como complemento solo lo de Neo4j que T17 no cubre.

## Posición de `NULL` al ordenar

- T05B afirma que, para `ORDER BY`, `NULL` es el "mayor". [T05B, p. 29]
- Es el comportamiento de PostgreSQL. En MySQL 9.7.2 es al revés: `NULL` se ordena como el **menor** valor y sale primero en orden ascendente. Verificado: `ORDER BY x` sobre `{1, NULL, 2}` devuelve `NULL, 1, 2`. *Complemento del agente (no consta en el material cargado).*
- **Decisión:** citar T05B para PostgreSQL y, al resolver en MySQL, no asumir la posición de los nulos: si importa, ordenar explícitamente, por ejemplo con `ORDER BY x IS NULL, x` para mandarlos al final.

## CAP de Neo4j, Redis y DynamoDB

Los TP 11, 12 y 13 piden clasificar cada motor según CAP, pero las fuentes no coinciden. [P15, p. 2; P16, p. 2; P17, p. 2]

| Motor | Gráfico de T13 | Otras fuentes del material |
|---|---|---|
| Neo4j | No figura. | **AP** para Neo4j HA: los slaves pueden estar desincronizados; consistencia eventual [T17, p. 40]. **CA** “porque no distribuye datos” [T19, p. 36]. En el clúster Raft no se confirman escrituras sin mayoría [C06, p. 9]. |
| Redis | **CP**. | **CA** por la misma razón [T19, p. 36]; **CP** en la guía visual [T20, p. 31]. |
| DynamoDB | **AP**. | Dynamo prioriza disponibilidad sobre consistencia [T20, p. 5]; la guía visual ubica en AP a *Dynamo*, no a DynamoDB [T20, p. 31]; ofrece lecturas fuertemente consistentes a mayor costo [T20, p. 23]. |

[T13, p. 18]

- El argumento “CA” de T19 supone una instalación no distribuida, y la propia T19 aclara que CAP tiene poco sentido en ese caso. Sin embargo, las mismas clases muestran réplicas, Sentinel y clústeres. [T19, pp. 27–29, 36; T18, pp. 15–16, 25–27; T17, pp. 36–39]
- **Análisis del agente:** en el clúster Raft de C06, una partición que deja a un lado sin mayoría impide escribir de ese lado. Eso privilegia la consistencia de las escrituras sobre la disponibilidad. Las lecturas en secundarios, en cambio, pueden estar atrasadas salvo que se usen bookmarks. [C06, pp. 9–10]
- **Complemento del agente (no consta en el material cargado):** Redis replica de forma asincrónica por defecto, así que una conmutación puede perder escrituras ya confirmadas por el maestro. En DynamoDB, las lecturas son eventualmente consistentes por defecto; tablas y LSI admiten lecturas fuertemente consistentes, pero los GSI solo eventuales. Véanse [replicación de Redis](https://redis.io/docs/latest/operate/oss_and_stack/management/replication/) y [consistencia de lectura en DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html).
- **Decisión:** al responder, citar la fuente elegida y declarar la arquitectura analizada. Para Neo4j: HA histórico (AP según T17), clúster Raft (C06) o instancia única (CA según T19). Para Redis y DynamoDB: partir del gráfico de T13, como en el TP 9 y el TP 10, y mencionar la alternativa de T19 o el matiz de las lecturas fuertes. Aplica la salvedad general de [CAP](#cap-simplificación-elegir-dos-y-clasificación-de-motores).

## Neo4j: versiones, sintaxis histórica y afirmaciones generales

- **Versiones mezcladas.** T17 combina la API REST y HA de Neo4j 3.4.9 [T17, pp. 32, 37], `db.schema()` de 3.5 [T17, p. 30], la instalación de Community 4.x con Java 11 [T17, pp. 19–20] y la versión estable 5.6 de marzo de 2023 [T17, p. 15]. El TP 11 usa la imagen `neo4j` sin etiqueta y advierte que algunos métodos del libro quedaron deprecados. [P15, p. 1]
- **Corrección visual de la restricción.** El texto extraído dice `CREATE CONSTRAINT FOR (p:Publication) REQUIRE p.name IS UNIQUE`, pero la página renderizada tacha `Publication` y lo corrige a mano por `Person`, que es lo que explica el error sobre Tom. Usar `Person`. [T17, p. 28; [figura](../material/figuras/T17-p28-restriccion-unicidad.png)]
- **Labels en relaciones.** T17 dice que los labels asignan roles o tipos a nodos y relaciones. [T17, p. 18] **Complemento del agente (no consta en el material cargado):** en Neo4j los nodos tienen labels, mientras cada relación tiene exactamente un *tipo*. Véase [conceptos de grafos](https://neo4j.com/docs/getting-started/appendix/graphdb-concepts/).
- **Complemento del agente (no consta en el material cargado):** la sintaxis vigente de parámetros es `$value`, no `{value}` [T17, pp. 10–11]. La función actual es `point.distance()`, no `distance()` [T17, p. 29]. El navegador acepta `:schema`, pero no es Cypher. Los clústeres actuales organizan cada base en primarios (con Raft) y secundarios para escalar lecturas, como C06, en lugar del master-slave HA de T17. La API REST `/db/data` es histórica; la interfaz HTTP actual es otra. Véanse [parámetros](https://neo4j.com/docs/cypher-manual/current/syntax/parameters/), [funciones espaciales](https://neo4j.com/docs/cypher-manual/current/functions/spatial/), [clústeres](https://neo4j.com/docs/operations-manual/current/clustering/introduction/) y [API HTTP](https://neo4j.com/docs/http-api/current/).
- **Afirmaciones generales.** “El rendimiento no desciende”, “los recorridos son de tiempo constante” y el límite de 34.000 millones de nodos aparecen sin versión ni carga de referencia. [T17, pp. 6–7, 39] **Análisis del agente:** el paso a un vecino es barato, pero una consulta que debe ubicar nodos de partida sin índice o recorrer gran parte del grafo no es de costo constante; por eso la misma clase crea índices. [T17, p. 28] No tomar el límite como vigente sin verificar la versión.
- El libro usa `:play movie-graph`; el TP 11 indica `:play movies`. [B01, p. 189; P15, p. 1]
- **Decisión:** estudiar los conceptos con T17 y C06 y escribir Cypher con la sintaxis vigente al practicar, marcando las adaptaciones. No reproducir el laboratorio HA ni la API REST como instalación actual.

## Redis: transacciones, persistencia y replicación

- **Atómica sin rollback.** T18 afirma que una transacción “es atómica (se procesan todos los comandos o ninguno)” y que no tiene rollback. [T18, pp. 12–13] T19 aclara que `DISCARD` no ejecuta, pero no revierte. [T19, p. 7] **Complemento del agente (no consta en el material cargado):** si un comando falla al encolarse (por ejemplo, por sintaxis), `EXEC` rechaza la transacción entera. Si falla al ejecutarse (por ejemplo, por tipo incorrecto), los demás se ejecutan igual y no se deshacen. Con `WATCH`, `EXEC` aborta si una clave observada cambió. Véase [transacciones](https://redis.io/docs/latest/develop/interact/transactions/).
- **Siglas y fsync.** T18 desarrolla AOF como “Append On File” y RDB como “Redis DataBase Backup”, y enumera las políticas de fsync como “ninguna, por segundos, cantidad de consultas”. [T18, pp. 17, 21] **Complemento del agente (no consta en el material cargado):** AOF es *Append Only File*; las políticas de `appendfsync` son `no`, `everysec` (por defecto) y `always` (en cada escritura). Véase [persistencia](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/).
- **“Redis Cluster” del libro.** T19 llama así a un reparto de claves por hashing consistente del cliente Ruby y dice que se probó “con un master y un slave”. Luego verifica la misma clave en ambas instancias. [T19, p. 31] El libro configura los dos servidores como maestros. [B01, p. 283] **Análisis del agente:** con hashing consistente, cada clave va a una sola instancia; y una réplica configurada como en T19, p. 28, solo acepta lecturas. [T19, p. 29] El particionado automático de Redis Cluster se menciona, pero no se practica. [T19, pp. 4, 17]
- **Debilidades históricas.** T19 dice que Redis Cluster “está en desarrollo”. [T19, p. 35] **Complemento del agente (no consta en el material cargado):** Redis Cluster ya es parte del producto; véase [escalado con Redis Cluster](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/).
- **Erratas menores.** El texto anuncia el intervalo `(9..10000]`, pero el comando usa `(9 9999` y por eso excluye a `prag`. `MOVE` aparece devolviendo `(integer) 2`, pero devuelve 1 si mueve la clave. [T19, pp. 15, 18] Véase [MOVE](https://redis.io/docs/latest/commands/move/).
- **Decisión:** explicar la transacción Redis como aislamiento y ejecución en bloque, sin vuelta atrás ante errores de ejecución. Usar los nombres oficiales al configurar persistencia.

## Redis: versiones, licencia y seguridad

- **Versiones.** T19 cita la versión estable 7.0.11, un `INFO` de la 5.0.0 y el cambio de `SLAVEOF` a `REPLICAOF` en la 5. El TP 12 usa la imagen `redis` sin etiqueta y habla de “Redis Open Source”. [T19, pp. 1, 22, 28; P16, p. 1]
- **Licencia.** T18 indica licencia BSD. [T18, p. 9] **Complemento del agente (no consta en el material cargado):** las versiones actuales se distribuyen bajo RSALv2, SSPLv1 o AGPLv3. Véase [licencias de Redis](https://redis.io/legal/licenses/).
- **AUTH.** T18 recomienda `AUTH` y una capa de ACL en la aplicación. [T18, pp. 29–30] T19, siguiendo al libro, considera ignorables `requirepass`/`AUTH` y prefiere firewall y SSH. [T19, p. 25] **Complemento del agente (no consta en el material cargado):** Redis tiene hoy ACL propias, con usuarios y permisos por comando. Véase [ACL](https://redis.io/docs/latest/operate/oss_and_stack/management/security/acl/).
- **`rename-command`.** T19 lo muestra escrito en el prompt de `redis-cli`. [T19, pp. 25–26] **Complemento del agente (no consta en el material cargado):** es una directiva de `redis.conf`, no un comando de la sesión. Véase [seguridad](https://redis.io/docs/latest/operate/oss_and_stack/management/security/).
- **Comandos deprecados.** **Complemento del agente (no consta en el material cargado):** `HMSET` está deprecado desde 4.0 (se usa `HSET` con varios pares), y `ZRANGEBYSCORE` desde 6.2 (se usa `ZRANGE ... BYSCORE`); ambos siguen funcionando. `KEYS` recorre todo el espacio de claves y no se recomienda en producción. Véanse [HMSET](https://redis.io/docs/latest/commands/hmset/), [ZRANGEBYSCORE](https://redis.io/docs/latest/commands/zrangebyscore/) y [KEYS](https://redis.io/docs/latest/commands/keys/). [T19, pp. 8–9, 15; P18A]
- **Bloom filters.** T19 dice que el tipo no viene por defecto y se agrega como módulo desde 4.0. [T19, pp. 32–33] **Complemento del agente (no consta en el material cargado):** la documentación actual presenta el Bloom filter como tipo de Redis Open Source; véase [Bloom filter](https://redis.io/docs/latest/develop/data-types/probabilistic/bloom-filter/). El TP 12 pide igualmente la implementación del libro con `SETBIT`/`GETBIT`. [P16, p. 2]
- **Decisión:** citar el material para conceptos y practicar con la sintaxis vigente, señalando el reemplazo cuando se use un comando deprecado.

## Ejercicio Redis: enunciado y solución

- P18 es el enunciado con huecos; P18A lo completa y comenta las respuestas. [P18; P18A]
- El punto 2 pide la lista `L_Cantantes`, pero P18 y P18A usan la clave `cantantes`. [P18; P18A]
- En P18A, `libro5` (*La chica del tren*) repite el ISBN `9788466332286` de `libro3`. [P18A]
- Tras `DEL pelicula3`, el comentario de `EXISTS pelicula3` dice “Si no existe se borrará”; **análisis del agente:** debe leerse como “devuelve 0 porque se borró”. [P18A]
- P18A comenta que `ZADD` “devuelve el número de elementos del conjunto ordenado”. **Complemento del agente (no consta en el material cargado):** devuelve cuántos miembros nuevos agregó; coincide con el total solo porque el conjunto estaba vacío. Véase [ZADD](https://redis.io/docs/latest/commands/zadd/).
- **Decisión:** usar P18A como referencia de cátedra y aclarar estas diferencias al practicar.

## DynamoDB: claves, índices y cambios de versión

- **Rótulos de claves.** T20 aclara que “PK” significa partition key, no primary key. [T20, p. 10] En la [figura LSI](../material/figuras/T20-p18-ejemplo-lsi.png), una llave rotulada “Partition key” abarca `Username` (hash key) y `Date` (range key). **Análisis del agente:** la partition key es solo `Username`; ambos atributos juntos forman la clave primaria compuesta. [T20, pp. 14, 18]
- **Operadores de la sort key.** La figura del modelo lista “contains” e “in” entre las consultas habilitadas por la sort key. [T20, p. 6] **Complemento del agente (no consta en el material cargado):** una condición de clave sobre la sort key admite `=`, `<`, `<=`, `>`, `>=`, `BETWEEN` y `begins_with`; otras condiciones se aplican como filtro después de leer. Véase [condiciones de clave](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.KeyConditionExpressions.html).
- **Consultas sobre índices.** Las consultas LSI y GSI de T20 omiten el índice, igual que el libro, y proyectan `Date`. [T20, pp. 18–19; B01, pp. 230–231] **Complemento del agente (no consta en el material cargado):** una consulta sobre un índice requiere `--index-name`, y `Date` es palabra reservada, por lo que debe reemplazarse con `--expression-attribute-names`. Véanse [Query](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html) y [palabras reservadas](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ReservedWords.html).
- **Cadenas vacías.** T20 advierte “No Empty Strings”. [T20, p. 11] **Complemento del agente (no consta en el material cargado):** hoy un atributo puede tener una cadena o binario vacío si no forma parte de una clave de tabla o índice. Véase [tipos de datos](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html).
- **Atomicidad entre ítems.** T20 afirma que no hay operaciones atómicas entre ítems. [T20, p. 6] **Complemento del agente (no consta en el material cargado):** DynamoDB ofrece transacciones sobre varios ítems, y la capacidad puede ser aprovisionada o bajo demanda. Véanse [transacciones](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/transactions.html) y [modos de capacidad](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/capacity-mode.html).
- **Decisión:** estudiar el modelo con T20 y, al ejecutar comandos, agregar los parámetros que exige la CLI vigente, marcándolos como adaptación.

## TP 11, 12 y 13: preparación, bibliografía y vacíos

- **Entornos.** Las guías usan imágenes sin versión (`neo4j`, `redis`, `amazon/dynamodb-local`). Neo4j corre con `NEO4J_AUTH=none`, y el comando de Redis no configura contraseña. [P15, p. 1; P16, p. 1; P17, p. 1] El repositorio no agregó estos servicios a `compose.yaml` ni ejecutó las guías.
- **DynamoDB Local.** T20 lo inicia con `-sharedDb`; el contenedor del TP 13 no lo indica, y su `aws configure` usa credenciales ficticias. [T20, p. 7; P17, p. 1] **Complemento del agente (no consta en el material cargado):** sin `-sharedDb`, DynamoDB Local guarda un archivo por clave de acceso y región; si cambia `aws configure`, las tablas creadas antes no se ven. Véanse las [notas de uso](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.UsageNotes.html).
- **Páginas del libro.** Los TP citan páginas impresas de B01. En el PDF local, la página impresa N está en N + 11 (capítulo 6, Neo4j), N + 10 (capítulo 7, DynamoDB) y N + 9 (capítulo 8, Redis); el capítulo 4 usaba N + 13. [B01, pp. 181, 218, 261]
- **Servicios externos.** El TP 11 usa el Sandbox de Neo4j con los Paradise Papers, y T20 recorre Kinesis, Lambda, S3 y Athena. No se verificó su disponibilidad, y DynamoDB Local no los reemplaza; el TP 13 no los pide. [P15, p. 2; T20, pp. 23–30; P17, p. 2]
- **Vacíos.** El TP 12 pide la posición de una película según el score, pero el material no presenta un comando para obtener la posición de un miembro. [P16, p. 2; T19, pp. 14–16] El TP 13 remite a una fórmula de particiones que el material no incluye. [P17, p. 2; B01, p. 232] No se recibió una “Clase 19”: la numeración salta de la 18 a la 20.
- **Decisión:** al resolver, fijar y registrar versiones de imagen, adaptar sintaxis histórica y marcar como complemento lo que salga de la documentación oficial.

## TPO FarmaRed: vacíos de la consigna y de los datos

- **Integrantes.** La portada pide grupos de 4 integrantes, pero los entregables piden commits de “los tres integrantes”. [P19, pp. 1, 7] **Decisión:** prevalece la modalidad de la portada; confirmar con la cátedra y exigir commits de todos los integrantes.
- **Receta sin productos.** La regla de condición de venta exige una receta vigente del mismo cliente, pero `recetas.csv` no indica qué productos se prescriben, y una receta cubre varios productos en una misma venta (V006 y V007 dispensan PRD005 y PRD009 con RC003). [P19, pp. 3, 5; P19G; P19I] **Decisión:** la consulta 14 solo puede validar cliente, existencia y estado de la receta; no inventar una relación receta–producto sin confirmarla.
- **Unidad de dispensa.** No está definido si una venta con varios productos bajo receta cuenta como una dispensa o como una por ítem. Los datos cuentan una por venta: `dispensas_realizadas` coincide con las ventas “Completada” de cada receta. [P19, p. 5; P19G; P19H]
- **30 días frente a RC002.** La regla fija la próxima dispensa 30 días después de la última. RC003 y RC004 la cumplen, pero RC002 tiene `2026-09-15` cuando su última dispensa (V005) fue el `2026-08-15`; con 30 días daría `2026-09-14`. [P19, p. 5; P19G; P19H] **Decisión:** aplicar la regla escrita en los servicios y cargar el CSV tal como viene.
- **Vencimiento de recetas.** Existe el estado “Vencida” (RC009), pero la consigna no da un plazo de validez ni una regla de transición. [P19, p. 3; P19G] **Decisión:** tratar el estado como un dato almacenado; no calcular vencimientos por fecha sin una regla de la cátedra.
- **“Ventas registradas” en la consulta 12.** No se aclara si una venta “Pendiente” o “Anulada” cuenta como venta registrada. La consulta 5 sí aclara explícitamente que excluye anuladas. [P19, p. 6] **Decisión:** documentar el criterio en el informe.
- **Fecha de referencia.** Los datos se describen respecto del 13/10/2026, pero las consultas deben usar la fecha del sistema. [P19, pp. 2, 6] Por eso, los resultados de las consultas 5, 6, 11 y 12 sobre los datos provistos cambian según el día en que se ejecuten. Los registros propios exigidos por la consigna tienen que cubrir el período actual.
