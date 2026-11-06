# Amazon DynamoDB

## Qué es

DynamoDB es un servicio de base de datos NoSQL de Amazon, totalmente administrado y en la nube, con rendimiento rápido y predecible y escalabilidad. Distribuye automáticamente datos y tráfico entre servidores según la capacidad solicitada y el volumen almacenado. Es propietario, admite estructuras clave-valor y documentos, y se anunció el 18 de enero de 2012 como evolución de SimpleDB. Toma el nombre y un modelo similar de Dynamo, aunque su implementación es otra. [T20, pp. 2, 4]

La clase lo define como *cloud key/value store* con un modelo “key-value plus”. DB-Engines lo ubica segundo tanto entre los clave-valor (detrás de Redis) como entre los documentales (detrás de MongoDB). [T20, pp. 2–3]

- Una tabla admite cualquier cantidad de ítems, y cada ítem, cualquier cantidad de atributos, con un límite de **400 KB por ítem**.
- Los datos se guardan en SSD y se replican automáticamente en varias zonas de disponibilidad de una región.
- Es un servicio pago, con una capa gratuita para probar.

[T20, pp. 4, 6, 11]

**Dynamo (2007).** En 2004 Amazon empezaba a chocar con los límites de escala de su base Oracle. El *paper* de Dynamo resume tres aspectos: sin modelo relacional, **disponibilidad por sobre consistencia** y escalabilidad “infinita”. [T20, p. 5]

## Tablas, ítems y claves

| SQL | DynamoDB |
|---|---|
| Tablas | Tablas |
| Filas | Ítems |
| Columnas | Atributos |
| Primary key (puede tener varias columnas) | Primary key: partition key y sort key opcional |
| Índices | Local Secondary Indexes: misma partition key, otra sort key |
| Vistas | Global Secondary Indexes: otra partition key y una sort key |

La [tabla comparativa](../../material/figuras/T20-p19-sql-vs-dynamodb.png) se revisó visualmente. [T20, pp. 5, 19]

En el [modelo de tabla](../../material/figuras/T20-p6-modelo-tabla.png):

- La **partition key** es obligatoria: define el patrón de acceso clave-valor y determina la distribución de los datos.
- La **sort key** es opcional: modela relaciones 1:N y habilita consultas más ricas sobre los ítems de una clave, como comparaciones, “begins with”, “between”, resultados ordenados, conteos y los N primeros o últimos.

