# Glosario

| Término | Definición breve | Fuente |
|---|---|---|
| Atributo | Propiedad de una entidad o relación, definida sobre un dominio. | [T02, p. 14] |
| Atributo compuesto | Atributo descomponible en componentes con significado propio. | [T02, p. 16] |
| Atributo derivado | Valor calculado a partir de otros datos. | [T02, p. 17] |
| Atributo multivaluado | Puede tomar varios valores para una misma instancia. | [T02, p. 15] |
| Acción referencial | Respuesta asociada a una FK cuando se modifica o borra una clave referenciada, como rechazo, cascada o puesta a nulo. | [T09, pp. 9–11] |
| ARIES | Esquema de recuperación organizado en análisis, redo y undo. | [T12, p. 6] |
| Atomicidad | Propiedad por la cual una transacción se completa íntegramente o se deshace. | [T11, p. 16] |
| Autenticación | Proceso de identificar una cuenta antes de permitirle acceso. | [T11, p. 5] |
| Autorización | Determinación de los recursos y operaciones permitidos para un usuario o grupo. | [T11, p. 5] |
| Baja lógica | Marcar una entidad como inactiva en lugar de eliminarla físicamente. | [P19, p. 5] |
| Cardinalidad máxima | Máximo de instancias que pueden asociarse por una relación. | [T02, p. 27] |
| Cardinalidad mínima | Mínimo de instancias asociadas; 0 expresa opcionalidad y 1 obligatoriedad. | [T02, pp. 27, 33] |
| Clave extranjera (FK) | Columnas que referencian una clave de otra tabla. | [T03, p. 4] |
| Clave primaria (PK) | Clave elegida para identificar unívocamente las filas. | [T03, pp. 4, 7] |
| `CHECK` | Restricción declarativa cuya condición debe resultar verdadera o desconocida para aceptar una fila. | [T09, pp. 17, 20] |
| Checkpoint | Punto que acota el tramo del log que debe revisarse durante recovery. | [T12, p. 6] |
| Costo estimado | Magnitud calculada por el optimizador para comparar planes; no equivale directamente a milisegundos. | [T08, pp. 2, 5, 9] |
| DDL/LDD | Lenguaje para definir esquemas y restricciones. | [T01, p. 8] |
| DML/LMD | Lenguaje para consultar o manipular datos. | [T01, p. 8; T04, p. 8] |
| Durabilidad | Propiedad por la cual una transacción confirmada persiste frente a fallos posteriores. | [T11, p. 17] |
| Dominio | Conjunto de valores admisibles para un atributo. | [T02, p. 14] |
| Entidad | Objeto real o abstracto sobre el que se guarda información. | [T02, pp. 8, 10] |
| Entidad débil | Su existencia e identificación dependen de una entidad fuerte. | [T02, p. 12] |
| Esquema | Diseño general de una base de datos. | [T01, p. 8] |
| FEFO | First Expired, First Out: consumir primero los lotes con vencimiento más próximo. | [P19, p. 5] |
| Grado de relación | Cantidad de tipos de entidad que participan. | [T02, pp. 23–24] |
| Identificador alternativo | Otro atributo o conjunto capaz de identificar unívocamente. | [T02, p. 16] |
| Identificador principal | Atributo o conjunto elegido para identificar cada instancia. | [T02, pp. 16, 19] |
| Integridad referencial | Restricción que exige que una FK apunte a una clave válida. | [T03, p. 4] |
| Integridad, restricción de | Condición que caracteriza estados o transiciones válidos de la base de datos. | [T09, pp. 2–5] |
| Join interno | Combinación que conserva parejas que cumplen su condición. | [T05B, pp. 6–7] |
| Join externo | Combinación que también conserva filas sin pareja y completa con `NULL`. | [T05B, p. 31] |
| Modelo de datos | Herramientas conceptuales para describir datos, relaciones, semántica y restricciones. | [T01, p. 7] |
| `MATCH` | Regla que determina cómo se tratan nulos en una clave extranjera compuesta. | [T09, pp. 12–14] |
| `NULL` | Ausencia de valor; no equivale a cero ni cadena vacía. | [T05A, p. 15; T05B, p. 24] |
| Persistencia políglota | Uso conjunto de tecnologías de datos según la necesidad. | [C01, p. 5] |
| Lectura fantasma | Cambio en el conjunto de filas que satisface una consulta por inserciones o borrados concurrentes. | [T11, p. 24] |
| Lectura no repetible | Cambio del valor observado al volver a leer una fila dentro de la misma transacción. | [T11, p. 24] |
| Lectura sucia | Lectura de cambios de otra transacción todavía no confirmada. | [T11, p. 23] |
| LSN | Identificador creciente de un registro del log. | [T12, p. 5] |
| Plan de ejecución | Árbol de operaciones elegido por el optimizador para resolver una sentencia. | [T08, pp. 2–5] |
| Preservación de clave | Propiedad estructural por la cual cada fila de una tabla aparece a lo sumo una vez en una vista, permitiendo identificar la tabla actualizable. | [T06, p. 11; T07, pp. 4–8] |
| Relación conceptual | Asociación entre instancias de entidades. | [T02, p. 21] |
| Relación/tablas | En el modelo relacional, conjunto de tuplas representable como tabla. | [T03, p. 4] |
| Redo | Reaplicación durante recovery de cambios que ya estaban registrados en el log. | [T12, pp. 6, 11] |
| Rol | Cuenta nominal que agrupa privilegios y puede concederse a usuarios. | [T11, p. 11] |
| SGBD/DBMS | Datos interrelacionados y programas para acceder y gestionarlos. | [T01, p. 3] |
| Subconsulta correlacionada | Subconsulta que depende de valores de la fila externa. | [T05B, pp. 17–18] |
| Transacción | Unidad lógica de procesamiento delimitada por inicio y finalización. | [T11, p. 14] |
| Trigger | Código persistente que se activa automáticamente ante un evento de la base de datos. | [T09, p. 26; T10, p. 3] |
| Tupla | Instancia/fila de una relación. | [T02, p. 3; T03, p. 4] |
| Undo | Deshacer los cambios de transacciones que no llegaron a confirmar. | [T12, pp. 6, 10–11] |
| Vista | Relación derivada definida por una consulta; habitualmente es una tabla virtual no materializada. | [T06, p. 3] |
| Vista actualizable | Vista cuyo DML puede traducirse sin ambigüedad a operaciones sobre sus relaciones subyacentes. | [T06, pp. 10–12] |
| Vista materializada | Resultado de una consulta precalculado y almacenado, que debe mantenerse consistente con sus tablas base. | [T07, p. 17] |
| `WITH CHECK OPTION` | Opción que rechaza cambios cuyo resultado no satisface el predicado controlado por la vista. | [T06, p. 15] |
| WAL | Regla de logging que exige persistir el registro de un cambio antes que la página modificada. | [T12, p. 4] |

