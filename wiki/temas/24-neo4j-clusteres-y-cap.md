# Neo4j: clústeres, Raft y CAP

## Ediciones y escala

Neo4j puede embeberse en una aplicación o correr en clústeres con replicación master-slave. La Community Edition es GPL y alcanza para los días 1 y 2 del libro. Alta disponibilidad (HA) y backups requieren Enterprise Edition. [T17, pp. 19, 40] El código fuente se publica bajo GPLv3 y AGPLv3; los binarios, como *freemium registerware*. [T17, p. 15]

## Alta disponibilidad histórica: Neo4j HA

- Un nodo **master** y varios **slaves**. Los slaves aceptan escrituras y las sincronizan con el master.
- Si el master queda offline, un slave toma su lugar; la elección es automática.
- Los clústeres dependían de ZooKeeper como mecanismo de coordinación externo.

[T17, p. 36] El laboratorio levanta tres instancias Enterprise 3.4.9 con `dbms.mode=HA`, `ha.server_id`, `ha.initial_hosts` y puertos de coordinación, datos, HTTP y Bolt distintos por instancia. Un nodo creado desde `cypher-shell` en un servidor aparece en otro. [T17, pp. 37–39]

`neo4j-admin backup` permite un backup completo y después incrementales. [T17, p. 39] HA es una arquitectura retirada; ver [dudas](../dudas-y-conflictos.md#neo4j-versiones-sintaxis-histórica-y-afirmaciones-generales).

## Causal Clustering

La [arquitectura del anexo](../../material/figuras/C06-p6-arquitectura-causal-clustering.png) distingue:

| Rol | Función |
|---|---|
| Primarios (A, B, C) | Participan del consenso Raft y aceptan escrituras; uno es líder y los otros followers. |
| Secundarios (D, E) | Réplicas de lectura con replicación asíncrona; no votan en Raft. Escalan lecturas. |

[C06, p. 6] La síntesis de cierre separa los conceptos: **Raft** es el algoritmo de consenso y **Causal Clustering** es la arquitectura distribuida. [C06, p. 13]

## Raft

| Rol | Función |
|---|---|
| Leader | Coordina el log de consenso de una base de datos. |
| Follower | Replica entradas y participa en votaciones. |
| Candidate | Solicita votos al comenzar una elección. |

Si falla el líder, los miembros restantes pueden elegir otro. Elegir y confirmar requiere mayoría de votantes. Raft ordena las transacciones; no coordina las lecturas en secundarios. [C06, p. 7]

Una escritura se confirma así: (1) el cliente la envía; (2) el líder agrega una entrada al log; (3) la replica a los followers; (4) la mayoría confirma la recepción; (5) la entrada se compromete y se aplica. [C06, p. 8]

| Primarios | Quórum | Fallas toleradas |
|---|---|---|
| 3 | 2 | 1 |
| 5 | 3 | 2 |
| 7 | 4 | 3 |

Para tolerar F fallas hacen falta **N ≥ 2F + 1** primarios. Sin mayoría no se confirman nuevas escrituras mediante Raft. [C06, p. 9] Es la misma aritmética de mayoría que `QUORUM` en [Cassandra](22-cassandra-consistencia-y-digest.md). [T16, pp. 45–46]

## Bookmarks y consistencia causal

Tras una primera transacción, el cliente conserva un **bookmark** con el punto de progreso alcanzado. Una transacción posterior que lo presenta espera a que la réplica esté suficientemente actualizada. Así se evita que una lectura causalmente dependiente observe un estado anterior, aunque los secundarios tengan retraso de replicación, y se obtiene *Read Your Own Writes*. [C06, p. 10]

## Comparación con Cassandra

| Neo4j (clúster) | Cassandra (operación habitual) |
|---|---|
| Primarios con Raft; consenso por mayoría; secundarios para lecturas; bookmarks para causalidad. | Sin líder único de escritura; niveles de consistencia configurables; replicación entre nodos. |

Cassandra usa consenso adicional solo en operaciones específicas, como las LWT. [C06, p. 11] Comparar con [coordinador y niveles de consistencia](22-cassandra-consistencia-y-digest.md). [T16, pp. 25–26, 45–46]

## Actividad de clase

El anexo propone un caso con 3 primarios y 2 secundarios, y su guía de respuestas:

- Si falla el líder, quedan 2 de 3 primarios: puede elegirse otro líder y se mantiene el quórum.
- Si luego falla otro primario, queda 1 de 3: no hay mayoría para nuevas escrituras.
- Si un cliente escribe y lee desde un secundario, este puede estar atrasado; un bookmark permite esperar el progreso causal.
- `MERGE` busca o crea patrones; una restricción `UNIQUE` protege la identidad ante concurrencia. Ver [MERGE](23-neo4j-grafos-y-cypher.md#merge).

[C06, pp. 12–13]

## Fortalezas y debilidades

| Fortalezas | Debilidades |
|---|---|
| Sin tipos ni esquema; no restringe cómo se relacionan los datos. | La nomenclatura (*node* y *relationship*, no *vertex* y *edge*) complica la comunicación. |
| Búsquedas con Lucene, Cypher e interfaz REST. | HA replica el grafo completo; no fragmenta subgrafos, lo que limita el tamaño. |
| Recorridos rápidos: un vecino está a un paso, sin joins. | La licencia GPL/AGPL no es tan permisiva como MIT; HA y backups requieren licencia Enterprise. |
| HA de Enterprise para sitios con mucha lectura. | Modelar en grafos puede costar si no hay costumbre. |

[T17, pp. 39–40] El libro considera Neo4j una opción obvia para redes sociales y pide evaluarlo también para problemas menos evidentes. [T17, p. 40] El TP 11 pide este resumen y los casos de uso. [P15, p. 2]

## CAP

El material no da una única clasificación:

- **T17 (libro, HA):** Neo4j HA es **AP**. Cada slave devuelve lo que tiene, que puede estar temporalmente desincronizado; es eventualmente consistente y se recomienda para cargas con predominio de lectura. [T17, p. 40]
- **T19:** Redis y Neo4j son **CA** porque no fragmentan datos, aunque CAP “no tiene mucho sentido” en sistemas no distribuidos. [T19, p. 36]
- **C06 (clúster Raft):** sin mayoría no se confirman escrituras, y los secundarios pueden atrasarse salvo con bookmarks. [C06, pp. 9–10]
- **T13:** el gráfico de clasificación no incluye Neo4j. [T13, p. 18]

El TP 11 pide clasificarlo. [P15, p. 2] Antes de responder, fijar qué arquitectura se analiza; ver [CAP en dudas](../dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb).