[T20, p. 6] La diapositiva lista además “contains” e “in”; ver la [salvedad](../dudas-y-conflictos.md#dynamodb-claves-índices-y-cambios-de-versión).

En la CLI, la partition key se declara como `HASH` y la sort key como `RANGE`; la clase advierte que “PK” no significa primary key. [T20, p. 10] La hash key es la clave de acceso y de partición; la range key se usa para búsquedas ordenadas. [T20, p. 14] Con esto se distinguen dos formas de clave:

| Tabla del ejemplo | Clave | Forma |
|---|---|---|
| `ShoppingCart` | `ItemName` (HASH) | Simple: solo partition key. |
| `MusicCollection` | `Artist` (HASH) + `SongTitle` (RANGE) | Compuesta. |
| `Books` | `Title` (HASH) + `PublishYear` (RANGE) | Compuesta: un mismo título con varias ediciones. |

[T20, pp. 9, 14] El TP 13 pide comparar ambas formas. [P17, p. 2]

## Tipos de datos y JSON tipado

La [tabla de tipos](../../material/figuras/T20-p11-tipos-de-datos.png) incluye escalares `S` (string), `N` (number, enviado como cadena por compatibilidad), `B` (binario en Base64), `BOOL` y `NULL`; conjuntos `SS`, `NS` y `BS`; y documentos `L` (lista de valores de cualquier tipo) y `M` (mapa). Lleva la advertencia “No Empty Strings”. [T20, p. 11] Ver [dudas](../dudas-y-conflictos.md#dynamodb-claves-índices-y-cambios-de-versión) sobre esa restricción.

Cada valor del JSON de DynamoDB lleva su tipo:

```json
{ "url": { "S": "https://aws.amazon.com/es/dynamodb/" } }
```

[T20, p. 12] Al crear la tabla solo se declaran los atributos de la clave. Los ítems pueden traer otros (como `ISBN` o `Note`), y una proyección de un atributo ausente devuelve `{}` para ese ítem. La clase invita a discutir si eso es “schema-free” y cómo difiere del JSON sin tipos de MongoDB. [T20, pp. 16–17]

## Operaciones con la CLI

DynamoDB Local permite trabajar sin AWS: se ejecuta con Java (`-sharedDb`, puerto 8000) y exige credenciales cualesquiera y una región configuradas con `aws configure`. Cada comando lleva `--endpoint-url http://localhost:8000`. [T20, pp. 7–8; P17, p. 1]

| Operación | Comando | Equivalente orientativo |
|---|---|---|
| Crear tabla | `create-table --attribute-definitions ... --key-schema ... --provisioned-throughput ...` | `CREATE TABLE` |
| Ver estado | `describe-table` (`CREATING` → `ACTIVE`) | — |
| Listar | `list-tables` | — |
| Insertar | `put-item --item '{...}'` o `--item file://item1.json` | `INSERT` |
| Leer todo | `scan` | `SELECT *` |
| Contar | `scan --select "COUNT"` | `SELECT COUNT(*)` |
| Leer por clave | `get-item --key '{...}'` | — |
| Borrar | `delete-item --key '{...}'` | `DELETE` |

[T20, pp. 8–14] Si el JSON en línea da error, la clase propone pasarlo en un archivo con `file://`. [T20, pp. 12–14]

**Query.** La consulta por clave usa una condición sobre la partition key y, opcionalmente, la sort key, con los valores aparte:

```bash
aws dynamodb query --table-name Books \
  --expression-attribute-values '{ ":title": {"S": "Moby Dick"}, ":year": {"N": "1980"} }' \
  --key-condition-expression 'Title = :title AND PublishYear > :year' \
  --endpoint-url http://localhost:8000
```

Devuelve la edición de 2008. `--projection-expression 'ISBN'` limita los atributos devueltos. [T20, pp. 15–16]

## Índices secundarios

- **Local (LSI):** permite consultar y escanear atributos fuera de la clave primaria, con la misma partition key y otra sort key. No se puede modificar después de crear la tabla. [T20, pp. 17–19]
- **Global (GSI):** no se restringe a ítems con la misma partition key; “global” significa “cualquier atributo de la tabla”. Se puede modificar después de creada la tabla. [T20, pp. 18–19]

En el [ejemplo LSI](../../material/figuras/T20-p18-ejemplo-lsi.png), la tabla de puntajes tiene `Username` como hash key, `Date` como range key, un LSI sobre `High score` y `Avatar` sin índice. La consulta busca las fechas en que un usuario superó 800 puntos. La consulta GSI busca por `Avatar = Lion` y proyecta usuario y fecha. [T20, pp. 18–19] El [ejemplo de GSI y su costo](../../material/figuras/T20-p20-ejemplo-gsi.png) muestra que cada GSI suma almacenamiento y unidades de lectura y escritura aprovisionadas a la factura. [T20, p. 20]

Las consultas de la clase omiten detalles que la CLI exige; ver [dudas](../dudas-y-conflictos.md#dynamodb-claves-índices-y-cambios-de-versión). El TP 13 pide comparar LSI y GSI. [P17, p. 2]

## Capacidad y consistencia

- Las **RCU** se miden en unidades de 4 KB por segundo y las **WCU** en unidades de 1 KB por segundo: “1 = 4 para las lecturas, 1 = 1 para las escrituras”.
- Las lecturas fuertemente consistentes cuestan alrededor del doble que las eventualmente consistentes.
- La capacidad de una tabla puede actualizarse: se puede empezar con RCU=1 y WCU=1 y ajustar.

[T20, pp. 22–23] DynamoDB ofrece consistencia **a nivel de ítem**, análoga a la de fila en un RDBMS. Según la clase, no hay operaciones atómicas entre ítems ni consistencia en operaciones por lotes, y las consultas sobre índices o tablas completas pueden no estar actualizadas. Si se necesita consistencia entre ítems, conviene otro motor. [T20, p. 6] Ver la salvedad de versión en [dudas](../dudas-y-conflictos.md#dynamodb-claves-índices-y-cambios-de-versión).

## Pipeline de datos de sensores

- **Tabla.** `SensorData` usa `SensorId` (HASH) y `CurrentTime` (RANGE, número en tiempo Unix), con un LSI `TemperatureIndex` sobre `SensorId` y `Temperature` y proyección `ALL`. [T20, pp. 20–22]
- **Ingesta.** Los datos pasan de Kinesis a una función Lambda que decodifica el payload en Base64 y hace `putItem`. Se prueba con `aws kinesis put-record` y un `scan`; ver el [diagrama del pipeline](../../material/figuras/T20-p29-pipeline-athena.png). [T20, pp. 23–26, 29]
- **Carga.** Scripts Ruby simulan 10 sensores con 1000 muestras cada uno, y `scan --query Count` cuenta los ítems. [T20, p. 28]
- **Consulta SQL.** Data Pipeline vuelca la tabla en S3 y Athena la consulta con una tabla externa sobre JSON. Las [consultas de ejemplo](../../material/figuras/T20-p30-consultas-athena.png) listan sensores y calculan conteos, promedio, máximo y desvío de temperatura. El libro sugiere dividir los datos por día. [T20, pp. 28–30]

La tarea pide explorar una biblioteca cliente; la clase recorre boto3 en Python: crear tabla, cargar datos, CRUD, query/scan y borrado. [T20, pp. 26–27]

## Fortalezas, debilidades y CAP

| Fortalezas | Debilidades |
|---|---|
| Se empieza a construir sin instalar ni configurar nada. | Aprovisionar capacidad, planificar índices y modelar es complicado. |
| Pocos límites intrínsecos de crecimiento, si hay presupuesto. | Salvo un problema “con forma de DynamoDB”, probablemente convenga PostgreSQL u otra relacional. |
| Índices y consultas por rango poco comunes en NoSQL. | Puede costar adaptar el modelo al sistema de particionado. |
| Los servicios de AWS cubren faltantes, como SQL con Athena. | El costo, y la confianza en un sistema cuyo interior no se ve. |

[T20, pp. 32–33] El libro cierra con alternativas en la nube: BigQuery y Redshift si se busca SQL, y Spanner, CockroachDB o FaunaDB para bases distribuidas globalmente. El *bonus track* remite al *single-table design* de Alex DeBrie. [T20, pp. 33–34] El TP 13 pide resumir fortalezas y debilidades. [P17, p. 2]

El TP 13 también pide clasificarlo según CAP. [P17, p. 2] El gráfico de T13 ubica DynamoDB en **AP**. T20 recoge la prioridad de Dynamo por la disponibilidad, aunque también ofrece lecturas fuertemente consistentes. Su [guía visual](../../material/figuras/T20-p31-guia-visual-cap.png) ubica en AP a **Dynamo**, no a DynamoDB. Ver [CAP en dudas](../dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb). [T13, p. 18; T20, pp. 5, 23, 31]
