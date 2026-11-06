# Persistencia políglota, Docker y entorno MySQL

## Persistencia políglota

La persistencia políglota aplica a datos la idea de usar la tecnología más adecuada para cada necesidad: una aplicación puede comunicarse con varios tipos de bases en vez de imponer un único motor a todos los casos. [C01, pp. 4–5]

La decisión no se reduce a “relacional o NoSQL”. Debe considerar tipo de modelo, durabilidad, disponibilidad, consistencia, escalabilidad, complejidad operativa y capacidades del equipo. Cuantos más motores se incorporan, mayor es el costo de integrar, desplegar, observar, respaldar y mantener. [C01, p. 6]

Para las familias NoSQL, escalabilidad y CAP, continuar en [NoSQL y CAP](15-nosql-y-cap.md); para la elección entre embebidos y referencias, en [modelado MongoDB](16-mongodb-modelado.md). Las nuevas unidades desarrollan decisiones que dependen de la aplicación y distinguen replicación de sharding. [T13, pp. 9, 21–30; T14, pp. 2–8; C02, pp. 1–2]

## Docker en dos conceptos

- **Imagen:** paquete inmutable con lo necesario para ejecutar una aplicación.
- **Contenedor:** instancia en ejecución de una imagen, con su proceso y estado asociado. [C01, p. 9]

Los contenedores comparten el kernel del host y suelen ser más livianos que una máquina virtual, que incluye un sistema operativo invitado completo. [C01, p. 10]

La cátedra propone Docker como una de las formas de levantar MySQL y permite conectarse con la CLI, MySQL Workbench o DataGrip. [C01, pp. 15–17]

## Entorno de este repositorio

El archivo `compose.yaml` fija MySQL `9.7.2`, crea la base `mydb` y carga el esquema de películas al inicializar un volumen vacío. Es la versión indicada por la Clase I. [C01, p. 15]

```bash
cp .env.example .env
make db-up       # iniciar
make db-status   # ver estado
make db-shell    # abrir cliente mysql dentro del contenedor
make db-down     # detener, conservando datos
make db-reset    # eliminar datos locales y reinicializar
```

El laboratorio es deliberadamente local y no representa una configuración de producción.

## Entorno MongoDB del repositorio

`compose.yaml` agrega el servicio `mongo` (contenedor `bd2-mongo`) para el TP 9. La guía propone `docker pull mongo` sin versión [P10A, p. 1]; el repositorio fija `mongo:7.0.43` porque las series 8.0 y posteriores no arrancan en el kernel Linux del entorno (ver [dudas](../dudas-y-conflictos.md#mongodb-y-kernels-linux-619)).

- Publica `27017` solo en `127.0.0.1`: corre sin autenticación.
- Monta `material/catedra/practica/recursos` en `/recursos` y `practica/` en `/practica`, ambos de solo lectura, así que `mongoimport` y `load()` leen los archivos sin `docker cp`.
- `make mongo-shell` abre `mongosh` sobre la base `lab`; `make db-up` levanta ambos motores.

## Entorno Cassandra de la guía

El TP 10 propone un contenedor Cassandra y `cqlsh`; ofrece DataGrip como alternativa con el puerto 9042 publicado. El [espacio del TP 10](../../practica/tp-10/README.md) indexa esa preparación y sus límites: la imagen no fija versión. El repositorio agrega el servicio `cassandra` a `compose.yaml` (contenedor `bd2-cassandra`), fijado en 5.0.9 —hoy `latest` apunta a una 6.0 alfa—, con heap de 1 GB, sin autenticación y publicado solo en `127.0.0.1`; `make cql-shell` abre `cqlsh`. La parte II no agrega instalación: pide levantar Cassandra según lo hecho en la parte I. Para diseñar el modelo, seguir [Cassandra y CQL](20-cassandra-modelado-y-cql.md). [P12, p. 1; P13, p. 1; T16, pp. 13, 16–19]

## Entornos de Neo4j, Redis y DynamoDB de las guías

Los TP 11, 12 y 13 siguen el mismo esquema de contenedor: `docker pull`, `docker run --name ... -d`, `docker stop`/`start` y `docker exec -it ... bash`. Ninguna imagen fija versión, y el repositorio todavía no agrega estos servicios a `compose.yaml`. [P15, p. 1; P16, p. 1; P17, p. 1]

| Guía | Imagen | Puertos | Cliente |
|---|---|---|---|
| TP 11 | `neo4j`, con `NEO4J_AUTH=none` | 7474 (navegador) y 7687 (Bolt) | Neo4j Browser y Cypher |
| TP 12 | `redis` | 6379 | `redis-cli` |
| TP 13 | `amazon/dynamodb-local` | 8000 | AWS CLI con `--endpoint-url http://localhost:8000` |

Ver los espacios del [TP 11](../../practica/tp-11/README.md), [TP 12](../../practica/tp-12/README.md) y [TP 13](../../practica/tp-13/README.md), y las salvedades de entorno en [dudas](../dudas-y-conflictos.md#tp-11-12-y-13-preparación-bibliografía-y-vacíos). El libro remata el capítulo de Redis con un ejemplo de persistencia políglota: CouchDB como sistema de registro, Neo4j para relaciones y Redis como intermediario. [B01, pp. 289, 293]
