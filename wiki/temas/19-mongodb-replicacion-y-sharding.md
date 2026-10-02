# MongoDB: replicación y sharding

## Propósitos y componentes

| Aspecto | Replicación | Sharding |
|---|---|---|
| Objetivo del material | Alta disponibilidad y tolerancia a fallos. | Escalabilidad horizontal. |
| Distribución de datos | Copias de los mismos datos en un replica set. | Partes distintas de los datos en distintos shards. |
| Componentes | Primario y secundarios. | Shards, `mongos`, config servers y shard key. |
| Lecturas y escrituras | Por defecto, en el primario; lecturas distribuidas si se configura. | Distribución entre shards según el diseño. |

Ambos mecanismos pueden combinarse: los shards pueden ser replica sets para reunir fragmentación y redundancia. [C02, pp. 1–2; T13, p. 30]

## Replica set y elección

El material describe un primario que puede ser reemplazado por un secundario ante una falla. La [figura de elección](../../material/figuras/T15-p43-eleccion-replica-set.png) muestra detección mediante heartbeats, elección de un nuevo primario y continuidad de la replicación. Es una explicación conceptual; la figura no especifica todas las condiciones de una elección. [C02, p. 1; T15, p. 43]

T15 ofrece un ejemplo local con tres procesos `mongod`, directorios y puertos diferentes, la opción `--replSet book`, `rs.initiate(...)` y `rs.status()`. Usa el cliente antiguo `mongo`; al preparar una práctica hay que revisar la compatibilidad del entorno. [T15, pp. 41–42]

## Shards y enrutamiento

La **shard key** distribuye los datos entre servidores; `mongos` actúa como router de consultas y los config servers coordinan la información del cluster. T13 y T15 ilustran fragmentación horizontal por rangos de valores. Fragmentar datos y replicarlos son decisiones con propósitos distintos. [C02, pp. 1–2; T13, pp. 30–31; T15, p. 44]

La lista introductoria de T13 también nombra **GridFS** como función de almacenamiento. No debe interpretarse como un reemplazo de `mongod` o `mongos` ni como otro tipo de shard. [T13, p. 31]

**Complemento del agente (no consta en el material cargado):** GridFS permite almacenar archivos mayores que el límite de un documento BSON. [Manual oficial: límite BSON y GridFS](https://www.mongodb.com/docs/manual/reference/limits/).

## Relación con CAP

La clasificación didáctica de MongoDB como CP se encuentra en T13. La replicación y el failover por sí solos no explican todas las garantías de una aplicación; para desarrollar la clasificación del TP 9, partir de la diapositiva y explicitar el escenario de partición. Véase [NoSQL y CAP](15-nosql-y-cap.md). [T13, pp. 17–18; P10B, p. 2]
