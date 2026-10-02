# Cassandra: almacenamiento y Bloom filters

## Escritura local y persistencia

El recorrido de una escritura distingue commit log, memtable y SSTable. El log registra las escrituras para recuperación; la memtable las conserva temporalmente en memoria; el flush vuelca su contenido a SSTables en disco antes de liberar esa memoria. El [diagrama local](../../material/figuras/T16-p31-escritura-local.png) se revisó junto con las explicaciones. [T16, pp. 30–33]

Las SSTables son inmutables: una actualización no reescribe el archivo anterior. Por eso una misma partición puede tener datos en varias SSTables y su lectura puede requerir combinar información de varios archivos. La compactación reduce la cantidad de SSTables y trata datos antiguos para mejorar las lecturas. [T16, pp. 33–34, 40]

**Complemento del agente (no consta en el material cargado):** el commit log es el WAL de este motor. La confirmación y el momento del `fsync` dependen de `commitlog_sync`; una escritura reconocida no implica universalmente sincronización inmediata en disco. La documentación también describe varias causas de flush y varios componentes por SSTable; no interpretar la familia de columnas como un único fichero. [Apache Cassandra: storage engine](https://cassandra.apache.org/doc/latest/cassandra/architecture/storage-engine.html). Comparar con [Recovery y WAL](14-recovery-y-wal.md).

## Borrados, tombstones y expiración

Como las SSTables son inmutables, un borrado escribe una marca de eliminación o **tombstone**. El material relaciona su eliminación posterior con compactación y un período de gracia: una réplica caída necesita recibir el borrado para evitar inconsistencias. También presenta una fecha de caducidad para datos y recomienda mantenimiento/repair. [T16, pp. 38–39, 47]

**Complemento del agente (no consta en el material cargado):** el vencimiento de un TTL genera tombstones. Superar `gc_grace_seconds` no provoca por sí solo un borrado físico inmediato: la purga depende de las condiciones de compactación. Una réplica que conserva valores viejos puede reintroducirlos si se descarta demasiado pronto la marca de borrado. [Apache Cassandra: tombstones](https://cassandra.apache.org/doc/latest/cassandra/managing/operating/compaction/tombstones.html). La abreviatura `LLTS` de T16, p. 39, queda registrada como errata probable, sin modificar el original.

## Para qué sirve un Bloom filter

C04 plantea una lectura por partition key que podría involucrar varias SSTables. El filtro permite descartar rápidamente aquellas donde la clave no está; no encuentra ni devuelve el dato. Si responde que la clave puede estar, todavía hay que comprobar la SSTable. Esta presentación precisa la descripción de T16, que lo llama un tipo de caché. [C04, pp. 1–2, 6–8; T16, p. 30]

## Vector de bits y hashes

El filtro contiene un vector de bits y varias funciones hash. Al insertar una clave se ponen en 1 las posiciones elegidas por sus hashes. El [ejemplo Juan](../../material/figuras/C04-p4-insertar-juan.png) utiliza un vector de diez bits y las posiciones 2, 5 y 8. [C04, pp. 3–4]

Para consultar Pedro, el [ejemplo visual](../../material/figuras/C04-p5-consultar-pedro.png) comprueba posiciones 2, 4 y 8. Como el bit 4 es 0, Pedro definitivamente no fue agregado. Si todos los bits consultados fueran 1, otras claves podrían haberlos activado: la respuesta sería solo “puede estar”. [C04, pp. 5–6]

| Respuesta del filtro | Clave realmente presente | Interpretación |
|---|---|---|
| No está | No | Descartar la SSTable. |
| No está | Sí | Falso negativo; imposible en el funcionamiento presentado. |
| Puede estar | Sí | Comprobar y encontrar la clave. |
| Puede estar | No | Falso positivo; la comprobación descarta la coincidencia. |

La [tabla de casos](../../material/figuras/C04-p6-falso-positivo.png) se revisó visualmente. Un falso positivo agrega una búsqueda innecesaria; un falso negativo descartaría una SSTable necesaria. Esa asimetría explica por qué el primero es aceptable y el segundo no. La última frase es una conclusión del agente a partir del mecanismo explicado, no una respuesta textual de la diapositiva. [C04, pp. 5–8]

## Uso en Cassandra

En el [recorrido de cinco SSTables](../../material/figuras/C04-p7-descartar-sstables.png), el filtro descarta 1, 2 y 4; se comprueban 3 y 5. La unidad resume el compromiso: más memoria para el filtro reduce falsos positivos y búsquedas innecesarias. No presenta fórmulas de dimensionamiento ni un ejemplo de borrado de bits; no inferirlos de los dibujos. [C04, p. 7]

El Bloom filter opera dentro de la lectura local sobre SSTables. **DIGEST** compara resultados de réplicas en una lectura distribuida; se estudia en [consistencia y DIGEST](22-cassandra-consistencia-y-digest.md). Ambos usan hashes, con propósitos diferentes. [C04, pp. 2–7; T16, pp. 41–43; C05]