## NoSQL y MongoDB

| Término | Definición breve | Fuente |
|---|---|---|
| BASE | Disponibilidad básica, estado flexible y consistencia eventual. | [T13, pp. 19–20] |
| BSON | Formato binario de documentos usado por MongoDB. | [T13, p. 29; T15, p. 6] |
| CAP | Compromiso entre consistencia, disponibilidad y tolerancia a particiones; el material lo presenta mediante CP, AP y CA. | [T13, pp. 12–18] |
| Colección | Agrupación de documentos cuyos campos pueden diferir. | [T13, p. 26; T15, p. 23] |
| Consistencia eventual | Admisión de estados transitorios no consistentes, con convergencia posterior según la explicación de BASE. | [T13, p. 20] |
| Documento embebido | Documento relacionado almacenado dentro del principal. | [T14, pp. 3–5] |
| Escalabilidad horizontal | Aumento de capacidad agregando servidores, según el contraste visual de la unidad. | [T13, p. 9] |
| Escalabilidad vertical | Aumento de recursos de un servidor, según el contraste visual de la unidad. | [T13, p. 9] |
| `_id` | Identificador único del documento; puede ser provisto o generado como ObjectId. | [T15, pp. 8–9; P10A, p. 2] |
| `$lookup` | Etapa de ensamble entre colecciones que incorpora las coincidencias en un arreglo. | [T13, pp. 48–49; T14, pp. 22–24] |
| MapReduce | Procesamiento que emite pares clave–valor y combina los valores de cada clave. | [T15, pp. 35–37; C03, pp. 1–2] |
| `mongod` | Proceso núcleo de la base de datos MongoDB en la arquitectura presentada. | [T13, p. 31; T15, p. 41] |
| `mongos` | Router de consultas de un cluster fragmentado. | [C02, p. 1] |
| Referencia documental | Vínculo entre documentos mediante valores identificadores. | [T14, pp. 7, 18–20] |
| Replica set | Conjunto de copias con primario y secundarios orientado a disponibilidad y failover. | [C02, p. 1; T15, pp. 41–43] |
| Shard | Servidor que conserva una parte de los datos fragmentados. | [C02, p. 1] |
| Shard key | Clave usada para distribuir datos entre shards. | [C02, p. 1] |
| Upsert | Actualización que inserta un documento si el filtro no encuentra coincidencias. | [P10A, pp. 4–5] |

