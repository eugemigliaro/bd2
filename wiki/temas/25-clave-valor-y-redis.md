# Bases clave-valor y Redis: arquitectura

## El modelo clave-valor

Una estructura clave-valor es una tabla hash simple que se usa cuando todos los accesos se hacen por clave primaria. Sus operaciones son **PUT** (asignar un valor a una clave), **GET** (obtener el valor de una clave) y **DEL** (borrar una clave). Es el tipo de base más simple de usar desde una aplicación. [T18, p. 2]

El valor es un BLOB que la base almacena sin conocer su contenido; la aplicación es responsable de definirlo. Como el acceso es por clave primaria, suelen tener muy buena performance y escalar rápido. [T18, p. 3] Redis matiza esta descripción, porque sus valores tienen estructura y operaciones propias. [T18, p. 9; T19, pp. 34–35]

| Conviene usarlas | No conviene usarlas |
|---|---|
| Sesión web de un usuario: se guarda con un PUT y se recupera con un GET. | Relaciones entre datos. |
| Perfiles y preferencias, recuperados con un acceso por `userId`. | Transacciones de varias operaciones. |
| Carrito de compras asociado al usuario, guardado como un único objeto. | Consultas por valores dentro del campo valor. |
| | Operaciones sobre diferentes conjuntos de datos. |

[T18, pp. 6–7] La diapositiva de productos, revisada visualmente, muestra Redis, Aerospike, Riak, Oracle NoSQL, Amazon DynamoDB y Memcached. El ranking de septiembre de 2021 encabeza la categoría con Redis y DynamoDB. [T18, pp. 4–5] DynamoDB se estudia en [su propia página](27-dynamodb.md).

## Redis

