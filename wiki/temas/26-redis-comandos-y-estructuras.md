# Redis: comandos y estructuras de datos

## Entorno y cliente

La clase práctica instala Redis desde el código fuente o, en Windows, con WSL2; aclara que en la práctica se use Docker. El servidor `redis-server` escucha por defecto en el puerto 6379, y el cliente `redis-cli` responde `PONG` a `PING`. `HELP` orienta sobre los grupos de comandos. [T19, pp. 4–6] El TP 12 levanta un contenedor y entra con `redis-cli`; ver el [espacio del TP 12](../../practica/tp-12/README.md). [P16, p. 1]

El hilo conductor del libro es un acortador de URLs al estilo bit.ly. [T19, p. 6]

## Convención de nombres

- Los comandos de conjuntos empiezan con `S`; los de hashes, con `H`; los de conjuntos ordenados, con `Z`.
- Los de listas suelen empezar con `L` (izquierda) o `R` (derecha), según el extremo sobre el que operan.
- Cada colección admite hasta 2³² elementos por clave; la memoria necesaria depende de las colecciones.

[T19, pp. 7–8]

## Cadenas y contadores

| Comandos | Uso | Fuente |
|---|---|---|
| `SET`, `GET` | Asignar y leer una clave; O(1). | [T19, p. 6] |
| `MSET`, `MGET` | Varias claves a la vez; O(N). `MGET` devuelve `nil` para una clave inexistente. | [T19, p. 6; P18A] |
| `INCR` | Sumar uno a un valor numérico. | [T19, pp. 6–7] |
| `SETNX` | Asignar solo si la clave no existe: devuelve 1 si la crea y 0 si ya existía. | [P18A] |
| `EXISTS`, `DEL` | Comprobar existencia y borrar. | [P18A] |
| `KEYS patrón` | Listar claves; admite `*`, rangos `[1-3]` y negación `[^6]`. | [T19, p. 9; P18A] |

## Hashes

En lugar de claves separadas como `user:luc:name` y `user:luc:password`, un hash agrupa pares campo-valor bajo una sola clave:

```text
HMSET user:luc name "Luc" password "s3cret"
HKEYS user:luc        -> name, password
HVALS user:luc        -> Luc, s3cret
HGET user:luc password
HGETALL user:luc
```