Las precisiones actuales de CAP, validación, transacciones y métodos de MongoDB están etiquetadas como complemento en los [apuntes NoSQL](temas/15-nosql-y-cap.md) y en [dudas y conflictos](dudas-y-conflictos.md).

## Cassandra

| Término | Definición breve | Fuente |
|---|---|---|
| Bloom filter | Vector de bits y hashes para descartar ausencia con certeza; una respuesta positiva requiere comprobación. | [C04, pp. 3–7] |
| Clustering key | Columnas que ordenan filas dentro de una partición y completan su identificación. | [T16, pp. 56, 63–69; P12, p. 2] |
| Commit log | Registro de escrituras usado en la recuperación del nodo. | [T16, pp. 30–32] |
| Consistency level (CL) | Cantidad de respuestas o confirmaciones requeridas para completar una operación. | [T16, pp. 36, 41, 44–46] |
| Coordinador | Nodo que recibe una petición del cliente y coordina las réplicas involucradas. | [T16, pp. 25–26] |
| CQL | Lenguaje de consulta de Cassandra, similar a SQL, sin joins ni subconsultas en el material. | [T16, p. 13] |
| Data center | Agrupación lógica de nodos dentro del cluster. | [T16, p. 29] |
| Digest request | Solicitud de un resumen hash para contrastar el resultado entre réplicas. | [T16, pp. 42–43; C05] |
| Familia de columnas | Contenedor de filas, declarado como tabla en CQL en el TP. | [T16, p. 51; P12, p. 1] |
| Gossip | Comunicación entre pares para propagar información de estado y detectar fallas. | [T16, p. 28] |
| Keyspace | Agrupación de tablas/familias de columnas con política de replicación. | [T16, pp. 51, 59; P12, p. 1] |
| Memtable | Estructura en memoria que conserva escrituras antes de su flush a SSTables. | [T16, pp. 30–33] |
| Partition key | Clave que agrupa filas en una partición y participa en su distribución. | [T16, pp. 16, 56, 63–69] |
| Read repair | Reparación de datos desactualizados detectados durante una lectura; el mecanismo depende de versión/configuración. | [T16, pp. 28, 42–43; C05]; salvedad en [dudas](dudas-y-conflictos.md) |
| Replication factor (RF) | Cantidad de nodos que guardan una copia de cada fragmento; RF=1 no añade redundancia. | [T16, p. 59; P12, p. 1] |
| SSTable | Archivo persistente e inmutable creado a partir de una memtable. | [T16, pp. 30, 33] |
| Tombstone | Marca de borrado que permite representar eliminaciones sin modificar SSTables existentes. | [T16, pp. 38–39] |

Ver [modelado/CQL](temas/20-cassandra-modelado-y-cql.md), [almacenamiento/Bloom](temas/21-cassandra-almacenamiento-y-bloom.md) y [consistencia/DIGEST](temas/22-cassandra-consistencia-y-digest.md). Los complementos del manual se distinguen allí de las afirmaciones de cátedra.

