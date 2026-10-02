# Cassandra: replicación, consistencia y DIGEST

## Peer-to-peer y coordinador

Los nodos participan como pares; no hay un maestro permanente. Un cliente puede acceder a un nodo que actúa como coordinador de la petición y determina las réplicas involucradas. El coordinador es un rol de esa operación, y no necesita ser el nodo que guarda el dato. La unidad también presenta gossip como comunicación entre pares para conocer estado y detectar fallas. [T16, pp. 12, 25–29]

El particionado asigna datos mediante tokens derivados de claves, mientras que la estrategia de replicación decide dónde guardar copias. El keyspace define el **replication factor (RF)**, cantidad de copias de cada fragmento. La clase presenta `SimpleStrategy` y `NetworkTopologyStrategy`; el TP usa `SimpleStrategy` y RF=1 en un laboratorio de un solo nodo. RF=1 implica una copia, sin redundancia adicional. [T16, pp. 12, 59–61; P12, p. 1]

**Complemento del agente (no consta en el material cargado):** la configuración documentada usa `Murmur3Partitioner`; los otros partitioners enumerados por T16 son históricos. [Apache Cassandra: configuración](https://cassandra.apache.org/doc/latest/cassandra/managing/configuration/cass_yaml_file.html). Para replicación, el manual distingue `SimpleStrategy` de `NetworkTopologyStrategy`, que permite especificar RF por data center. [Definición de keyspace](https://cassandra.apache.org/doc/latest/cassandra/developing/cql/ddl.html).

## Replicación y confirmación no son lo mismo

En la [escritura distribuida](../../material/figuras/T16-p35-escritura-cluster.png), el coordinador envía la escritura a las réplicas correspondientes. El **consistency level (CL)** determina cuántas confirmaciones necesita para informar éxito; no redefine el RF ni significa escribir únicamente en ese número de nodos. En lectura, determina la cantidad de respuestas requeridas para completar la petición. [T16, pp. 35–37, 41, 44]

Las [tablas de lectura](../../material/figuras/T16-p45-consistencia-lecturas.png) y [escritura](../../material/figuras/T16-p46-consistencia-escrituras.png) incluyen `ONE`, `TWO`, `THREE`, `QUORUM`, `LOCAL_QUORUM`, `EACH_QUORUM` y `ALL`; la segunda agrega `ANY`. Son tablas históricas con salvedades de versión registradas en [dudas](../dudas-y-conflictos.md); no asumir que todos los niveles son válidos indistintamente para lectura y escritura. [T16, pp. 45–46]

Para estudiar el concepto de mayoría: `ONE` requiere una réplica, `QUORUM` una mayoría del conjunto relevante y `ALL` todas sus réplicas. El material distingue la mayoría local de un data center frente a la mayoría del conjunto. La fórmula de T16, p. 45, expresa mitad más uno; interpretada como cantidad entera de réplicas, la mayoría es `floor(N/2)+1`: con RF=3, se necesitan dos. Este cálculo es una explicitación del agente de la regla de mayoría presentada. [T16, pp. 45–46; C05]

**Complemento del agente (no consta en el material cargado):** las garantías dependen de combinar lectura y escritura; el solapamiento se expresa como `R + W > N`. `ANY` puede confirmar una escritura guardando un hint, y no sirve para lecturas. No basta declarar “QUORUM da consistencia fuerte” sin precisar ambas operaciones. [Apache Cassandra: consistencia ajustable](https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html).

La clasificación didáctica AP de [NoSQL y CAP](15-nosql-y-cap.md) y la consistencia configurable aparecen juntas en la clase. Una caída puede impedir satisfacer el CL exigido: no tomar “el servicio no se degradará” como garantía para cualquier cantidad de fallas o configuración. Esa limitación es una inferencia del agente a partir del requisito de respuestas. [T13, p. 18; T16, pp. 11, 36, 41, 44–46]

## Lectura directa, DIGEST y reparación

T16 distingue obtener los datos completos mediante **direct read request**, verificar réplicas mediante **digest request** y corregir datos desactualizados mediante **read repair**. El [recurso C05](../../material/catedra/teoria/recursos/c05-cassandra-digest.png), revisado visualmente, ilustra RF=3 con réplicas A, B y C. [T16, pp. 40–43; C05]

El recorrido didáctico de C05 es:

1. El coordinador obtiene el dato completo desde una réplica.
2. Pide resúmenes hash a otras réplicas y los compara.
3. Si coinciden, devuelve el resultado; si difieren, hay inconsistencia.
4. El ejemplo elige el dato con mayor timestamp: B a las 10:05 frente a A a las 10:00 y C a las 09:58.
5. El dibujo muestra actualización posterior de las réplicas viejas en segundo plano.

[C05; T16, pp. 41–43]

**Complemento del agente (no consta en el material cargado):** el esquema omite que un digest diferente exige recuperar datos completos para reconciliarlos; puede ser necesario combinar valores de columnas. Además, desde Cassandra 4.0 se retiró el background read repair descrito y se configura `read_repair` por tabla (`BLOCKING` o `NONE`). No se consultan obligatoriamente todas las réplicas en cada lectura. [Apache Cassandra: read repair](https://cassandra.apache.org/doc/latest/cassandra/managing/operating/read_repair.html). Conservar C05 como explicación de cátedra con esa salvedad, sin redibujar el original.

El timestamp del modelo interno se utiliza para resolver conflictos. La clase recomienda sincronización de relojes y distingue este metadato del nombre y valor de la columna. No confundirlo con cualquier atributo de negocio de tipo `timestamp`. [T16, pp. 50, 52, 54]

## Mantenimiento y seguridad

T16 recomienda operaciones `repair` periódicas para réplicas inconsistentes. También presenta usuarios/roles, privilegios mediante `GRANT` y `REVOKE`, cifrado de comunicaciones y backups. Son capacidades que requieren configuración; la clase no proporciona un laboratorio completo de seguridad distribuida. [T16, pp. 47–49]

**Complemento del agente (no consta en el material cargado):** el cliente `cqlsh` permite fijar el CL con `CONSISTENCY QUORUM;` antes de la consulta. El ejemplo `USING CONSISTENCY QUORUM` de T16, p. 45, se conserva como sintaxis histórica, no como receta actual. [Apache Cassandra: cqlsh](https://cassandra.apache.org/doc/latest/cassandra/managing/tools/cqlsh.html).

Continuar con [modelado y CQL](20-cassandra-modelado-y-cql.md), [almacenamiento/Bloom](21-cassandra-almacenamiento-y-bloom.md) o [TP 10](../../practica/tp-10/README.md).