Otros comandos son `HDEL`, `HINCRBY`, `HLEN` y `HSETNX`. La clase señala una errata del libro, que usa `HVALS` donde corresponde `HKEYS`. [T19, pp. 8–9] La solución de cátedra combina `HSET` y `HMSET` para cargar libros. [P18A] Ver la precisión sobre `HMSET` en [dudas](../dudas-y-conflictos.md#redis-versiones-licencia-y-seguridad).

## Listas

Las listas guardan valores ordenados y sirven como colas (FIFO) o pilas (LIFO). También permiten insertar en el medio, limitar el tamaño y mover valores entre listas. [T19, p. 9]

| Comando | Efecto |
|---|---|
| `RPUSH` / `LPUSH` | Agregar por la derecha o por la izquierda. |
| `LRANGE clave 0 -1` | Leer toda la lista; los índices negativos cuentan desde el final. |
| `LREM clave 0 valor` | Quitar las apariciones de un valor. |
| `LPOP` / `RPOP` | Sacar por la izquierda o por la derecha; con la lista vacía devuelve `nil`. |
| `RPOPLPUSH origen destino` | Sacar del final de una lista y empujar al inicio de otra. |
| `LLEN`, `LINDEX` | Longitud y elemento por posición. |

`RPUSH` con `RPOP` es una pila; `LPUSH` con `RPOP`, una cola; `LPUSH` con `LPOP`, otra pila. [T19, pp. 9–10; P18A]

**Listas bloqueantes.** `BRPOP clave timeout` bloquea la conexión hasta que haya un elemento o venza el plazo. En el ejemplo, un cliente espera en `comments` y recibe el `LPUSH` que otro hace 11 segundos después. [T19, pp. 10–11]

## Conjuntos

| Comando | Efecto |
|---|---|
| `SADD`, `SMEMBERS` | Agregar miembros y listar el conjunto. |
| `SINTER`, `SDIFF`, `SUNION` | Intersección, diferencia y unión. |
| `SUNIONSTORE`, `SINTERSTORE`, `SDIFFSTORE` | Guardar el resultado en una clave nueva. |
| `SMOVE` | Mover un miembro a otro conjunto. |
| `SCARD` | Cardinalidad. |
| `SPOP` / `SREM` | Sacar un miembro al azar / quitar uno dado. |
| `SISMEMBER` | Pertenencia: 0 o 1. |
| `SRANDMEMBER clave n` | `n` miembros al azar: sin repetir si `n` es positivo, con repeticiones posibles si es negativo. |

Como los conjuntos no están ordenados, no tienen comandos posicionales. [T19, pp. 11–13; P18A]

## Conjuntos ordenados

Son colecciones de cadenas no repetidas, como los conjuntos, pero cada miembro tiene un **score** que ordena el conjunto de menor a mayor. Los miembros son únicos; los scores pueden repetirse. El ejemplo típico es una tabla de posiciones de un juego. [T19, p. 14]

```text
ZADD visits 500 7wks 9 gog 9999 prag      -> (integer) 3
ZINCRBY visits 1 prag                     -> "10000"
ZRANGE visits 0 1                         -> gog, 7wks
ZREVRANGE visits 0 -1 WITHSCORES          -> prag 10000, 7wks 500, gog 9
ZRANGEBYSCORE visits 9 10000              -> extremos incluidos
ZRANGEBYSCORE visits (9 9999              -> "(" excluye el extremo
ZRANGEBYSCORE visits -inf inf
ZREVRANGEBYSCORE visits inf -inf
```

[T19, pp. 14–15] `ZUNIONSTORE destino numkeys ... [WEIGHTS ...] [AGGREGATE SUM|MIN|MAX]` une conjuntos con pesos distintos. [T19, p. 16] La solución de cátedra agrega `ZCOUNT clave min max` (cuántos miembros hay en el rango de scores) y `ZREM`. [P18A]

## Expiración

`EXPIRE clave segundos` fija un tiempo de vida (TTL) y `TTL` informa cuánto falta. `PERSIST` anula el vencimiento antes de que ocurra; cuando vence, `EXISTS` pasa de 1 a 0. [T19, p. 16] `TTL` devuelve −1 si la clave no tiene vencimiento y −2 cuando ya expiró. [P18A]

## Bases numeradas

La base 0 es la predeterminada y `SELECT índice` cambia de base (el prompt muestra `[1]`). Sirven para separar claves de una misma aplicación, no para alojar aplicaciones independientes. Redis Cluster solo admite la base 0. `MOVE clave base` mueve una clave entre bases. `FLUSHDB` borra la base actual y `FLUSHALL`, todas. [T19, pp. 17–18]

## Clientes, pipelines y protocolo

- En Python, `redis.StrictRedis(host='localhost', port=6379, db=0)` se conecta. `pipeline()` acumula comandos y, por defecto, los envuelve en `MULTI`/`EXEC`, salvo con `transaction=False`. [T19, pp. 18–19]
- Redis no implementa REST: su protocolo es texto simple sobre TCP. Se puede hablar con él con `telnet` o `nc` y encadenar comandos separados por `\r\n`. [T19, pp. 19–20]
- Cargar 100.000 claves con Ruby tarda 5,85 s; con pipeline, 1,06 s. [T19, pp. 30–31]

## Publicar y suscribirse

`SUBSCRIBE comments` deja al cliente leyendo mensajes del canal. `PUBLISH comments "..."` devuelve cuántos suscriptores lo recibieron (2 en el ejemplo con dos clientes). [T19, pp. 21–22] **Análisis del agente:** en la lista bloqueante, cada elemento lo saca un único lector; en pub/sub, todos los suscriptores reciben el mensaje publicado. [T19, pp. 11, 21–22]

## Servidor: información, configuración y rendimiento

- `INFO` devuelve estadísticas: versión, modo y sistema operativo, entre otras. [T19, p. 22]
- Sin archivo de configuración, Redis arranca con valores por defecto y lo advierte. Parámetros comentados: `daemonize` (no en desarrollo; en producción, con log a archivo), `port`, `loglevel`, `logfile` y `databases 16` (conviene bajarlo a 1 si solo se usa la base 0). [T19, pp. 23–24]
- `redis-benchmark -n 100000` mide cuánto tardan 100.000 operaciones de cada tipo; el ejemplo da unas 73.000 `SET` y 74.000 `GET` por segundo. [T19, pp. 26–27]

## Bloom filters

Un Bloom filter es una estructura probabilística, eficiente en espacio, que prueba si un elemento pertenece a un conjunto. La clase lo usa primero desde una biblioteca Ruby y con `SETBIT`/`GETBIT`. Desde Redis 4.0, el tipo puede agregarse compilando un módulo (RedisBloom/ReBloom) y cargándolo con `--loadmodule`. [T19, pp. 32–33] El TP 12 pide probar la versión con `SETBIT`/`GETBIT` del libro. [P16, p. 2] El mecanismo es el mismo que se estudió para [Cassandra](21-cassandra-almacenamiento-y-bloom.md): admite falsos positivos, no falsos negativos. [C04, pp. 5–8]

## Ejercicio de cátedra

El [ejercicio Redis](../../practica/ejercicio-redis/README.md) tiene cinco partes: películas en cadenas, una lista de cantantes, hashes de libros, conjuntos de bases NoSQL y relacionales, y un conjunto ordenado por popularidad. La solución de cátedra comenta qué devuelve cada comando. [P18; P18A]