## Neo4j

| Término | Definición breve | Fuente |
|---|---|---|
| Base orientada a grafos | Representa y almacena datos con nodos, relaciones y propiedades. | [T17, pp. 1, 16] |
| Bookmark | Marca de progreso que conserva el cliente para que una lectura posterior espere una réplica suficientemente actualizada. | [C06, p. 10] |
| Causal Clustering | Arquitectura de clúster con primarios que usan Raft y secundarios de lectura. | [C06, pp. 6, 13] |
| Cypher | Lenguaje de consulta de Neo4j basado en patrones de nodos y relaciones. | [T17, pp. 9, 19–20] |
| Grafo de propiedad | Grafo con peso, etiquetas y propiedades en nodos y relaciones; el modelo de Neo4j. | [T17, pp. 4–5] |
| Label | Rol o tipo asignado a un nodo, como `Person` o `Wine`. | [T17, p. 18] |
| `MERGE` | Busca un patrón completo y lo crea si no existe. | [C06, pp. 2–5] |
| Quórum (Raft) | Mayoría de primarios necesaria para elegir líder y confirmar escrituras; tolerar F fallas exige N ≥ 2F + 1. | [C06, pp. 7, 9] |
| Raft | Algoritmo de consenso con roles leader, follower y candidate que ordena las transacciones. | [C06, pp. 7–8] |
| Relación | Arista dirigida que conecta nodos, representa una acción y puede tener propiedades. | [T17, pp. 17–18] |

## Clave-valor y Redis

| Término | Definición breve | Fuente |
|---|---|---|
| AOF | Registro de cada escritura que Redis reproduce al iniciar para reconstruir los datos. | [T18, pp. 17, 21–23] |
| Base clave-valor | Tabla hash simple accedida siempre por clave, con operaciones PUT, GET y DEL. | [T18, p. 2] |
| Conjunto ordenado | Colección de miembros únicos con score, que puede repetirse, ordenada por ese score. | [T19, p. 14] |
| `DISCARD` | Vacía la cola de una transacción sin ejecutarla; no revierte cambios. | [T18, p. 14; T19, p. 7] |
| Lista bloqueante | Extracción (`BRPOP`) que espera hasta que haya un elemento o venza el plazo. | [T19, p. 11] |
| Pub/Sub | Publicación en un canal que reciben todos sus suscriptores. | [T19, pp. 21–22] |
| RDB | Snapshot compacto de los datos de Redis tomado a intervalos. | [T18, pp. 17, 19–20] |
| Sentinel | Procesos que monitorean maestro y réplicas de Redis y promueven una réplica ante una falla. | [T18, pp. 25–27] |
| TTL | Tiempo de vida de una clave, fijado con `EXPIRE` y consultado con `TTL`. | [T19, p. 16] |
| `WATCH` | Observa claves y aborta la transacción si alguna cambia. | [T18, p. 14] |

## DynamoDB

| Término | Definición breve | Fuente |
|---|---|---|
| GSI | Índice secundario global: otra partition key; puede modificarse después de crear la tabla. | [T20, pp. 18–20] |
| Ítem | Equivalente de una fila; admite atributos variables y hasta 400 KB. | [T20, pp. 4–5, 11] |
| LSI | Índice secundario local: misma partition key y otra sort key; se define al crear la tabla. | [T20, pp. 17–19] |
| Partition key (hash key) | Atributo obligatorio de la clave que determina la distribución de los datos. | [T20, pp. 6, 10, 14] |
| RCU / WCU | Unidades de capacidad de lectura (4 KB/s) y escritura (1 KB/s). | [T20, pp. 22–23] |
| Scan | Lectura de toda la tabla, como `SELECT *`. | [T20, pp. 12–13] |
| Sort key (range key) | Atributo opcional de la clave que ordena ítems con igual partition key y habilita consultas por rango. | [T20, pp. 6, 10, 14] |

Ver [Neo4j](temas/23-neo4j-grafos-y-cypher.md), [Redis](temas/25-clave-valor-y-redis.md) y [DynamoDB](temas/27-dynamodb.md).