Redis (*Remote Dictionary Server*) es un almacén de estructuras de datos en memoria, de código abierto y escrito en ANSI C. Organiza claves y valores en RAM y se usa como base de datos, caché o *broker* de mensajes. Sus estructuras son cadenas, hashes, listas, conjuntos (ordenados o no), mapas de bits, HyperLogLogs e índices geoespaciales; la clase práctica agrega streams. Tiene distintos tipos de persistencia y replicación. [T18, pp. 8–9; T19, p. 1] La clase da su licencia como BSD; ver la [salvedad](../dudas-y-conflictos.md#redis-versiones-licencia-y-seguridad).

Soporta transacciones, unión, intersección y diferencia de conjuntos, operaciones sobre conjuntos ordenados, operaciones probabilísticas y expiración de datos. [T18, p. 11] La clase práctica lo describe como una base en memoria que persiste en disco. Su primera versión es de 2009 y la estable citada es la 7.0.11 (abril de 2023). Ofrece replicación, transacciones, varios niveles de persistencia, alta disponibilidad con Sentinel y particionado automático con Redis Cluster. Según algunos benchmarks, supera las 100.000 operaciones `SET` por segundo. [T19, pp. 1, 4]

La diapositiva de usuarios muestra a Twitter, GitHub, Pinterest y Stack Overflow. [T18, p. 10] Los comandos están en [Redis: comandos y estructuras](26-redis-comandos-y-estructuras.md).

## Transacciones

| Comando | Efecto |
|---|---|
| `MULTI` | Inicia un lote; responde `OK` porque solo encola. |
| `EXEC` | Ejecuta todos los comandos encolados. |
| `DISCARD` | Vacía la cola y termina la transacción. |
| `WATCH` | Monitorea claves; si alguna cambia, la transacción entera se aborta. |

[T18, p. 14] Los comandos se serializan y ejecutan secuencialmente, como una única operación aislada, y ningún otro cliente es atendido en el medio. La transacción es atómica: se procesan todos los comandos o ninguno. Si el servidor falla, puede registrarse solo una parte de las operaciones, aunque es poco probable. Desde la versión 2.2, Redis permite bloqueo optimista. [T18, pp. 12–13]

No hay rollback: hay fallas que no se detectan antes de encolar los comandos, como claves con un tipo de dato incorrecto. [T18, p. 12] La clase práctica lo explica comparando `DISCARD` con `ROLLBACK`: `DISCARD` **no ejecuta** la transacción, pero no devuelve los datos a un estado anterior (*operation cancellation*, no *transaction rollback*). [T19, p. 7] Ver la tensión entre “atómica” y “sin rollback” en [dudas](../dudas-y-conflictos.md#redis-transacciones-persistencia-y-replicación).

## Replicación

- Es **maestro-esclavo**: las réplicas son copias exactas del maestro. Ante una falla, la réplica se reconecta sola y vuelve a sincronizarse.
- Con buena conexión, el maestro envía la secuencia de comandos que reflejan escrituras, claves caducadas o desalojadas.
- **Resincronización parcial:** tras un corte, la réplica pide la parte de la secuencia que perdió.
- **Resincronización total:** si la parcial no es posible, el maestro crea una instantánea completa, la envía y sigue con el proceso normal.

[T18, pp. 15–16] En el laboratorio, la réplica se configura con `port 6380` y `replicaof 127.0.0.1 6379`. `slaveof` es el nombre de la versión 4, renombrado en la 5. El cliente conectado a la réplica solo lee y recibe los cambios del maestro. En producción, las réplicas deben estar en otras máquinas. [T19, pp. 27–29]

## Persistencia: RDB y AOF

Hay tres opciones: sin persistencia (los datos viven solo en el servidor en ejecución), **RDB** (snapshots a intervalos) y **AOF** (registro de cada escritura, reproducido al iniciar para reconstruir los datos). Si el AOF crece demasiado, se reescribe en segundo plano. [T18, p. 17]

| | RDB | AOF |
|---|---|---|
| Qué guarda | Representación compacta de un punto en el tiempo. | Todas las operaciones de escritura, en secuencia y en un formato legible. |
| Ventajas | Ideal para backups (por hora durante 24 h, diarios durante 30 días) y recuperación de desastres; fácil de transferir; Redis no hace el I/O, que queda a cargo de un proceso secundario; reinicia más rápido con grandes volúmenes. | Políticas de fsync configurables; con la predeterminada “por segundo” se pierde a lo sumo un segundo; al ser *append*, un corte de energía no lo corrompe; se compacta generando un archivo nuevo mínimo. |
| Desventajas | Ante una falla se pierden los últimos minutos; el proceso hijo de grabación puede costar con conjuntos grandes y CPU lenta. | Archivos más grandes; puede ser más lento según fsync; actualiza incrementalmente un estado, mientras RDB lo rehace desde cero, lo que es conceptualmente más robusto. |

[T18, pp. 19–23] Se pueden combinar: al reiniciar, Redis usa el AOF porque es el más completo. La recomendación es AOF con alguna instantánea RDB para reiniciar más rápido ante errores del AOF. Ambos juntos dan una seguridad comparable a PostgreSQL; quien tolere perder unos minutos puede usar solo RDB. [T18, pp. 18, 24]

La configuración por defecto graba snapshots con `save 900 1`, `save 300 10` y `save 60 10000`: a los 15 minutos si cambió al menos una clave, a los 5 minutos si cambiaron 10, y al minuto si cambiaron 10.000. `SAVE` fuerza la grabación bloqueando a los clientes; en producción conviene `BGSAVE`. [T19, pp. 24–25]

**Análisis del agente:** el AOF cumple el papel de log que se reproduce al reiniciar; comparar con el WAL de [Recovery y WAL](14-recovery-y-wal.md). Las siglas y los nombres de las políticas de fsync se precisan en [dudas](../dudas-y-conflictos.md#redis-transacciones-persistencia-y-replicación).

## Sentinel: disponibilidad

La naturaleza de Redis exige que los datos estén siempre accesibles; el clúster se configura con **Sentinel**:

- **Servidor Redis:** guarda los datos en memoria; maestro M y réplicas R.
- **Procesos Sentinel (S):** monitorean maestros y réplicas y conmutan una réplica a maestro ante una falla.
- **Procesos cliente (C):** comunican la aplicación con Redis.

Puede haber cualquier cantidad de cada componente, salvo el maestro, que es único. El **quórum** es la cantidad de Sentinels que deben coincidir para marcar un nodo como caído y promover una réplica. Se necesitan al menos 3 Sentinels para un quórum de 2. Pueden convivir en la misma máquina, pero no conviene. [T18, pp. 25–27] El TP 12 remite a la documentación oficial de Sentinel. [P16, p. 2]

La clase práctica también reparte claves entre dos servidores con un cliente Ruby que aplica hashing consistente (`Redis::Distributed`). Ver la [salvedad](../dudas-y-conflictos.md#redis-transacciones-persistencia-y-replicación) sobre cómo se configuran esos servidores. [T19, p. 31]

## Seguridad

Los problemas principales son control de acceso, seguridad del código y entradas maliciosas. Redis está pensado para clientes de confianza en entornos de confianza: no debe exponerse directamente a Internet. Prioriza rendimiento y simplicidad, no seguridad máxima. La aplicación debe mediar con una capa que implemente ACL, valide la entrada y decida qué operaciones ejecutar. [T18, pp. 28–29]

`AUTH` seguido de la contraseña autentica al cliente: con la capa activada, Redis rechaza a los no autenticados. Evita accesos involuntarios, pero no protege el transporte. [T18, p. 30] La clase práctica, siguiendo al libro, considera `requirepass`/`AUTH` casi inútiles (contraseña en texto plano y unos 100.000 intentos por segundo) y prefiere firewall y SSH. También renombra comandos peligrosos como `FLUSHALL` con `rename-command`. [T19, pp. 25–26] Ver el contraste en [dudas](../dudas-y-conflictos.md#redis-versiones-licencia-y-seguridad).

## Scripts en Lua

Redis interpreta scripts Lua de forma nativa y garantiza que se ejecuten de forma atómica. Mientras un script corre, ningún otro cliente puede ejecutar comandos, por lo que hay que evitar scripts lentos. [T18, p. 31]

## Fortalezas, debilidades y CAP

| Fortalezas | Debilidades |
|---|---|
| Velocidad. | Es rápido en gran parte porque vive en memoria; si se apaga antes de un snapshot, se pierden datos. |
| Valores complejos (listas, hashes, conjuntos) con operaciones propias. | No admite conjuntos de datos mayores que la RAM disponible. |
| Durabilidad ajustable: se cambia velocidad por seguridad. | — |
| Replicación maestro-esclavo incorporada, ideal para sistemas con muchas lecturas. | — |

[T19, pp. 34–35] Tiene más de 120 comandos, y el libro recomienda sumarlo a cualquier ecosistema políglota junto al sistema de registro. [T19, pp. 35–36] El TP 12 pide este resumen y los casos de uso. [P16, p. 2]

El TP 12 también pide clasificarlo según CAP. [P16, p. 2] El material da dos respuestas: T19 lo considera **CA** porque no fragmenta datos, mientras el gráfico de T13 y la guía visual de T20 lo ubican en **CP**. Ver [CAP en dudas](../dudas-y-conflictos.md#cap-de-neo4j-redis-y-dynamodb). [T19, p. 36; T13, p. 18; T20, p. 31]
